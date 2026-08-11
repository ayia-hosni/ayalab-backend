-- Lessons had no grouping concept at all — one flat, ordinal-sorted list under
-- a single implicit topic. Adds a section (required — the topic group, e.g.
-- "Linked Lists") and an optional category (a sub-tag within that section,
-- e.g. "Fundamentals" / "Insertion"), bilingual like every other lesson field.
-- Denormalized onto each lesson row rather than a separate sections table,
-- matching how this schema already works (title_en/title_ar per row, no
-- lookup tables anywhere) — the lesson catalogue is small enough that this
-- is simpler to manage from the admin panel than a normalized join.

ALTER TABLE lessons ADD COLUMN section_en TEXT;
ALTER TABLE lessons ADD COLUMN section_ar TEXT;
ALTER TABLE lessons ADD COLUMN category_en TEXT;
ALTER TABLE lessons ADD COLUMN category_ar TEXT;

-- Backfill every existing linked-list lesson into one section, split into
-- categories by what each lesson actually teaches. Covers all lessons present
-- as of this migration, not just the ones seeded by earlier migration files
-- (id 3, "Find (Search)", was added later straight through the admin panel).
UPDATE lessons SET section_en = 'Linked Lists', section_ar = 'القوائم المرتبطة',
                    category_en = 'Fundamentals', category_ar = 'الأساسيات'
WHERE id IN (1, 2, 3);

UPDATE lessons SET section_en = 'Linked Lists', section_ar = 'القوائم المرتبطة',
                    category_en = 'Insertion', category_ar = 'الإضافة'
WHERE id IN (4, 5);

-- Catch-all in case other lessons exist beyond the ones enumerated above
-- (e.g. added through the admin panel after this migration was written) —
-- without this, the NOT NULL constraint below would fail the whole migration.
UPDATE lessons SET section_en = 'Linked Lists', section_ar = 'القوائم المرتبطة'
WHERE section_en IS NULL;

ALTER TABLE lessons ALTER COLUMN section_en SET NOT NULL;
ALTER TABLE lessons ALTER COLUMN section_ar SET NOT NULL;
