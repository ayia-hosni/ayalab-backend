package com.ayalab.judge;

import com.ayalab.dto.SubmitResult;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Compiles and executes a user-supplied Java {@code Solution.reverseList(head)}
 * implementation against a list of test cases.
 *
 * <p>Unlike {@link JavaScriptJudge}, there is no equivalent to a GraalVM
 * polyglot sandbox for compiled Java bytecode on the JVM (the {@code
 * SecurityManager} API used for this historically was removed in JDK 24).
 * Isolation here is at the process level instead: the user's code is compiled
 * and run in a brand-new {@code java} process, in its own temp working
 * directory, with a capped heap and a hard wall-clock timeout that forcibly
 * kills the process if exceeded. That process still has the ordinary JDK
 * standard library available to it (file/network APIs included), so this is
 * "good enough" isolation for a single-user local practice tool &mdash; it is
 * not a substitute for a real container/seccomp sandbox and should not be
 * exposed as a multi-tenant public service as-is.</p>
 */
@Component
public class JavaJudge {

    private static final long COMPILE_TIMEOUT_MS = 10_000;
    private static final long RUN_TIMEOUT_MS = 8_000;
    private static final String ERROR_PREFIX = "__ERROR__:";

    /**
     * Harness split around the user-code injection point and joined with plain
     * concatenation (never String.format/.formatted) so a stray '%' in the
     * user's own code or comments can never be misread as a format specifier.
     */
    private static final String HARNESS_PREFIX = """
            import java.util.*;
            import java.io.*;

            class ListNode {
                int val;
                ListNode next;
                ListNode() {}
                ListNode(int val) { this.val = val; }
                ListNode(int val, ListNode next) { this.val = val; this.next = next; }
            }

            // ===== user code begins =====
            """;

    private static final String HARNESS_SUFFIX = """

            // ===== user code ends =====

            public class Main {
                static ListNode fromArray(int[] a) {
                    ListNode dummy = new ListNode(0), t = dummy;
                    for (int v : a) { t.next = new ListNode(v); t = t.next; }
                    return dummy.next;
                }
                static List<Integer> toList(ListNode h) {
                    List<Integer> out = new ArrayList<>();
                    int guard = 0;
                    while (h != null) { out.add(h.val); if (++guard > 100000) break; h = h.next; }
                    return out;
                }
                static int[] parseInts(String line) {
                    line = line.trim().replace("[", "").replace("]", "");
                    if (line.isEmpty()) return new int[0];
                    String[] parts = line.split(",");
                    int[] arr = new int[parts.length];
                    for (int i = 0; i < parts.length; i++) arr[i] = Integer.parseInt(parts[i].trim());
                    return arr;
                }
                public static void main(String[] args) throws Exception {
                    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
                    int n = Integer.parseInt(br.readLine().trim());
                    Solution sol = new Solution();
                    for (int i = 0; i < n; i++) {
                        String line = br.readLine();
                        try {
                            int[] arr = parseInts(line == null ? "" : line);
                            ListNode head = fromArray(arr);
                            ListNode res = sol.reverseList(head);
                            List<Integer> out = toList(res);
                            StringBuilder sb = new StringBuilder();
                            for (int j = 0; j < out.size(); j++) {
                                if (j > 0) sb.append(',');
                                sb.append(out.get(j));
                            }
                            System.out.println(sb);
                        } catch (Throwable t) {
                            String msg = t.getMessage();
                            System.out.println("__ERROR__:" + t.getClass().getSimpleName() + (msg != null ? (": " + msg) : ""));
                        }
                    }
                }
            }
            """;

    public SubmitResult run(String userCode, List<TestCase> cases) {
        long start = System.nanoTime();
        Path workDir;
        try {
            workDir = Files.createTempDirectory("aya-java-judge-");
        } catch (IOException e) {
            return new SubmitResult(false, "Error", "Could not allocate a workspace: " + e.getMessage(), 0, List.of());
        }

        try {
            Path source = workDir.resolve("Main.java");
            Files.writeString(source, HARNESS_PREFIX + userCode + HARNESS_SUFFIX, StandardCharsets.UTF_8);

            String javaHome = System.getProperty("java.home");
            String javac = javaHome + File.separator + "bin" + File.separator + "javac";
            String javaBin = javaHome + File.separator + "bin" + File.separator + "java";

            ProcessResult compile = runProcess(
                    List.of(javac, "-d", workDir.toString(), source.toString()),
                    workDir, null, COMPILE_TIMEOUT_MS);

            if (compile.timedOut()) {
                return new SubmitResult(false, "Compile Error", "Compilation timed out.", 0, List.of());
            }
            if (compile.exitCode() != 0) {
                return new SubmitResult(false, "Compile Error", cleanPaths(compile.stderr(), workDir), 0, List.of());
            }

            StringBuilder stdin = new StringBuilder();
            stdin.append(cases.size()).append('\n');
            for (TestCase tc : cases) {
                stdin.append(tc.input().toString().replaceAll("[\\[\\] ]", "")).append('\n');
            }

            ProcessResult run = runProcess(
                    List.of(javaBin, "-Xmx256m", "-XX:+UseSerialGC", "-cp", workDir.toString(), "Main"),
                    workDir, stdin.toString(), RUN_TIMEOUT_MS);

            long elapsedMs = (System.nanoTime() - start) / 1_000_000;

            if (run.timedOut()) {
                List<SubmitResult.CaseResult> results = new ArrayList<>();
                for (TestCase tc : cases) {
                    results.add(new SubmitResult.CaseResult(false, tc.input(), tc.expected(), null, "Time Limit Exceeded"));
                }
                return new SubmitResult(false, "Time Limit Exceeded", null, elapsedMs, results);
            }

            if (cases.isEmpty()) {
                return new SubmitResult(true, "Accepted", null, elapsedMs, List.of());
            }

            String stdout = run.stdout();
            String[] lines = stdout.isEmpty() ? new String[0] : stdout.split("\n", -1);

            List<SubmitResult.CaseResult> results = new ArrayList<>();
            boolean allPassed = true;
            for (int i = 0; i < cases.size(); i++) {
                TestCase tc = cases.get(i);
                if (i >= lines.length) {
                    allPassed = false;
                    String detail = run.exitCode() != 0
                            ? cleanPaths(firstNonBlankLine(run.stderr()), workDir)
                            : "the program exited before producing this case's output";
                    results.add(new SubmitResult.CaseResult(false, tc.input(), tc.expected(), null, "Runtime Error: " + detail));
                    continue;
                }
                String line = lines[i].trim();
                if (line.startsWith(ERROR_PREFIX)) {
                    allPassed = false;
                    results.add(new SubmitResult.CaseResult(false, tc.input(), tc.expected(), null, line.substring(ERROR_PREFIX.length())));
                    continue;
                }
                List<Integer> actual = parseCsvInts(line);
                boolean passed = actual.equals(tc.expected());
                if (!passed) allPassed = false;
                results.add(new SubmitResult.CaseResult(passed, tc.input(), tc.expected(), actual, null));
            }

            String verdict = allPassed ? "Accepted" : "Wrong Answer";
            return new SubmitResult(allPassed, verdict, null, elapsedMs, results);
        } catch (IOException e) {
            return new SubmitResult(false, "Error", e.getMessage(), 0, List.of());
        } finally {
            deleteRecursively(workDir);
        }
    }

    private List<Integer> parseCsvInts(String line) {
        List<Integer> out = new ArrayList<>();
        if (line.isEmpty()) return out;
        for (String part : line.split(",")) {
            out.add(Integer.parseInt(part.trim()));
        }
        return out;
    }

    private String firstNonBlankLine(String text) {
        for (String line : text.split("\n")) {
            if (!line.isBlank()) return line.trim();
        }
        return "process exited with a non-zero status";
    }

    /** Strips the ephemeral temp-dir prefix from compiler/runtime output so users only see relative paths. */
    private String cleanPaths(String text, Path workDir) {
        return text.replace(workDir.toString() + File.separator, "").replace(workDir.toString(), "").trim();
    }

    private record ProcessResult(int exitCode, String stdout, String stderr, boolean timedOut) {
    }

    private ProcessResult runProcess(List<String> command, Path workDir, String stdin, long timeoutMs) throws IOException {
        ProcessBuilder pb = new ProcessBuilder(command).directory(workDir.toFile());
        pb.environment().clear();
        Process process = pb.start();

        if (stdin != null) {
            try (OutputStream os = process.getOutputStream()) {
                os.write(stdin.getBytes(StandardCharsets.UTF_8));
            }
        } else {
            process.getOutputStream().close();
        }

        ByteArrayOutputStream outBuf = new ByteArrayOutputStream();
        ByteArrayOutputStream errBuf = new ByteArrayOutputStream();
        Thread outT = new Thread(() -> copyQuietly(process.getInputStream(), outBuf));
        Thread errT = new Thread(() -> copyQuietly(process.getErrorStream(), errBuf));
        outT.setDaemon(true);
        errT.setDaemon(true);
        outT.start();
        errT.start();

        boolean finished;
        try {
            finished = process.waitFor(timeoutMs, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            process.destroyForcibly();
            finished = false;
        }

        if (!finished) {
            process.destroyForcibly();
            joinQuietly(outT);
            joinQuietly(errT);
            return new ProcessResult(-1, outBuf.toString(StandardCharsets.UTF_8), errBuf.toString(StandardCharsets.UTF_8), true);
        }

        joinQuietly(outT);
        joinQuietly(errT);
        return new ProcessResult(process.exitValue(), outBuf.toString(StandardCharsets.UTF_8), errBuf.toString(StandardCharsets.UTF_8), false);
    }

    private void copyQuietly(InputStream in, ByteArrayOutputStream out) {
        try {
            in.transferTo(out);
        } catch (IOException ignored) {
            // stream closed because the process was killed - fine, we already have what we need
        }
    }

    private void joinQuietly(Thread t) {
        try {
            t.join(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void deleteRecursively(Path dir) {
        try (var walk = Files.walk(dir)) {
            walk.sorted(Comparator.reverseOrder()).forEach(p -> {
                try {
                    Files.deleteIfExists(p);
                } catch (IOException ignored) {
                }
            });
        } catch (IOException ignored) {
            // best-effort cleanup
        }
    }
}
