-- LeetCode 203: Remove Linked List Elements.
-- Content-only problem page (no visualizer_type, no problem_test_cases) — the
-- Run/Submit judge is currently hardcoded to reverseList(head) and does not yet
-- support arbitrary function signatures like removeElements(head, val).

INSERT INTO problems (id, title, slug, acceptance, difficulty, status, description, visualizer_type, available)
VALUES (203, 'Remove Linked List Elements', 'remove-linked-list-elements', 51.2, 'EASY', 'TODO', $desc$<p>Given the <code>head</code> of a linked list and an integer <code>val</code>, remove all the nodes of the linked list that has <code>Node.val == val</code>, and return the new head.</p>
<h4>Example 1</h4>
<p>Input: head = [1, 2, 6, 3, 4, 5, 6], val = 6<br>Output: [1, 2, 3, 4, 5]</p>
<h4>Example 2</h4>
<p>Input: head = [], val = 1<br>Output: []</p>
<h4>Example 3</h4>
<p>Input: head = [7, 7, 7, 7], val = 7<br>Output: []</p>
<h4>Constraints</h4>
<p>The number of nodes is in the range [0, 10<sup>4</sup>]. 1 &lt;= Node.val &lt;= 50. 0 &lt;= val &lt;= 50.</p>
<h4>Approach</h4>
<p>Use a dummy node plus two pointers so deleting the head needs no special case.</p>
<p>Point <code>dummy.next</code> at <code>head</code> so the real head always has a node in front of it — this removes the need for an "is this the head?" branch. <code>prev</code> starts at <code>dummy</code> and tracks the last node that was kept; <code>curr</code> walks the list inspecting each node in turn.</p>
<p>At each step, save <code>curr.next</code> as <code>nxt</code> before touching any pointers, so the rest of the list is never lost. If <code>curr.val === val</code>, bypass the node by setting <code>prev.next = nxt</code> and leave <code>prev</code> where it is — the next node still needs to attach to that same <code>prev</code>. Otherwise the node is kept, so <code>prev</code> advances to <code>curr</code>. Either way, <code>curr</code> then moves to <code>nxt</code>.</p>
<p>Return <code>dummy.next</code> — it always points to the true head, whether or not the original head was deleted.</p>
<h4>Complexity</h4>
<p>Time O(n) · Space O(1)</p>
<p>Every node is visited exactly once, and only a constant number of extra pointers (<code>dummy</code>, <code>prev</code>, <code>curr</code>, <code>nxt</code>) are used.</p>$desc$, NULL, TRUE);

INSERT INTO problem_tags (problem_id, tag) VALUES (203, 'Linked List');
INSERT INTO problem_tags (problem_id, tag) VALUES (203, 'Recursion');

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (203, 'javascript', $code$/**
 * Definition for singly-linked list.
 * function ListNode(val, next) {
 *   this.val = (val === undefined ? 0 : val);
 *   this.next = (next === undefined ? null : next);
 * }
 */
function removeElements(head, val) {
  const dummy = new ListNode(0, head);
  let prev = dummy;
  let curr = head;

  while (curr !== null) {
    const nxt = curr.next;

    if (curr.val === val) {
      prev.next = nxt;
    } else {
      prev = curr;
    }

    curr = nxt;
  }

  return dummy.next;
}$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (203, 'python', $code$# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

class Solution:
    def removeElements(self, head: ListNode, val: int) -> ListNode:
        # Create a dummy node that points to the head
        dummy = ListNode(next=head)

        # Initialize the previous and current pointers
        prev, curr = dummy, head

        # Iterate through the list
        while curr:
            # Store the next node
            nxt = curr.next

            # If the current value matches the target value to be deleted
            if curr.val == val:
                prev.next = nxt  # Bypass the current node
            else:
                prev = curr  # Shift the previous pointer forward

            # Shift the current pointer to the next node
            curr = nxt

        # Return the new head
        return dummy.next$code$);

INSERT INTO problem_starter_code (problem_id, language, code) VALUES (203, 'java', $code$/**
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
    public ListNode removeElements(ListNode head, int val) {
        ListNode dummy = new ListNode(0, head);
        ListNode prev = dummy;
        ListNode curr = head;

        while (curr != null) {
            ListNode nxt = curr.next;

            if (curr.val == val) {
                prev.next = nxt;
            } else {
                prev = curr;
            }

            curr = nxt;
        }

        return dummy.next;
    }
}$code$);
