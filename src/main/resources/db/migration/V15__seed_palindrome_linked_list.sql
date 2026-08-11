-- LeetCode 234: Palindrome Linked List.
-- Content-only problem page (no visualizer_type, no problem_test_cases) — the
-- Run/Submit judge is currently hardcoded to reverseList(head) and does not yet
-- support arbitrary function signatures like isPalindrome(head).

INSERT INTO problems (id, title, slug, acceptance, difficulty, status, description, visualizer_type, available)
VALUES (234, 'Palindrome Linked List', 'palindrome-linked-list', 51.5, 'EASY', 'TODO', $desc$<p>Given the <code>head</code> of a singly linked list, return <code>true</code> if it is a palindrome (the sequence reads the same forwards and backwards) or <code>false</code> otherwise.</p>
<h4>Example 1</h4>
<p>Input: head = [1, 2, 2, 1]<br>Output: true</p>
<h4>Example 2</h4>
<p>Input: head = [1, 2]<br>Output: false</p>
<h4>Constraints</h4>
<p>The number of nodes is in the range [1, 10<sup>5</sup>]. 0 &lt;= Node.val &lt;= 9.</p>
<h4>Follow Up</h4>
<p>Could you do it in O(n) time and O(1) space?</p>
<h4>Approach 1: Using an Array</h4>
<p>Because linked lists only allow sequential access, checking for a palindrome directly is tricky. A simple workaround is to copy all the values from the linked list into a standard array. Once the values are in an array, we can use a standard two-pointer approach (one at the beginning, one at the end) to check if the array is a palindrome.</p>
<h4>Complexity</h4>
<p>Time O(n) · Space O(n)</p>
<p>O(n) to iterate through the linked list and copy its values, plus O(n) for the two pointers to scan the array. The extra array of size n is what makes this the non-optimal solution.</p>
<h4>Approach 2: Fast &amp; Slow Pointers (Optimal)</h4>
<p>The follow-up asks for O(n) time and O(1) space, without an extra array. This is done in three phases.</p>
<p><strong>Find the middle.</strong> Use a fast and slow pointer, both starting at <code>head</code>. <code>slow</code> moves one step at a time while <code>fast</code> moves two steps. By the time <code>fast</code> reaches the end of the list, <code>slow</code> is resting exactly at the middle.</p>
<p><strong>Reverse the second half.</strong> Starting from where <code>slow</code> paused, reverse the remaining half in place by tracking a <code>prev</code> node (initially <code>null</code>) and flipping the <code>next</code> pointers of the nodes in the second half to point backwards.</p>
<p><strong>Check for palindrome.</strong> Now there is a pointer at the very beginning of the list (<code>left = head</code>) and a pointer at the start of the reversed second half (<code>right = prev</code>). Walk them both one step at a time — if any values don't match, it isn't a palindrome. If the whole second half checks out, it is.</p>
<h4>Complexity</h4>
<p>Time O(n) · Space O(1)</p>
<p>The list is traversed a constant number of times (finding the middle, reversing the second half, comparing the two halves), and only a fixed number of extra pointers (<code>fast</code>, <code>slow</code>, <code>prev</code>, <code>tmp</code>, <code>left</code>, <code>right</code>) are used regardless of list size.</p>$desc$, NULL, TRUE);

INSERT INTO problem_tags (problem_id, tag) VALUES (234, 'Linked List');
INSERT INTO problem_tags (problem_id, tag) VALUES (234, 'Two Pointers');

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (234, 'javascript', $code$/**
 * Definition for singly-linked list.
 * function ListNode(val, next) {
 *   this.val = (val === undefined ? 0 : val);
 *   this.next = (next === undefined ? null : next);
 * }
 */
function isPalindrome(head) {
  let fast = head;
  let slow = head;

  // 1. Find middle (slow will be at the middle)
  while (fast !== null && fast.next !== null) {
    fast = fast.next.next;
    slow = slow.next;
  }

  // 2. Reverse second half
  let prev = null;
  while (slow !== null) {
    const tmp = slow.next;
    slow.next = prev;
    prev = slow;
    slow = tmp;
  }

  // 3. Check palindrome
  let left = head;
  let right = prev;
  while (right !== null) {
    if (left.val !== right.val) {
      return false;
    }
    left = left.next;
    right = right.next;
  }

  return true;
}$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (234, 'python', $code$# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

class Solution:
    def isPalindrome(self, head: ListNode) -> bool:
        fast = head
        slow = head

        # 1. Find middle (slow will be at the middle)
        while fast and fast.next:
            fast = fast.next.next
            slow = slow.next

        # 2. Reverse second half
        prev = None
        while slow:
            tmp = slow.next
            slow.next = prev
            prev = slow
            slow = tmp

        # 3. Check palindrome
        left, right = head, prev
        while right:
            if left.val != right.val:
                return False
            left = left.next
            right = right.next

        return True$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (234, 'java', $code$/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public boolean isPalindrome(ListNode head) {
        ListNode fast = head;
        ListNode slow = head;

        // 1. Find middle (slow will be at the middle)
        while (fast != null && fast.next != null) {
            fast = fast.next.next;
            slow = slow.next;
        }

        // 2. Reverse second half
        ListNode prev = null;
        while (slow != null) {
            ListNode tmp = slow.next;
            slow.next = prev;
            prev = slow;
            slow = tmp;
        }

        // 3. Check palindrome
        ListNode left = head;
        ListNode right = prev;
        while (right != null) {
            if (left.val != right.val) {
                return false;
            }
            left = left.next;
            right = right.next;
        }

        return true;
    }
}$code$);
