-- ─────────────────────────────────────────────────────────────────────────────
-- V4: Scalability & design improvements
--
--  1. problem_starter_code  – replaces the opaque JSON blob in problems.starter_code
--  2. visualizer_type       – replaces the boolean has_visualizer flag
--  3. problem_test_cases    – moves hardcoded test cases out of Java and into the DB
--  4. Audit timestamps on problems
-- ─────────────────────────────────────────────────────────────────────────────


-- ── 1. Starter code ──────────────────────────────────────────────────────────
-- One row per (problem, language). Keeps code queryable and avoids JSON parsing
-- in the application layer for every detail page load.

CREATE TABLE problem_starter_code (
    problem_id  BIGINT      NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    language    VARCHAR(32) NOT NULL,   -- 'javascript' | 'python' | 'java' | …
    code        TEXT        NOT NULL,
    PRIMARY KEY (problem_id, language)
);

-- Migrate the single existing JSON blob (problem 206 only).
-- jsonb_each_text unpacks {"javascript":"…","python":"…","java":"…"} into rows.
INSERT INTO problem_starter_code (problem_id, language, code)
SELECT p.id, kv.key, kv.value
FROM   problems p,
       jsonb_each_text(p.starter_code::jsonb) AS kv
WHERE  p.starter_code IS NOT NULL;

ALTER TABLE problems DROP COLUMN starter_code;


-- ── 2. Visualizer type ───────────────────────────────────────────────────────
-- A string enum is open for extension (e.g. 'DP_TABLE', 'GRAPH_BFS') without
-- a schema change. NULL means no interactive visualizer.

ALTER TABLE problems ADD COLUMN visualizer_type VARCHAR(64);
UPDATE problems SET visualizer_type = 'POINTER_TRACE' WHERE has_visualizer = TRUE;
ALTER TABLE problems DROP COLUMN has_visualizer;

CREATE INDEX idx_problems_visualizer_type
    ON problems (visualizer_type)
    WHERE visualizer_type IS NOT NULL;


-- ── 3. Test cases ────────────────────────────────────────────────────────────
-- input_json / output_json store the problem's native input contract as JSON so
-- the schema works for any problem, not just linked-list reversal.
-- is_sample = TRUE  → shown as examples on the problem page / "Run Tests" mode
-- is_sample = FALSE → hidden; used only by the judge on "Submit"

CREATE TABLE problem_test_cases (
    id           BIGSERIAL NOT NULL PRIMARY KEY,
    problem_id   BIGINT    NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    ordinal      SMALLINT  NOT NULL,
    is_sample    BOOLEAN   NOT NULL DEFAULT FALSE,
    input_json   TEXT      NOT NULL,
    output_json  TEXT      NOT NULL
);

CREATE INDEX idx_test_cases_problem_ordinal ON problem_test_cases (problem_id, ordinal);

-- Seed: Reverse Linked List (problem 206) – previously hardcoded in SubmissionService.java
INSERT INTO problem_test_cases (problem_id, ordinal, is_sample, input_json, output_json) VALUES
    (206, 1, TRUE,  '[1,2,3,4,5]', '[5,4,3,2,1]'),
    (206, 2, TRUE,  '[1,2]',       '[2,1]'),
    (206, 3, FALSE, '[]',          '[]'),
    (206, 4, FALSE, '[7]',         '[7]'),
    (206, 5, FALSE, '[-3,0,9,-1]', '[-1,9,0,-3]');


-- ── 4. Audit timestamps ───────────────────────────────────────────────────────
ALTER TABLE problems ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE problems ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();