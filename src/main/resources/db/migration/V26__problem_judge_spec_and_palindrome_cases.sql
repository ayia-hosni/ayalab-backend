-- The judge was hard-wired to reverseList. Give each problem its own entry method and result kind
-- so other linked-list problems can be judged, then enable it for Palindrome Linked List.

ALTER TABLE problems
    ADD COLUMN judge_method      VARCHAR(64),
    ADD COLUMN judge_result_kind VARCHAR(16),
    ADD CONSTRAINT chk_problems_judge_result_kind CHECK (judge_result_kind IN ('LIST', 'BOOLEAN')),
    ADD CONSTRAINT chk_problems_judge_complete CHECK ((judge_method IS NULL) = (judge_result_kind IS NULL));

UPDATE problems SET judge_method = 'reverseList',  judge_result_kind = 'LIST'    WHERE slug = 'reverse-linked-list';
UPDATE problems SET judge_method = 'isPalindrome', judge_result_kind = 'BOOLEAN' WHERE slug = 'palindrome-linked-list';

-- Palindrome Linked List (LeetCode 234): 1..10^5 nodes, values 0..9. Samples mirror the examples.
INSERT INTO problem_test_cases (problem_id, ordinal, is_sample, input_json, output_json)
SELECT p.id, v.ordinal, v.is_sample, v.input_json, v.output_json
FROM problems p, (VALUES
  (1, TRUE,  '[1,2,2,1]',   'true'),
  (2, TRUE,  '[1,2]',       'false'),
  (3, FALSE, '[1]',         'true'),
  (4, FALSE, '[1,2,3,2,1]', 'true'),
  (5, FALSE, '[1,2,3,4,5]', 'false'),
  (6, FALSE, '[1,0,1]',     'true'),
  (7, FALSE, '[1,1,2,1]',   'false')
) AS v(ordinal, is_sample, input_json, output_json)
WHERE p.slug = 'palindrome-linked-list';
