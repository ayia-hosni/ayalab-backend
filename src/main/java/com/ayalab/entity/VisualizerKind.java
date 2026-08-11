package com.ayalab.entity;

/** Which interactive tab a {@link ProblemGameConfig} row's JSON drives. */
public enum VisualizerKind {
    TRACE_GAME,
    MOVE_POINTER,
    SOLUTION_SLIDES;

    /** camelCase key used on the wire, e.g. {@code traceGame} — matches the frontend's tab names. */
    public String jsonKey() {
        String[] parts = name().toLowerCase().split("_");
        StringBuilder sb = new StringBuilder(parts[0]);
        for (int i = 1; i < parts.length; i++) {
            sb.append(Character.toUpperCase(parts[i].charAt(0))).append(parts[i].substring(1));
        }
        return sb.toString();
    }

    /** Inverse of {@link #jsonKey()}, e.g. {@code traceGame} -> {@code TRACE_GAME}. */
    public static VisualizerKind fromJsonKey(String key) {
        return valueOf(key.replaceAll("([A-Z])", "_$1").toUpperCase());
    }
}
