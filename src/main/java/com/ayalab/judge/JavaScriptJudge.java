package com.ayalab.judge;

import com.ayalab.dto.SubmitResult;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Value;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Executes a user-supplied JavaScript {@code reverseList(head)} implementation
 * against a list of test cases.
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
     * lists, invokes the user's reverseList, and returns the resulting array.
     * The user code is injected where indicated.
     */
    private static final String HARNESS = """
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
            %s
            // ===== user code ends =====

            // Bridge invoked from Java with a plain JS array of ints.
            function __run(arr) {
              const head = __fromArray(arr);
              const res = reverseList(head);
              return __toArray(res);
            }
            """;

    public SubmitResult run(String userCode, List<TestCase> cases) {
        String source = String.format(HARNESS, userCode);
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
                        "reverseList is not defined as a function", 0, List.of());
            }

            List<SubmitResult.CaseResult> results = new ArrayList<>();
            boolean allPassed = true;
            for (TestCase tc : cases) {
                CaseOutcome outcome = runCase(executor, run, tc);
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

    private CaseOutcome runCase(ExecutorService executor, Value run, TestCase tc) {
        Callable<List<Integer>> task = () -> {
            Value out = run.execute((Object) tc.input().toArray(new Integer[0]));
            List<Integer> actual = new ArrayList<>();
            for (long i = 0; i < out.getArraySize(); i++) {
                actual.add(out.getArrayElement(i).asInt());
            }
            return actual;
        };

        Future<List<Integer>> future = executor.submit(task);
        try {
            List<Integer> actual = future.get(TIMEOUT_MS, TimeUnit.MILLISECONDS);
            boolean passed = actual.equals(tc.expected());
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
