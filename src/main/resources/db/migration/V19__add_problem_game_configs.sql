-- Interactive-game content (trace-game / move-pointer / solution-slides tabs) used to be
-- hardcoded per problem in the frontend. This table lets it live in the database instead,
-- so the frontend can render a single generic engine per visualizer kind driven by JSON.
CREATE TABLE problem_game_configs (
    id               BIGSERIAL PRIMARY KEY,
    problem_id       BIGINT NOT NULL REFERENCES problems(id),
    visualizer_kind  VARCHAR(32) NOT NULL, -- 'TRACE_GAME' | 'MOVE_POINTER' | 'SOLUTION_SLIDES'
    config           JSONB NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (problem_id, visualizer_kind)
);
