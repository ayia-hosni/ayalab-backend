-- Backing store for the Lessons feature (previously hardcoded on the frontend).
CREATE TABLE lessons (
    id BIGSERIAL PRIMARY KEY,
    ordinal INT NOT NULL,
    icon VARCHAR(32) NOT NULL,
    title_en TEXT NOT NULL,
    title_ar TEXT NOT NULL,
    description_en TEXT NOT NULL,
    description_ar TEXT NOT NULL
);

CREATE TABLE lesson_slides (
    id BIGSERIAL PRIMARY KEY,
    lesson_id BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    ordinal INT NOT NULL,
    kicker_en TEXT NOT NULL,
    kicker_ar TEXT NOT NULL,
    title_en TEXT NOT NULL,
    title_ar TEXT NOT NULL,
    visual TEXT NOT NULL,
    body_en TEXT NOT NULL,
    body_ar TEXT NOT NULL
);

CREATE INDEX idx_lesson_slides_lesson_id ON lesson_slides(lesson_id);
