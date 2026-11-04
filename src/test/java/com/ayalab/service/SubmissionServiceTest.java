package com.ayalab.service;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemTestCase;
import com.ayalab.judge.JavaJudge;
import com.ayalab.judge.JavaScriptJudge;
import com.ayalab.judge.JudgeSpec;
import com.ayalab.repository.ProblemRepository;
import com.ayalab.repository.ProblemTestCaseRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class SubmissionServiceTest {

    private final JavaScriptJudge js = mock(JavaScriptJudge.class);
    private final JavaJudge java = mock(JavaJudge.class);
    private final ProblemRepository problems = mock(ProblemRepository.class);
    private final ProblemTestCaseRepository cases = mock(ProblemTestCaseRepository.class);
    private final ProblemService problemService = mock(ProblemService.class);
    private final SubmissionService service =
            new SubmissionService(js, java, problems, cases, problemService, new ObjectMapper());

    private Problem problem;

    @BeforeEach
    void setUp() {
        problem = new Problem();
        ReflectionTestUtils.setField(problem, "id", 234L);
        when(problems.findBySlug("p")).thenReturn(Optional.of(problem));
    }

    private static ProblemTestCase testCase(boolean sample, String in, String out) {
        ProblemTestCase tc = new ProblemTestCase();
        ReflectionTestUtils.setField(tc, "sample", sample);
        ReflectionTestUtils.setField(tc, "inputJson", in);
        ReflectionTestUtils.setField(tc, "outputJson", out);
        return tc;
    }

    @Test
    void problemWithoutAJudgeSpecSaysSoAndTouchesNothing() {
        SubmitResult r = service.submit("p", new SubmitRequest("java", "code", true));
        assertThat(r.accepted()).isFalse();
        assertThat(r.verdict()).isEqualTo("Judge Unavailable");
        verifyNoInteractions(java, js, cases);
        verify(problemService, never()).updateStatus(any(), any());
    }

    @Test
    void problemWithoutTestCasesIsNeverVacuouslyAccepted() {
        ReflectionTestUtils.setField(problem, "judgeMethod", "isPalindrome");
        ReflectionTestUtils.setField(problem, "judgeArgsKind", "LIST");
        ReflectionTestUtils.setField(problem, "judgeResultKind", "BOOLEAN");
        when(cases.findByProblemIdOrderByOrdinal(234L)).thenReturn(List.of());
        SubmitResult r = service.submit("p", new SubmitRequest("java", "code", true));
        assertThat(r.accepted()).isFalse();
        assertThat(r.verdict()).isEqualTo("No Test Cases");
        verifyNoInteractions(java, js);
        verify(problemService, never()).updateStatus(any(), any());
    }

    @Test
    void booleanCasesAreDecodedAndPassedToTheJudgeWithItsSpec() {
        ReflectionTestUtils.setField(problem, "judgeMethod", "isPalindrome");
        ReflectionTestUtils.setField(problem, "judgeArgsKind", "LIST");
        ReflectionTestUtils.setField(problem, "judgeResultKind", "BOOLEAN");
        when(cases.findByProblemIdOrderByOrdinal(234L)).thenReturn(List.of(
                testCase(true, "[1,2,2,1]", "true"), testCase(false, "[1,2]", "false")));
        when(java.run(any(), any(), anyList())).thenReturn(new SubmitResult(true, "Accepted", null, 1, List.of()));

        service.submit("p", new SubmitRequest("java", "code", true));

        ArgumentCaptor<JudgeSpec> spec = ArgumentCaptor.forClass(JudgeSpec.class);
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<com.ayalab.judge.TestCase>> sent = ArgumentCaptor.forClass(List.class);
        verify(java).run(eq("code"), spec.capture(), sent.capture());
        assertThat(spec.getValue()).isEqualTo(new JudgeSpec("isPalindrome", JudgeSpec.ArgsKind.LIST, JudgeSpec.ResultKind.BOOLEAN));
        assertThat(sent.getValue()).extracting(com.ayalab.judge.TestCase::expected).containsExactly(true, false);
    }

    @Test
    void runOnlyUsesSamplesAndListCasesStayLists() {
        ReflectionTestUtils.setField(problem, "judgeMethod", "reverseList");
        ReflectionTestUtils.setField(problem, "judgeArgsKind", "LIST");
        ReflectionTestUtils.setField(problem, "judgeResultKind", "LIST");
        when(cases.findByProblemIdOrderByOrdinal(234L)).thenReturn(List.of(
                testCase(true, "[1,2]", "[2,1]"), testCase(false, "[3]", "[3]")));
        when(js.run(any(), any(), anyList())).thenReturn(new SubmitResult(true, "Accepted", null, 1, List.of()));

        service.submit("p", new SubmitRequest("javascript", "code", false));

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<com.ayalab.judge.TestCase>> sent = ArgumentCaptor.forClass(List.class);
        verify(js).run(eq("code"), any(), sent.capture());
        assertThat(sent.getValue()).hasSize(1);
        assertThat(sent.getValue().get(0).expected()).isEqualTo(List.of(2, 1));
    }

    @Test
    void listAndIntInputsAndIntOutputsAreDecoded() {
        ReflectionTestUtils.setField(problem, "judgeMethod", "removeElements");
        ReflectionTestUtils.setField(problem, "judgeArgsKind", "LIST_AND_INT");
        ReflectionTestUtils.setField(problem, "judgeResultKind", "LIST");
        when(cases.findByProblemIdOrderByOrdinal(234L)).thenReturn(List.of(testCase(true, "[[1,2,6],6]", "[1,2]")));
        when(java.run(any(), any(), anyList())).thenReturn(new SubmitResult(true, "Accepted", null, 1, List.of()));
        service.submit("p", new SubmitRequest("java", "code", false));
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<com.ayalab.judge.TestCase>> sent = ArgumentCaptor.forClass(List.class);
        verify(java).run(eq("code"), any(), sent.capture());
        assertThat(sent.getValue().get(0).input()).isEqualTo(List.of(List.of(1, 2, 6), 6));
        assertThat(sent.getValue().get(0).expected()).isEqualTo(List.of(1, 2));

        ReflectionTestUtils.setField(problem, "judgeMethod", "fib");
        ReflectionTestUtils.setField(problem, "judgeArgsKind", "INT");
        ReflectionTestUtils.setField(problem, "judgeResultKind", "INT");
        when(cases.findByProblemIdOrderByOrdinal(234L)).thenReturn(List.of(testCase(true, "10", "55")));
        service.submit("p", new SubmitRequest("java", "code2", false));
        verify(java).run(eq("code2"), any(), sent.capture());
        assertThat(sent.getValue().get(0).input()).isEqualTo(10);
        assertThat(sent.getValue().get(0).expected()).isEqualTo(55);
    }
}
