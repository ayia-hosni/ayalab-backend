package com.ayalab.judge;

import java.util.regex.Pattern;

/**
 * How to run one problem: which method of the user's solution to call, how its arguments are built
 * from a test case's input, and what kind of value it returns. Read from the problem row, so adding
 * a problem of an existing shape needs no judge change.
 */
public record JudgeSpec(String method, ArgsKind args, ResultKind result) {

    /** What the solution method receives. */
    public enum ArgsKind {
        /** A linked list head, built from a list of ints: {@code f(head)}. */
        LIST,
        /** A linked list head and an int, built from {@code [[..ints..], value]}: {@code f(head, value)}. */
        LIST_AND_INT,
        /** A single int: {@code f(n)}. */
        INT
    }

    /** What the solution method returns, and therefore how its result is printed, parsed and compared. */
    public enum ResultKind {
        /** A linked list, compared as the list of its values. */
        LIST,
        /** A boolean. */
        BOOLEAN,
        /** An int. */
        INT
    }

    private static final Pattern IDENTIFIER = Pattern.compile("[A-Za-z_][A-Za-z0-9_]*");

    public JudgeSpec {
        // The method name is spliced into generated source, so it must be a plain identifier.
        if (method == null || !IDENTIFIER.matcher(method).matches()) {
            throw new IllegalArgumentException("Invalid judge method name: " + method);
        }
        if (args == null) throw new IllegalArgumentException("Judge args kind is required");
        if (result == null) throw new IllegalArgumentException("Judge result kind is required");
    }
}
