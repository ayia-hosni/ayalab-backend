package com.ayalab.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class SlideSpecValidatorTest {

    private final SlideSpecValidator validator = new SlideSpecValidator();
    private final ObjectMapper json = new ObjectMapper();

    private List<String> check(String spec) throws Exception {
        return validator.validate(json.readTree(spec));
    }

    @Test
    void acceptsExistingKinds() throws Exception {
        assertThat(check("{\"kind\":\"legacy-html\",\"html\":\"<div/>\"}")).isEmpty();
        assertThat(check("{\"kind\":\"chain\",\"frames\":[]}")).isEmpty();
        assertThat(check("{\"kind\":\"grid\",\"grid\":{\"cards\":[]}}")).isEmpty();
    }

    @Test
    void rejectsUnknownKindAndNonObjects() throws Exception {
        assertThat(check("{\"kind\":\"pie\"}")).anyMatch(e -> e.contains("unknown spec kind"));
        assertThat(check("[]")).containsExactly("spec must be an object");
        assertThat(validator.validate(null)).containsExactly("spec must be an object");
    }

    @Test
    void validDoublyListWithBeforeAfterPanels() throws Exception {
        assertThat(check("""
                {"kind":"list","variant":"doubly","panels":[
                  {"caption":"Before","nodes":[{"id":"a"},{"id":"b"}],
                   "pointers":[{"name":"Head","at":"a"}],"highlight":["b"]},
                  {"caption":"After","nodes":[{"id":"a"}]}]}""")).isEmpty();
    }

    @Test
    void listRejectsBadVariantDuplicateIdsAndDanglingRefs() throws Exception {
        List<String> errors = check("""
                {"kind":"list","variant":"ring","panels":[
                 {"nodes":[{"id":"a"},{"id":"a"}],
                  "pointers":[{"name":"Head","at":"zzz"}],"highlight":["nope"]}]}""");
        assertThat(errors).anyMatch(e -> e.contains("variant"))
                .anyMatch(e -> e.contains("duplicate id 'a'"))
                .anyMatch(e -> e.contains("unknown node 'zzz'"))
                .anyMatch(e -> e.contains("unknown node 'nope'"));
    }

    @Test
    void diagramKindsRequirePanels() throws Exception {
        assertThat(check("{\"kind\":\"list\",\"variant\":\"singly\"}")).anyMatch(e -> e.contains("non-empty 'panels'"));
        assertThat(check("{\"kind\":\"tree\",\"panels\":[]}")).anyMatch(e -> e.contains("non-empty 'panels'"));
    }

    @Test
    void validTree() throws Exception {
        assertThat(check("""
                {"kind":"tree","panels":[{"nodes":[
                  {"id":"r","parent":null},
                  {"id":"l","parent":"r","side":"left"},
                  {"id":"x","parent":"r","side":"right"}],
                 "visitOrder":["l","r","x"]}]}""")).isEmpty();
    }

    @Test
    void treeRejectsTwoRootsSharedSlotsAndMissingSide() throws Exception {
        List<String> errors = check("""
                {"kind":"tree","panels":[{"nodes":[
                  {"id":"r","parent":null},{"id":"r2","parent":null},
                  {"id":"a","parent":"r","side":"left"},
                  {"id":"b","parent":"r","side":"left"},
                  {"id":"c","parent":"r"}]}]}""");
        assertThat(errors).anyMatch(e -> e.contains("exactly one root"))
                .anyMatch(e -> e.contains("used by 2 nodes"))
                .anyMatch(e -> e.contains("needs side"));
    }

    @Test
    void treeRejectsUnknownParentAndCycles() throws Exception {
        assertThat(check("{\"kind\":\"tree\",\"panels\":[{\"nodes\":[{\"id\":\"r\",\"parent\":null},{\"id\":\"a\",\"parent\":\"ghost\",\"side\":\"left\"}]}]}"))
                .anyMatch(e -> e.contains("unknown parent 'ghost'"));
        assertThat(check("""
                {"kind":"tree","panels":[{"nodes":[
                  {"id":"r","parent":null},
                  {"id":"a","parent":"b","side":"left"},
                  {"id":"b","parent":"a","side":"left"}]}]}"""))
                .anyMatch(e -> e.contains("cycle"));
    }

    @Test
    void validMemoryDiagram() throws Exception {
        assertThat(check("""
                {"kind":"memory","panels":[{"cells":[
                  {"id":"x","address":"1000","name":"x","value":"42"},
                  {"id":"p","address":"1004","name":"p","value":"1000"}],
                 "arrows":[{"from":"p","to":"x"}],"highlight":["x"]}]}""")).isEmpty();
    }

    @Test
    void memoryRejectsDanglingAndSelfArrowsAndDuplicateCells() throws Exception {
        List<String> errors = check("""
                {"kind":"memory","panels":[{"cells":[{"id":"x"},{"id":"x"}],
                 "arrows":[{"from":"x","to":"ghost"},{"from":"x","to":"x"}],"highlight":["nope"]}]}""");
        assertThat(errors).anyMatch(e -> e.contains("duplicate id 'x'"))
                .anyMatch(e -> e.contains("unknown cell 'ghost'"))
                .anyMatch(e -> e.contains("self-arrow"))
                .anyMatch(e -> e.contains("unknown node 'nope'"));
        assertThat(check("{\"kind\":\"memory\"}")).anyMatch(e -> e.contains("non-empty 'panels'"));
    }
}
