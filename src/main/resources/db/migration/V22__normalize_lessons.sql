-- Normalizes the lessons schema (additive: nothing is dropped here).
--   * sections / categories become real tables referenced by FK
--   * every translatable string moves to a locale-keyed *_i18n table, so adding a
--     language is data only
--   * slide visuals become a single JSONB `spec` (discriminated by spec->>'kind');
--     slides that only ever had raw HTML are wrapped as {"kind":"legacy-html"}
-- The old _en/_ar and visual columns stay (now nullable) until a later migration
-- drops them, so the previous code keeps working while the backend/frontend switch.

-- ── taxonomy ────────────────────────────────────────────────────────────────

CREATE TABLE lesson_sections (
    id      BIGSERIAL PRIMARY KEY,
    slug    VARCHAR(100) NOT NULL UNIQUE,
    ordinal INT          NOT NULL
);

CREATE TABLE lesson_section_i18n (
    section_id BIGINT      NOT NULL REFERENCES lesson_sections(id) ON DELETE CASCADE,
    locale     VARCHAR(8)  NOT NULL,
    name       TEXT        NOT NULL,
    PRIMARY KEY (section_id, locale)
);

CREATE TABLE lesson_categories (
    id         BIGSERIAL PRIMARY KEY,
    section_id BIGINT       NOT NULL REFERENCES lesson_sections(id) ON DELETE CASCADE,
    slug       VARCHAR(100) NOT NULL,
    ordinal    INT          NOT NULL,
    UNIQUE (section_id, slug)
);

CREATE TABLE lesson_category_i18n (
    category_id BIGINT     NOT NULL REFERENCES lesson_categories(id) ON DELETE CASCADE,
    locale      VARCHAR(8) NOT NULL,
    name        TEXT       NOT NULL,
    PRIMARY KEY (category_id, locale)
);

-- Sections/categories are numbered in order of first appearance by lesson ordinal.
INSERT INTO lesson_sections (slug, ordinal)
SELECT lower(regexp_replace(trim(section_en), '[^a-zA-Z0-9]+', '-', 'g')),
       row_number() OVER (ORDER BY min(ordinal)) - 1
FROM lessons
GROUP BY section_en;

INSERT INTO lesson_section_i18n (section_id, locale, name)
SELECT s.id, v.locale, v.name
FROM (SELECT DISTINCT section_en, section_ar FROM lessons) l
JOIN lesson_sections s ON s.slug = lower(regexp_replace(trim(l.section_en), '[^a-zA-Z0-9]+', '-', 'g'))
CROSS JOIN LATERAL (VALUES ('en', l.section_en), ('ar', l.section_ar)) AS v(locale, name);

INSERT INTO lesson_categories (section_id, slug, ordinal)
SELECT s.id,
       lower(regexp_replace(trim(l.category_en), '[^a-zA-Z0-9]+', '-', 'g')),
       row_number() OVER (PARTITION BY s.id ORDER BY min(l.ordinal)) - 1
FROM lessons l
JOIN lesson_sections s ON s.slug = lower(regexp_replace(trim(l.section_en), '[^a-zA-Z0-9]+', '-', 'g'))
WHERE l.category_en IS NOT NULL
GROUP BY s.id, l.category_en;

INSERT INTO lesson_category_i18n (category_id, locale, name)
SELECT c.id, v.locale, v.name
FROM (SELECT DISTINCT section_en, category_en, category_ar FROM lessons WHERE category_en IS NOT NULL) l
JOIN lesson_sections   s ON s.slug = lower(regexp_replace(trim(l.section_en), '[^a-zA-Z0-9]+', '-', 'g'))
JOIN lesson_categories c ON c.section_id = s.id
                        AND c.slug = lower(regexp_replace(trim(l.category_en), '[^a-zA-Z0-9]+', '-', 'g'))
CROSS JOIN LATERAL (VALUES ('en', l.category_en), ('ar', l.category_ar)) AS v(locale, name);

-- ── lessons ─────────────────────────────────────────────────────────────────

ALTER TABLE lessons
    ADD COLUMN slug        VARCHAR(150),
    ADD COLUMN section_id  BIGINT REFERENCES lesson_sections(id),
    ADD COLUMN category_id BIGINT REFERENCES lesson_categories(id),
    ADD COLUMN published   BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN created_at  TIMESTAMPTZ NOT NULL DEFAULT now();

UPDATE lessons SET slug = lower(regexp_replace(trim(title_en), '[^a-zA-Z0-9]+', '-', 'g'));
-- A slug is the public URL: strip leading/trailing dashes (e.g. "Find (Search)" -> "find-search").
UPDATE lessons SET slug = trim(both '-' from slug);

UPDATE lessons l SET section_id = s.id
FROM lesson_sections s
WHERE s.slug = lower(regexp_replace(trim(l.section_en), '[^a-zA-Z0-9]+', '-', 'g'));

UPDATE lessons l SET category_id = c.id
FROM lesson_categories c
WHERE l.category_en IS NOT NULL
  AND c.section_id = l.section_id
  AND c.slug = lower(regexp_replace(trim(l.category_en), '[^a-zA-Z0-9]+', '-', 'g'));

ALTER TABLE lessons
    ALTER COLUMN slug       SET NOT NULL,
    ALTER COLUMN section_id SET NOT NULL,
    ADD CONSTRAINT uq_lessons_slug UNIQUE (slug);

CREATE INDEX idx_lessons_section_id  ON lessons(section_id);
CREATE INDEX idx_lessons_category_id ON lessons(category_id);

CREATE TABLE lesson_i18n (
    lesson_id   BIGINT     NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    locale      VARCHAR(8) NOT NULL,
    title       TEXT       NOT NULL,
    description TEXT       NOT NULL,
    PRIMARY KEY (lesson_id, locale)
);

INSERT INTO lesson_i18n (lesson_id, locale, title, description)
SELECT id, 'en', title_en, description_en FROM lessons
UNION ALL
SELECT id, 'ar', title_ar, description_ar FROM lessons;

-- ── slides ──────────────────────────────────────────────────────────────────

ALTER TABLE lesson_slides ADD COLUMN spec JSONB;

UPDATE lesson_slides
SET spec = CASE
    WHEN visual_spec IS NOT NULL THEN visual_spec::jsonb
    ELSE jsonb_build_object('kind', 'legacy-html', 'html', visual)
END;

ALTER TABLE lesson_slides
    ALTER COLUMN spec SET NOT NULL,
    ADD CONSTRAINT uq_lesson_slides_lesson_ordinal UNIQUE (lesson_id, ordinal) DEFERRABLE INITIALLY DEFERRED,
    ADD CONSTRAINT chk_lesson_slides_spec_kind CHECK (spec ? 'kind');

CREATE TABLE lesson_slide_i18n (
    slide_id BIGINT     NOT NULL REFERENCES lesson_slides(id) ON DELETE CASCADE,
    locale   VARCHAR(8) NOT NULL,
    kicker   TEXT       NOT NULL,
    title    TEXT       NOT NULL,
    body     TEXT       NOT NULL,
    PRIMARY KEY (slide_id, locale)
);

INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT id, 'en', kicker_en, title_en, body_en FROM lesson_slides
UNION ALL
SELECT id, 'ar', kicker_ar, title_ar, body_ar FROM lesson_slides;

-- ── let the new write path ignore the legacy columns ────────────────────────

ALTER TABLE lessons
    ALTER COLUMN title_en       DROP NOT NULL,
    ALTER COLUMN title_ar       DROP NOT NULL,
    ALTER COLUMN description_en DROP NOT NULL,
    ALTER COLUMN description_ar DROP NOT NULL,
    ALTER COLUMN section_en     DROP NOT NULL,
    ALTER COLUMN section_ar     DROP NOT NULL,
    ALTER COLUMN ordinal        SET  NOT NULL;

ALTER TABLE lesson_slides
    ALTER COLUMN kicker_en DROP NOT NULL,
    ALTER COLUMN kicker_ar DROP NOT NULL,
    ALTER COLUMN title_en  DROP NOT NULL,
    ALTER COLUMN title_ar  DROP NOT NULL,
    ALTER COLUMN visual    DROP NOT NULL,
    ALTER COLUMN body_en   DROP NOT NULL,
    ALTER COLUMN body_ar   DROP NOT NULL;

-- ── sequences ───────────────────────────────────────────────────────────────
-- The seed migrations inserted explicit ids, so the sequences lagged behind and the
-- next admin-created lesson would collide with an existing id. Resync them.
SELECT setval(pg_get_serial_sequence('lessons', 'id'),       COALESCE((SELECT MAX(id) FROM lessons), 1),       (SELECT COUNT(*) > 0 FROM lessons));
SELECT setval(pg_get_serial_sequence('lesson_slides', 'id'), COALESCE((SELECT MAX(id) FROM lesson_slides), 1), (SELECT COUNT(*) > 0 FROM lesson_slides));
