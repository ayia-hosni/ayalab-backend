package com.ayalab.cdk;

import software.amazon.awscdk.*;
import software.amazon.awscdk.services.ec2.*;
import software.amazon.awscdk.services.iam.*;
import software.amazon.awscdk.services.rds.*;
import software.amazon.awscdk.services.s3.assets.Asset;
import software.constructs.Construct;

import java.util.List;

public class AyalabStack extends Stack {

    public AyalabStack(final Construct scope, final String id, final StackProps props) {
        super(scope, id, props);

        // ── Context variables (pass with: cdk deploy -c key=value) ────────────
        String dbPassword     = contextOrDefault("dbPassword",     "ayalab_change_me");
        String frontendOrigin = contextOrDefault("frontendOrigin", "http://localhost:4200");
        String appVersion     = contextOrDefault("appVersion",     "1.0.0");

        // ── VPC ───────────────────────────────────────────────────────────────
        // natGateways(0) keeps us in the free tier — no NAT Gateway charges.
        Vpc vpc = Vpc.Builder.create(this, "Vpc")
                .maxAzs(2)
                .natGateways(0)
                .subnetConfiguration(List.of(
                        SubnetConfiguration.builder()
                                .name("Public")
                                .subnetType(SubnetType.PUBLIC)
                                .cidrMask(24)
                                .build(),
                        SubnetConfiguration.builder()
                                .name("Isolated")
                                .subnetType(SubnetType.PRIVATE_ISOLATED)
                                .cidrMask(24)
                                .build()
                ))
                .build();

        // ── Security groups ───────────────────────────────────────────────────
        SecurityGroup ec2Sg = SecurityGroup.Builder.create(this, "Ec2Sg")
                .vpc(vpc)
                .description("Backend EC2 — SSH and API")
                .allowAllOutbound(true)
                .build();
        ec2Sg.addIngressRule(Peer.anyIpv4(), Port.tcp(22),   "SSH");
        ec2Sg.addIngressRule(Peer.anyIpv4(), Port.tcp(8080), "Backend API");

        SecurityGroup rdsSg = SecurityGroup.Builder.create(this, "RdsSg")
                .vpc(vpc)
                .description("RDS — PostgreSQL reachable from EC2 only")
                .allowAllOutbound(false)
                .build();
        rdsSg.addIngressRule(ec2Sg, Port.tcp(5432), "PostgreSQL from EC2");

        // ── RDS PostgreSQL — db.t3.micro + 20 GB = free tier ─────────────────
        DatabaseInstance rds = DatabaseInstance.Builder.create(this, "Db")
                .engine(DatabaseInstanceEngine.postgres(
                        PostgresInstanceEngineProps.builder()
                                .version(PostgresEngineVersion.VER_16)
                                .build()))
                .instanceType(InstanceType.of(InstanceClass.BURSTABLE3, InstanceSize.MICRO))
                .vpc(vpc)
                .vpcSubnets(SubnetSelection.builder()
                        .subnetType(SubnetType.PRIVATE_ISOLATED)
                        .build())
                .securityGroups(List.of(rdsSg))
                .databaseName("ayalab")
                .credentials(Credentials.fromPassword(
                        "ayalab", SecretValue.unsafePlainText(dbPassword)))
                .allocatedStorage(20)
                .storageType(StorageType.GP2)
                .backupRetention(Duration.days(0))
                .deleteAutomatedBackups(true)
                .removalPolicy(RemovalPolicy.DESTROY)
                .deletionProtection(false)
                .build();

        // ── IAM role for EC2 ──────────────────────────────────────────────────
        Role ec2Role = Role.Builder.create(this, "Ec2Role")
                .assumedBy(new ServicePrincipal("ec2.amazonaws.com"))
                .managedPolicies(List.of(
                        // SSM lets you open a shell without SSH if needed
                        ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMManagedInstanceCore")
                ))
                .build();

        // ── CDK Assets — JAR and Dockerfile uploaded to S3 automatically ──────
        // Run `mvn package -DskipTests` in the project root before `cdk deploy`.
        Asset jarAsset = Asset.Builder.create(this, "AppJar")
                .path("../target/aya-lab-backend-" + appVersion + ".jar")
                .build();
        Asset dockerfileAsset = Asset.Builder.create(this, "AppDockerfile")
                .path("../Dockerfile")
                .build();
        jarAsset.grantRead(ec2Role);
        dockerfileAsset.grantRead(ec2Role);

        // ── SSH key pair — private key stored in SSM Parameter Store ──────────
        KeyPair keyPair = KeyPair.Builder.create(this, "KeyPair")
                .keyPairName("ayalab-key")
                .build();

        // ── User data — runs at EC2 first boot ───────────────────────────────
        UserData userData = UserData.forLinux();

        // 1. Install Docker and AWS CLI
        userData.addCommands(
                "apt-get update -y",
                "apt-get install -y docker.io awscli",
                "systemctl enable --now docker",
                "mkdir -p /home/ubuntu/app/target"
        );

        // 2. Download JAR and Dockerfile from S3 (CDK uploads them during deploy)
        userData.addS3DownloadCommand(S3DownloadOptions.builder()
                .bucket(jarAsset.getBucket())
                .bucketKey(jarAsset.getS3ObjectKey())
                .localFile("/home/ubuntu/app/target/aya-lab-backend-" + appVersion + ".jar")
                .build());
        userData.addS3DownloadCommand(S3DownloadOptions.builder()
                .bucket(dockerfileAsset.getBucket())
                .bucketKey(dockerfileAsset.getS3ObjectKey())
                .localFile("/home/ubuntu/app/Dockerfile")
                .build());

        // 3. Build image and start container
        userData.addCommands(
                "cd /home/ubuntu/app",
                "docker build -t ayalab-backend:latest .",
                "docker run -d --restart unless-stopped --name ayalab-backend -p 8080:8080"
                        + " -e DB_URL=jdbc:postgresql://" + rds.getDbInstanceEndpointAddress() + ":5432/ayalab"
                        + " -e DB_USERNAME=ayalab"
                        + " -e DB_PASSWORD=" + dbPassword
                        + " -e FRONTEND_ORIGIN=" + frontendOrigin
                        + " ayalab-backend:latest"
        );

        // ── EC2 instance — t2.micro = free tier ──────────────────────────────
        Instance ec2 = Instance.Builder.create(this, "Backend")
                .instanceType(InstanceType.of(InstanceClass.T2, InstanceSize.MICRO))
                .machineImage(MachineImage.lookup(LookupMachineImageProps.builder()
                        .name("ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*")
                        .owners(List.of("099720109477")) // Canonical
                        .build()))
                .vpc(vpc)
                .vpcSubnets(SubnetSelection.builder()
                        .subnetType(SubnetType.PUBLIC)
                        .build())
                .securityGroup(ec2Sg)
                .role(ec2Role)
                .keyPair(keyPair)
                .userData(userData)
                .build();

        // ── Elastic IP — static public IP that survives instance restarts ─────
        CfnEIP eip = CfnEIP.Builder.create(this, "Eip")
                .instanceId(ec2.getInstanceId())
                .domain("vpc")
                .build();

        // ── Stack outputs ─────────────────────────────────────────────────────
        CfnOutput.Builder.create(this, "BackendUrl")
                .description("Backend API URL")
                .value("http://" + eip.getAttrPublicIp() + ":8080")
                .build();

        CfnOutput.Builder.create(this, "RdsEndpoint")
                .description("RDS PostgreSQL endpoint (private)")
                .value(rds.getDbInstanceEndpointAddress())
                .build();

        CfnOutput.Builder.create(this, "RetrieveSshKey")
                .description("Download the SSH private key from SSM")
                .value("aws ssm get-parameter --name /ec2/keypair/" + keyPair.getKeyPairId()
                        + " --with-decryption --query Parameter.Value --output text"
                        + " > ayalab-key.pem && chmod 400 ayalab-key.pem")
                .build();

        CfnOutput.Builder.create(this, "SshCommand")
                .description("SSH into the EC2 instance")
                .value("ssh -i ayalab-key.pem ubuntu@" + eip.getAttrPublicIp())
                .build();
    }

    private String contextOrDefault(String key, String defaultValue) {
        Object value = this.getNode().tryGetContext(key);
        return value != null ? (String) value : defaultValue;
    }
}
