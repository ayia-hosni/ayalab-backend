resource "aws_db_subnet_group" "main" {
  name       = "ayalab-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = { Name = "ayalab-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier        = "ayalab-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"  # free tier
  allocated_storage = 20             # free tier max

  db_name  = "ayalab"
  username = "ayalab"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0  # disable automated backups (free tier)
  deletion_protection     = false

  tags = { Name = "ayalab-postgres" }
}
