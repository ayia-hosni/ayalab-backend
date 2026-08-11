-- Structured visual builder spec (JSON), stored alongside the rendered HTML in `visual`.
-- Null for slides authored before the builder existed (they keep working via raw HTML editing).
ALTER TABLE lesson_slides ADD COLUMN visual_spec TEXT;
