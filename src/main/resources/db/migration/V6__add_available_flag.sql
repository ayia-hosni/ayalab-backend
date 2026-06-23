-- Mark which problems are fully implemented and accessible.
-- Default FALSE so existing placeholder rows are hidden until ready.
ALTER TABLE problems ADD COLUMN available BOOLEAN NOT NULL DEFAULT FALSE;

-- Only Reverse Linked List (206) has a real description, starter code, and test cases.
UPDATE problems SET available = TRUE WHERE id = 206;
