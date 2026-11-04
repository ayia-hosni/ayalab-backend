package com.ayalab.judge;

import com.ayalab.dto.SubmitResult;
import com.ayalab.judge.JudgeSpec.ArgsKind;
import com.ayalab.judge.JudgeSpec.ResultKind;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIf;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Runs the real judges (javac in a subprocess, GraalVM JS in-process) for both result kinds. The JS
 * tests skip on a JDK GraalVM 23.x can't initialise on (e.g. JDK 26); the project targets JDK 17.
 */
class JudgesTest {

    private final JavaJudge java = new JavaJudge();
    private final JavaScriptJudge js = new JavaScriptJudge();

    private static final JudgeSpec REVERSE = new JudgeSpec("reverseList", ArgsKind.LIST, ResultKind.LIST);
    private static final JudgeSpec PALINDROME = new JudgeSpec("isPalindrome", ArgsKind.LIST, ResultKind.BOOLEAN);

    private static final List<TestCase> REVERSE_CASES = List.of(
            new TestCase(List.of(1, 2, 3), List.of(3, 2, 1)),
            new TestCase(List.of(), List.of()),
            new TestCase(List.of(7), List.of(7)));

    private static final List<TestCase> PALINDROME_CASES = List.of(
            new TestCase(List.of(1, 2, 2, 1), true),
            new TestCase(List.of(1, 2), false),
            new TestCase(List.of(1), true),
            new TestCase(List.of(1, 2, 3, 2, 1), true),
            new TestCase(List.of(1, 1, 2, 1), false));

    private static final JudgeSpec REMOVE = new JudgeSpec("removeElements", ArgsKind.LIST_AND_INT, ResultKind.LIST);
    private static final JudgeSpec FIB = new JudgeSpec("fib", ArgsKind.INT, ResultKind.INT);

    private static final List<TestCase> REMOVE_CASES = List.of(
            new TestCase(List.of(List.of(1, 2, 6, 3, 4, 5, 6), 6), List.of(1, 2, 3, 4, 5)),
            new TestCase(List.of(List.of(), 1), List.of()),
            new TestCase(List.of(List.of(7, 7, 7, 7), 7), List.of()),
            new TestCase(List.of(List.of(1, 1, 2, 1), 1), List.of(2)));

    private static final List<TestCase> FIB_CASES = List.of(
            new TestCase(0, 0), new TestCase(1, 1), new TestCase(2, 1),
            new TestCase(10, 55), new TestCase(30, 832040));

    // ── Java ────────────────────────────────────────────────────────────────

    private static final String JAVA_REVERSE = """
            class Solution { public ListNode reverseList(ListNode head) {
                ListNode prev = null;
                while (head != null) { ListNode n = head.next; head.next = prev; prev = head; head = n; }
                return prev; } }""";

    private static final String JAVA_PALINDROME = """
            class Solution { public boolean isPalindrome(ListNode head) {
                java.util.List<Integer> v = new java.util.ArrayList<>();
                for (ListNode c = head; c != null; c = c.next) v.add(c.val);
                for (int i = 0, j = v.size() - 1; i < j; i++, j--) if (!v.get(i).equals(v.get(j))) return false;
                return true; } }""";

    @Test
    void javaReverseStillAccepted() {
        SubmitResult r = java.run(JAVA_REVERSE, REVERSE, REVERSE_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.accepted()).isTrue();
    }

    @Test
    void javaPalindromeAcceptedAndReportsBooleans() {
        SubmitResult r = java.run(JAVA_PALINDROME, PALINDROME, PALINDROME_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.cases()).extracting(SubmitResult.CaseResult::actual).containsExactly(true, false, true, true, false);
    }

    @Test
    void javaPalindromeWrongAnswerShowsExpectedAndActual() {
        String alwaysTrue = "class Solution { public boolean isPalindrome(ListNode head) { return true; } }";
        SubmitResult r = java.run(alwaysTrue, PALINDROME, PALINDROME_CASES);
        assertThat(r.verdict()).isEqualTo("Wrong Answer");
        SubmitResult.CaseResult failed = r.cases().get(1);
        assertThat(failed.passed()).isFalse();
        assertThat(failed.expected()).isEqualTo(false);
        assertThat(failed.actual()).isEqualTo(true);
    }

    @Test
    void javaMissingMethodIsACompileError() {
        SubmitResult r = java.run(JAVA_REVERSE, PALINDROME, PALINDROME_CASES);
        assertThat(r.verdict()).isEqualTo("Compile Error");
        assertThat(r.compileError()).contains("isPalindrome");
    }

    private static final String JAVA_REMOVE = """
            class Solution { public ListNode removeElements(ListNode head, int val) {
                ListNode dummy = new ListNode(0, head), prev = dummy;
                for (ListNode c = head; c != null; c = c.next) { if (c.val == val) prev.next = c.next; else prev = c; }
                return dummy.next; } }""";

    private static final String JAVA_FIB = """
            class Solution { public int fib(int n) { if (n < 2) return n; int a = 0, b = 1;
                for (int i = 2; i <= n; i++) { int c = a + b; a = b; b = c; } return b; } }""";

    @Test
    void javaRemoveElementsTakesAListAndAnInt() {
        SubmitResult r = java.run(JAVA_REMOVE, REMOVE, REMOVE_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.cases().get(0).input()).isEqualTo(List.of(List.of(1, 2, 6, 3, 4, 5, 6), 6));
        assertThat(r.cases().get(0).actual()).isEqualTo(List.of(1, 2, 3, 4, 5));
    }

    @Test
    void javaRemoveElementsWrongAnswerIsCaught() {
        String ignoresVal = "class Solution { public ListNode removeElements(ListNode head, int val) { return head; } }";
        assertThat(java.run(ignoresVal, REMOVE, REMOVE_CASES).verdict()).isEqualTo("Wrong Answer");
    }

    @Test
    void javaFibonacciTakesAndReturnsAnInt() {
        SubmitResult r = java.run(JAVA_FIB, FIB, FIB_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.cases()).extracting(SubmitResult.CaseResult::actual).containsExactly(0, 1, 1, 55, 832040);
        String wrong = "class Solution { public int fib(int n) { return n; } }";
        SubmitResult w = java.run(wrong, FIB, FIB_CASES);
        assertThat(w.verdict()).isEqualTo("Wrong Answer");
        assertThat(w.cases().get(3).expected()).isEqualTo(55);
        assertThat(w.cases().get(3).actual()).isEqualTo(10);
    }

    // ── JavaScript ──────────────────────────────────────────────────────────

    static boolean graalAvailable() {
        try (var ctx = org.graalvm.polyglot.Context.newBuilder("js").option("engine.WarnInterpreterOnly", "false").build()) {
            return ctx.eval("js", "1 + 1").asInt() == 2;
        } catch (Throwable t) {
            return false;
        }
    }

    private static final String JS_REVERSE = """
            function reverseList(head) {
              let prev = null;
              while (head) { const n = head.next; head.next = prev; prev = head; head = n; }
              return prev;
            }""";

    private static final String JS_PALINDROME = """
            function isPalindrome(head) {
              const v = [];
              for (let c = head; c; c = c.next) v.push(c.val);
              return v.every((x, i) => x === v[v.length - 1 - i]);
            }""";

    @Test
    @EnabledIf("graalAvailable")
    void jsReverseStillAccepted() {
        assertThat(js.run(JS_REVERSE, REVERSE, REVERSE_CASES).verdict()).isEqualTo("Accepted");
    }

    @Test
    @EnabledIf("graalAvailable")
    void jsPalindromeAccepted() {
        SubmitResult r = js.run(JS_PALINDROME, PALINDROME, PALINDROME_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.cases()).extracting(SubmitResult.CaseResult::actual).containsExactly(true, false, true, true, false);
    }

    @Test
    @EnabledIf("graalAvailable")
    void jsPalindromeWrongAnswer() {
        SubmitResult r = js.run("function isPalindrome(head) { return false; }", PALINDROME, PALINDROME_CASES);
        assertThat(r.verdict()).isEqualTo("Wrong Answer");
        assertThat(r.cases().get(0).expected()).isEqualTo(true);
        assertThat(r.cases().get(0).actual()).isEqualTo(false);
    }

    @Test
    @EnabledIf("graalAvailable")
    void jsMustReturnARealBoolean() {
        SubmitResult r = js.run("function isPalindrome(head) { return 1; }", PALINDROME, PALINDROME_CASES);
        assertThat(r.accepted()).isFalse();
        assertThat(r.cases().get(0).error()).contains("must return true or false");
    }

    @Test
    @EnabledIf("graalAvailable")
    void jsMissingFunctionFailsEveryCaseWithAReadableError() {
        SubmitResult r = js.run(JS_REVERSE, PALINDROME, PALINDROME_CASES);
        assertThat(r.accepted()).isFalse();
        assertThat(r.cases()).allSatisfy(c -> assertThat(c.error()).contains("isPalindrome"));
    }

    private static final String JS_REMOVE = """
            function removeElements(head, val) {
              const dummy = new ListNode(0, head); let prev = dummy;
              for (let c = head; c !== null; c = c.next) { if (c.val === val) prev.next = c.next; else prev = c; }
              return dummy.next;
            }""";

    private static final String JS_FIB = """
            function fib(n) { if (n < 2) return n; let a = 0, b = 1;
              for (let i = 2; i <= n; i++) { const c = a + b; a = b; b = c; } return b; }""";

    @Test
    @EnabledIf("graalAvailable")
    void jsRemoveElementsTakesAListAndAnInt() {
        assertThat(js.run(JS_REMOVE, REMOVE, REMOVE_CASES).verdict()).isEqualTo("Accepted");
        String ignoresVal = "function removeElements(head, val) { return head; }";
        assertThat(js.run(ignoresVal, REMOVE, REMOVE_CASES).verdict()).isEqualTo("Wrong Answer");
    }

    @Test
    @EnabledIf("graalAvailable")
    void jsFibonacciReturnsAnInt() {
        SubmitResult r = js.run(JS_FIB, FIB, FIB_CASES);
        assertThat(r.verdict()).isEqualTo("Accepted");
        assertThat(r.cases()).extracting(SubmitResult.CaseResult::actual).containsExactly(0, 1, 1, 55, 832040);
        SubmitResult notInt = js.run("function fib(n) { return 'x'; }", FIB, FIB_CASES);
        assertThat(notInt.cases().get(0).error()).contains("must return an integer");
    }
}
