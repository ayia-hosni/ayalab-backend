-- LeetCode 509: Fibonacci Number.
-- Content + starter code, no problem_test_cases — same tradeoff already documented in
-- V15__seed_palindrome_linked_list.sql: the Run/Submit judge is currently hardcoded to
-- reverseList(head) on a linked list and does not yet support arbitrary function
-- signatures like fib(n). Solution tab is for reading/reference; the interactive value
-- of this problem lives in the three visualizer tabs below.

INSERT INTO problems (id, title, slug, acceptance, difficulty, status, description, visualizer_type, available)
VALUES (509, 'Fibonacci Number', 'fibonacci-number', 68.4, 'EASY', 'TODO', $desc$<p>The <strong>Fibonacci numbers</strong>, commonly denoted <code>F(n)</code>, form a sequence such that each number is the sum of the two preceding ones, starting from <code>0</code> and <code>1</code>. That is,</p>
<p><code>F(0) = 0, F(1) = 1</code><br><code>F(n) = F(n - 1) + F(n - 2)</code>, for <code>n &gt; 1</code>.</p>
<p>Given <code>n</code>, calculate <code>F(n)</code>.</p>
<h4>Example 1</h4>
<p>Input: n = 2<br>Output: 1<br>Explanation: F(2) = F(1) + F(0) = 1 + 0 = 1.</p>
<h4>Example 2</h4>
<p>Input: n = 4<br>Output: 3<br>Explanation: F(4) = F(3) + F(2) = 2 + 1 = 3.</p>
<h4>Constraints</h4>
<p>0 &lt;= n &lt;= 30.</p>
<h4>Approach 1: Naive Recursion</h4>
<p>The recurrence translates directly into code: <code>fib(n)</code> returns <code>n</code> for the base cases, otherwise <code>fib(n - 1) + fib(n - 2)</code>. It's correct, but it recomputes the same subproblems over and over — <code>fib(5)</code> calls <code>fib(3)</code> twice, <code>fib(2)</code> three times, and so on, doubling roughly every time <code>n</code> grows by one.</p>
<h4>Complexity</h4>
<p>Time O(2<sup>n</sup>) · Space O(n) for the call stack.</p>
<h4>Approach 2: Top-Down Memoization</h4>
<p>Same recursion, but the first time <code>fib(i)</code> is computed its result is stored in a cache. Every later call for that same <code>i</code> becomes a single lookup instead of a re-computation, collapsing the exponential tree down to one branch per distinct <code>i</code>.</p>
<h4>Complexity</h4>
<p>Time O(n) · Space O(n) for the cache and the call stack.</p>
<h4>Approach 3: Bottom-Up Tabulation</h4>
<p>Instead of starting from <code>fib(n)</code> and recursing down, start from the base cases and build up: compute <code>F(2)</code>, then <code>F(3)</code>, ..., up to <code>F(n)</code>, each time reusing the two values just computed. Since only the last two values are ever needed, they can be tracked in two rolling variables instead of a full array — no recursion, no cache.</p>
<h4>Complexity</h4>
<p>Time O(n) · Space O(1).</p>$desc$, 'DP_TRACE', TRUE);

INSERT INTO problem_tags (problem_id, tag) VALUES (509, 'Math');
INSERT INTO problem_tags (problem_id, tag) VALUES (509, 'Dynamic Programming');
INSERT INTO problem_tags (problem_id, tag) VALUES (509, 'Recursion');
INSERT INTO problem_tags (problem_id, tag) VALUES (509, 'Memoization');

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (509, 'javascript', $code$/**
 * Bottom-up tabulation with two rolling variables — O(n) time, O(1) space.
 */
function fib(n) {
  if (n < 2) return n;

  let prev2 = 0;
  let prev1 = 1;

  for (let i = 2; i <= n; i++) {
    const curr = prev1 + prev2;
    prev2 = prev1;
    prev1 = curr;
  }

  return prev1;
}$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (509, 'python', $code$class Solution:
    # Bottom-up tabulation with two rolling variables — O(n) time, O(1) space.
    def fib(self, n: int) -> int:
        if n < 2:
            return n

        prev2, prev1 = 0, 1
        for _ in range(2, n + 1):
            prev2, prev1 = prev1, prev1 + prev2

        return prev1$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (509, 'java', $code$class Solution {
    // Bottom-up tabulation with two rolling variables — O(n) time, O(1) space.
    public int fib(int n) {
        if (n < 2) return n;

        int prev2 = 0;
        int prev1 = 1;

        for (int i = 2; i <= n; i++) {
            int curr = prev1 + prev2;
            prev2 = prev1;
            prev1 = curr;
        }

        return prev1;
    }
}$code$);
