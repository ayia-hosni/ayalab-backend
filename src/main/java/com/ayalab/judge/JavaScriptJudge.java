package com.ayalab.judge;

import com.ayalab.dto.SubmitResult;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Value;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Executes a user-supplied JavaScript function (named by the {@link JudgeSpec}) that
 * takes a linked-list head, against a list of test cases.
 *
 * <p>The user code runs inside a locked-down GraalVM polyglot context: no host
 * access, no IO, no threads. Each run is additionally guarded by a wall-clock
 * timeout so an accidental infinite loop cannot hang the server.</p>
 */
@Component
public class JavaScriptJudge {

    private static final long TIMEOUT_MS = 4000;

    /**
     * A small JS harness that defines a ListNode, converts arrays to/from linked
     * lists, invokes the user's function, and returns its result (an array or a boolean).
     * The user code is injected where indicated, via plain concatenation (never
     * String.format/.formatted) so a stray '%' in the user's own code or
     * comments can never be misread as a format specifier.
     */
    private static final String HARNESS_PREFIX = """
            function ListNode(val, next) {
              this.val = (val === undefined ? 0 : val);
              this.next = (next === undefined ? null : next);
            }
            function __fromArray(a) {
              let dummy = new ListNode(0), t = dummy;
              for (const v of a) { t.next = new ListNode(v); t = t.next; }
              return dummy.next;
            }
            function __toArray(h) {
              const out = []; let guard = 0;
              while (h) { out.push(h.val); if (++guard > 100000) break; h = h.next; }
              return out;
            }

            // ===== user code begins =====
            """;

    private static final String HARNESS_SUFFIX = """

            // ===== user code ends =====

            // Bridge invoked from Java with the input as a JSON array string. Passing a string (rather than
            // a Java array) keeps the sandbox free of host-object interop, which isn't iterable here.
            function __run(json) {
              const input = JSON.parse(json);
              const res = __METHOD__(__ARGS__);
              return __RESULT__;
            }
            """;

    public SubmitResult run(String userCode, JudgeSpec spec, List<TestCase> cases) {
        String args = switch (spec.args()) {
            case LIST -> "__fromArray(input)";
            case LIST_AND_INT -> "__fromArray(input[0]), input[1]";
            case INT -> "input";
        };
        String result = spec.result() == JudgeSpec.ResultKind.LIST ? "__toArray(res)" : "res";
        String source = HARNESS_PREFIX + userCode
                + HARNESS_SUFFIX.replace("__METHOD__", spec.method()).replace("__ARGS__", args).replace("__RESULT__", result);
        long start = System.nanoTime();

        ExecutorService executor = Executors.newSingleThreadExecutor();
        try {
            // Compile (parse + eval) on the worker thread, guarded by a timeout.
            Future<Context> compileFuture = executor.submit(() -> {
                Context context = newContext();
                context.eval("js", source); // may throw PolyglotException
                return context;
            });

            Context context;
            try {
                context = compileFuture.get(TIMEOUT_MS, TimeUnit.MILLISECONDS);
            } catch (Exception e) {
                Throwable cause = e.getCause() != null ? e.getCause() : e;
                return new SubmitResult(false, "Compile Error", cleanMessage(cause), 0, List.of());
            }

            Value run = context.getBindings("js").getMember("__run");
            if (run == null || !run.canExecute()) {
                context.close(true);
                return new SubmitResult(false, "Compile Error",
                        spec.method() + " is not defined as a function", 0, List.of());
            }

            List<SubmitResult.CaseResult> results = new ArrayList<>();
            boolean allPassed = true;
            for (TestCase tc : cases) {
                CaseOutcome outcome = runCase(executor, run, spec, tc);
                results.add(outcome.result());
                if (!outcome.result().passed()) {
                    allPassed = false;
                }
            }

            // Close the context on the worker thread that created it.
            try {
                executor.submit(() -> { context.close(true); return null; })
                        .get(2, TimeUnit.SECONDS);
            } catch (Exception ignored) {
                // best-effort cleanup
            }

            long elapsedMs = (System.nanoTime() - start) / 1_000_000;
            String verdict = allPassed ? "Accepted" : "Wrong Answer";
            return new SubmitResult(allPassed, verdict, null, elapsedMs, results);
        } finally {
            executor.shutdownNow();
        }
    }

    private CaseOutcome runCase(ExecutorService executor, Value run, JudgeSpec spec, TestCase tc) {
        Callable<Object> task = () -> {
            Value out = run.execute(tc.input().toString());
            if (spec.result() == JudgeSpec.ResultKind.BOOLEAN) {
                if (!out.isBoolean()) throw new IllegalStateException(spec.method() + " must return true or false");
                return out.asBoolean();
            }
            if (spec.result() == JudgeSpec.ResultKind.INT) {
                if (!out.isNumber() || !out.fitsInInt()) throw new IllegalStateException(spec.method() + " must return an integer");
                return out.asInt();
            }
            List<Integer> actual = new ArrayList<>();
            for (long i = 0; i < out.getArraySize(); i++) {
                actual.add(out.getArrayElement(i).asInt());
            }
            return actual;
        };

        Future<Object> future = executor.submit(task);
        try {
            Object actual = future.get(TIMEOUT_MS, TimeUnit.MILLISECONDS);
            boolean passed = Objects.equals(actual, tc.expected());
            return new CaseOutcome(new SubmitResult.CaseResult(
                    passed, tc.input(), tc.expected(), actual, null));
        } catch (TimeoutException e) {
            future.cancel(true);
            return new CaseOutcome(new SubmitResult.CaseResult(
                    false, tc.input(), tc.expected(), null, "Time Limit Exceeded"));
        } catch (Exception e) {
            Throwable cause = e.getCause() != null ? e.getCause() : e;
            return new CaseOutcome(new SubmitResult.CaseResult(
                    false, tc.input(), tc.expected(), null, cleanMessage(cause)));
        }
    }

    private Context newContext() {
        // Locked down: only the JS language, no host access, no native access.
        // engine.WarnInterpreterOnly is disabled so running on a stock JDK (without
        // the GraalVM optimizing compiler) does not print a noisy startup warning.
        return Context.newBuilder("js")
                .allowAllAccess(false)
                .option("engine.WarnInterpreterOnly", "false")
                .build();
    }

    private String cleanMessage(Throwable t) {
        String msg = t.getMessage();
        return msg == null ? t.getClass().getSimpleName() : msg;
    }

    private record CaseOutcome(SubmitResult.CaseResult result) {
    }
}
