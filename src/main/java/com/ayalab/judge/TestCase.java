package com.ayalab.judge;

/**
 * A single input/expected-output pair. Both are plain JSON-shaped values whose form is set by the
 * problem's {@link JudgeSpec}:
 * <ul>
 *   <li>input: {@code List<Integer>} (LIST), {@code List<Object>} of {@code [List<Integer>, Integer]}
 *       (LIST_AND_INT), or {@code Integer} (INT)</li>
 *   <li>expected: {@code List<Integer>} (LIST), {@code Boolean} (BOOLEAN), or {@code Integer} (INT)</li>
 * </ul>
 */
public record TestCase(Object input, Object expected) {
}
