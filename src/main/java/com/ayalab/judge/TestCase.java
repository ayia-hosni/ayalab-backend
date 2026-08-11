package com.ayalab.judge;

import java.util.List;

/** A single input/expected-output pair for the Reverse Linked List problem. */
public record TestCase(List<Integer> input, List<Integer> expected) {
}
