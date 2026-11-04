package com.ayalab.integration;

import com.ayalab.dto.AdminLessonDto;
import com.ayalab.dto.AdminLessonRequest;
import com.ayalab.dto.AdminLessonRequest.LessonTextDto;
import com.ayalab.dto.AdminSlideRequest;
import com.ayalab.dto.AdminSlideRequest.SlideTextDto;
import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.service.SlideSpecValidator;
import com.ayalab.service.AdminLessonService;
import com.ayalab.service.LessonService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Runs every Flyway migration into an isolated schema of a real Postgres, lets Hibernate
 * validate the entities against it, and exercises the lesson services end to end.
 * Opt in with ITEST_DB_URL (e.g. jdbc:postgresql://localhost:5432/ayalab); the schema is
 * named {@code itest_lessons} and is dropped by the test before it starts.
 */
@SpringBootTest
@EnabledIfEnvironmentVariable(named = "ITEST_DB_URL", matches = ".+")
class LessonsDatabaseIT {

    private static final String SCHEMA = "itest_lessons";

    @DynamicPropertySource
    static void database(DynamicPropertyRegistry r) {
        String url = System.getenv("ITEST_DB_URL");
        r.add("spring.datasource.url", () -> url + (url.contains("?") ? "&" : "?") + "currentSchema=" + SCHEMA);
        r.add("spring.flyway.schemas", () -> SCHEMA);
        r.add("spring.flyway.create-schemas", () -> "true");
        r.add("spring.flyway.default-schema", () -> SCHEMA);
        r.add("spring.flyway.clean-disabled", () -> "false");
    }

    @Autowired LessonService reader;
    @Autowired AdminLessonService admin;
    @Autowired SlideSpecValidator validator;
    @Autowired com.ayalab.repository.ProblemRepository problems;
    @Autowired com.ayalab.repository.ProblemTestCaseRepository testCases;
    private final ObjectMapper json = new ObjectMapper();

    @Test
    void migratedSeedLessonsAreReadableInBothLocales() {
        var en = reader.list("en");
        var ar = reader.list("ar");
        // Lessons authored through the admin panel (e.g. "Find") are not in any migration, so only assert the seeded ones.
        assertThat(en).hasSizeGreaterThanOrEqualTo(8);
        assertThat(en).extracting(LessonSummary::slug)
                .startsWith("memory-and-addresses", "what-is-a-pointer", "pointers-in-action", "linked-list-basics");
        var basics = en.stream().filter(l -> l.slug().equals("linked-list-basics")).findFirst().orElseThrow();
        var basicsAr = ar.stream().filter(l -> l.slug().equals("linked-list-basics")).findFirst().orElseThrow();
        assertThat(basics.slideCount()).isEqualTo(19);
        assertThat(basics.section().name()).isEqualTo("Linked Lists");
        assertThat(basicsAr.section().name()).isEqualTo("القوائم المرتبطة");
        assertThat(basicsAr.title()).isNotEqualTo(basics.title());
        assertThat(en.get(0).section().name()).isEqualTo("Pointers");
        assertThat(ar.get(0).section().name()).isEqualTo("المؤشرات");

        LessonDetail traversal = reader.get("traversal", "en");
        assertThat(traversal.slides()).hasSize(18);
        assertThat(traversal.slides().get(0).visual().path("kind").asText()).isEqualTo("legacy-html");
        assertThat(reader.get("tree-basics", "en").slides().get(0).visual().path("kind").asText()).isEqualTo("legacy-html");
        assertThat(reader.get("1", "en").slug()).isEqualTo("linked-list-basics");
    }

    @Test
    void everySeededSlideHasAValidSpecAndBothLanguages() {
        for (var lesson : admin.list()) {
            for (var slide : lesson.slides()) {
                String where = lesson.slug() + " #" + slide.ordinal();
                assertThat(validator.validate(slide.spec())).as(where).isEmpty();
                assertThat(slide.translations().keySet()).as(where).contains("en", "ar");
            }
        }
        assertThat(reader.get("memory-and-addresses", "en").slides()).hasSize(11);
        assertThat(reader.get("what-is-a-pointer", "en").slides()).hasSize(14);
        assertThat(reader.get("pointers-in-action", "ar").slides()).hasSize(13);
    }

    @Test
    void judgeSpecsAndPalindromeTestCasesAreSeeded() {
        var reverse = problems.findBySlug("reverse-linked-list").orElseThrow();
        assertThat(reverse.getJudgeMethod()).isEqualTo("reverseList");
        assertThat(reverse.getJudgeArgsKind()).isEqualTo("LIST");
        assertThat(reverse.getJudgeResultKind()).isEqualTo("LIST");

        var palindrome = problems.findBySlug("palindrome-linked-list").orElseThrow();
        assertThat(palindrome.getJudgeMethod()).isEqualTo("isPalindrome");
        assertThat(palindrome.getJudgeResultKind()).isEqualTo("BOOLEAN");
        var cases = testCases.findByProblemIdOrderByOrdinal(palindrome.getId());
        assertThat(cases).hasSize(7);
        assertThat(cases.stream().filter(com.ayalab.entity.ProblemTestCase::isSample)).hasSize(2);
        assertThat(cases).extracting(com.ayalab.entity.ProblemTestCase::getOutputJson)
                .containsExactly("true", "false", "true", "true", "false", "true", "false");
    }

    @Test
    void removeElementsAndFibonacciAreJudgeable() {
        var remove = problems.findBySlug("remove-linked-list-elements").orElseThrow();
        assertThat(remove.getJudgeMethod()).isEqualTo("removeElements");
        assertThat(remove.getJudgeArgsKind()).isEqualTo("LIST_AND_INT");
        assertThat(remove.getJudgeResultKind()).isEqualTo("LIST");
        var removeCases = testCases.findByProblemIdOrderByOrdinal(remove.getId());
        assertThat(removeCases).hasSize(8);
        assertThat(removeCases.get(0).getInputJson()).isEqualTo("[[1,2,6,3,4,5,6],6]");

        var fib = problems.findBySlug("fibonacci-number").orElseThrow();
        assertThat(fib.getJudgeMethod()).isEqualTo("fib");
        assertThat(fib.getJudgeArgsKind()).isEqualTo("INT");
        assertThat(fib.getJudgeResultKind()).isEqualTo("INT");
        assertThat(testCases.findByProblemIdOrderByOrdinal(fib.getId())).hasSize(9);
    }

    @Test
    void createUpdateReorderAndDeleteRoundTrip() throws Exception {
        Long sectionId = admin.taxonomy().sections().get(0).id();
        var texts = Map.of("en", new SlideTextDto("k", "First", "<p>one</p><script>x()</script>"),
                "ar", new SlideTextDto("ك", "الأول", "<p>واحد</p>"));
        var a = new AdminSlideRequest(null, json.readTree("{\"kind\":\"list\",\"variant\":\"doubly\",\"panels\":[{\"nodes\":[{\"id\":\"a\"}]}]}"), texts);
        var b = new AdminSlideRequest(null, json.readTree("{\"kind\":\"chain\",\"frames\":[]}"), texts);

        AdminLessonDto created = admin.create(request("it-lesson", sectionId, List.of(a, b)));
        assertThat(created.slides()).hasSize(2);
        assertThat(created.slides().get(0).translations().get("en").body()).isEqualTo("<p>one</p>"); // script stripped
        Long firstId = created.slides().get(0).id();
        Long secondId = created.slides().get(1).id();

        // swap order and drop nothing: ids stay stable, ordinals swap (deferred unique constraint)
        var swapped = List.of(
                new AdminSlideRequest(secondId, created.slides().get(1).spec(), texts),
                new AdminSlideRequest(firstId, created.slides().get(0).spec(), texts));
        AdminLessonDto updated = admin.update(created.id(), request("it-lesson", sectionId, swapped));
        assertThat(updated.slides()).extracting(AdminLessonDto.AdminSlideDto::id).containsExactly(secondId, firstId);

        // removing a slide deletes only that one
        AdminLessonDto trimmed = admin.update(created.id(), request("it-lesson", sectionId,
                List.of(new AdminSlideRequest(firstId, created.slides().get(0).spec(), texts))));
        assertThat(trimmed.slides()).extracting(AdminLessonDto.AdminSlideDto::id).containsExactly(firstId);

        assertThat(reader.get("it-lesson", "ar").slides().get(0).title()).isEqualTo("الأول");

        admin.delete(created.id());
        assertThatThrownBy(() -> reader.get("it-lesson", "en")).hasMessageContaining("not found");
    }

    @Test
    void invalidSpecAndDuplicateSlugAreRejectedWithoutWriting() throws Exception {
        Long sectionId = admin.taxonomy().sections().get(0).id();
        var texts = Map.of("en", new SlideTextDto("k", "t", "b"));
        var bad = new AdminSlideRequest(null, json.readTree("{\"kind\":\"tree\",\"panels\":[{\"nodes\":[{\"id\":\"r\",\"parent\":\"ghost\"}]}]}"), texts);
        assertThatThrownBy(() -> admin.create(request("bad-spec", sectionId, List.of(bad))))
                .isInstanceOf(IllegalArgumentException.class).hasMessageContaining("slides[0].spec");
        assertThat(admin.list()).extracting(AdminLessonDto::slug).doesNotContain("bad-spec");

        assertThatThrownBy(() -> admin.create(request("tree-basics", sectionId, List.of())))
                .hasMessageContaining("slug already in use");
    }

    private AdminLessonRequest request(String slug, Long sectionId, List<AdminSlideRequest> slides) {
        return new AdminLessonRequest(slug, 99, "x", true, sectionId, null,
                Map.of("en", new LessonTextDto("Title", "Desc"), "ar", new LessonTextDto("عنوان", "وصف")), slides);
    }
}
