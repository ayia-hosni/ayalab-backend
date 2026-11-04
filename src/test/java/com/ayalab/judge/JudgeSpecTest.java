package com.ayalab.judge;

import com.ayalab.judge.JudgeSpec.ArgsKind;
import com.ayalab.judge.JudgeSpec.ResultKind;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JudgeSpecTest {

    @Test
    void acceptsPlainIdentifiers() {
        assertThat(new JudgeSpec("isPalindrome", ArgsKind.LIST, ResultKind.BOOLEAN).method()).isEqualTo("isPalindrome");
        assertThat(new JudgeSpec("_reverse2", ArgsKind.INT, ResultKind.LIST).result()).isEqualTo(ResultKind.LIST);
    }

    @Test
    void rejectsNamesThatCouldInjectCodeIntoTheHarness() {
        for (String bad : new String[]{"", "a b", "reverse(head); evil()", "1abc", "a-b", "x;y", null}) {
            assertThatThrownBy(() -> new JudgeSpec(bad, ArgsKind.LIST, ResultKind.LIST))
                    .as("method name %s", bad).isInstanceOf(IllegalArgumentException.class);
        }
        assertThatThrownBy(() -> new JudgeSpec("ok", ArgsKind.LIST, null)).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> new JudgeSpec("ok", null, ResultKind.LIST)).isInstanceOf(IllegalArgumentException.class);
    }
}
