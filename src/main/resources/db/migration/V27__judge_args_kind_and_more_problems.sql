-- Judge specs gain an argument kind (so problems taking a list + int, or just an int, can be judged)
-- and an INT result kind. Enables Remove Linked List Elements (203) and Fibonacci Number (509).

ALTER TABLE problems ADD COLUMN judge_args_kind VARCHAR(16);
UPDATE problems SET judge_args_kind = 'LIST' WHERE judge_method IS NOT NULL;

ALTER TABLE problems
    DROP CONSTRAINT chk_problems_judge_result_kind,
    DROP CONSTRAINT chk_problems_judge_complete,
    ADD CONSTRAINT chk_problems_judge_args_kind   CHECK (judge_args_kind   IN ('LIST', 'LIST_AND_INT', 'INT')),
    ADD CONSTRAINT chk_problems_judge_result_kind CHECK (judge_result_kind IN ('LIST', 'BOOLEAN', 'INT')),
    ADD CONSTRAINT chk_problems_judge_complete CHECK (
        (judge_method IS NULL AND judge_args_kind IS NULL AND judge_result_kind IS NULL)
     OR (judge_method IS NOT NULL AND judge_args_kind IS NOT NULL AND judge_result_kind IS NOT NULL));

UPDATE problems SET judge_method = 'removeElements', judge_args_kind = 'LIST_AND_INT', judge_result_kind = 'LIST'
WHERE slug = 'remove-linked-list-elements';
UPDATE problems SET judge_method = 'fib', judge_args_kind = 'INT', judge_result_kind = 'INT'
WHERE slug = 'fibonacci-number';

-- Remove Linked List Elements (LeetCode 203): input is [list, val]. Samples mirror the three examples.
INSERT INTO problem_test_cases (problem_id, ordinal, is_sample, input_json, output_json)
SELECT p.id, v.ordinal, v.is_sample, v.input_json, v.output_json
FROM problems p, (VALUES
  (1, TRUE,  '[[1,2,6,3,4,5,6],6]', '[1,2,3,4,5]'),
  (2, TRUE,  '[[],1]',              '[]'),
  (3, TRUE,  '[[7,7,7,7],7]',       '[]'),
  (4, FALSE, '[[1,2,3],4]',         '[1,2,3]'),
  (5, FALSE, '[[6,1,2],6]',         '[1,2]'),
  (6, FALSE, '[[1,2,6],6]',         '[1,2]'),
  (7, FALSE, '[[5],5]',             '[]'),
  (8, FALSE, '[[1,1,2,1],1]',       '[2]')
) AS v(ordinal, is_sample, input_json, output_json)
WHERE p.slug = 'remove-linked-list-elements';

-- Fibonacci Number (LeetCode 509): 0 <= n <= 30. Samples mirror the two examples.
INSERT INTO problem_test_cases (problem_id, ordinal, is_sample, input_json, output_json)
SELECT p.id, v.ordinal, v.is_sample, v.input_json, v.output_json
FROM problems p, (VALUES
  (1, TRUE,  '2',  '1'),
  (2, TRUE,  '4',  '3'),
  (3, FALSE, '0',  '0'),
  (4, FALSE, '1',  '1'),
  (5, FALSE, '3',  '2'),
  (6, FALSE, '5',  '5'),
  (7, FALSE, '10', '55'),
  (8, FALSE, '20', '6765'),
  (9, FALSE, '30', '832040')
) AS v(ordinal, is_sample, input_json, output_json)
WHERE p.slug = 'fibonacci-number';
