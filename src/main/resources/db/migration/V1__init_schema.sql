-- Schema for the ayalab problem set.

CREATE TABLE problems (
    id             BIGINT       PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    slug           VARCHAR(255) NOT NULL UNIQUE,
    acceptance     DOUBLE PRECISION NOT NULL,
    difficulty     VARCHAR(16)  NOT NULL,
    status         VARCHAR(16)  NOT NULL DEFAULT 'TODO',
    description    TEXT,
    has_visualizer BOOLEAN      NOT NULL DEFAULT FALSE,
    starter_code   TEXT
);

CREATE TABLE problem_tags (
    problem_id BIGINT      NOT NULL REFERENCES problems (id) ON DELETE CASCADE,
    tag        VARCHAR(64) NOT NULL,
    PRIMARY KEY (problem_id, tag)
);

CREATE INDEX idx_problem_tags_tag ON problem_tags (tag);
CREATE INDEX idx_problems_difficulty ON problems (difficulty);
CREATE INDEX idx_problems_status ON problems (status);
