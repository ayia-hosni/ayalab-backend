package com.ayalab.service;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.BiConsumer;

/**
 * Structural validation of a slide's {@code spec}. It checks what the renderer relies on
 * (kind, required arrays, id references, tree shape) and nothing about styling.
 */
@Component
public class SlideSpecValidator {

    private static final Set<String> LIST_VARIANTS = Set.of("singly", "doubly", "circular");

    /** @return human-readable problems; empty when the spec is valid */
    public List<String> validate(JsonNode spec) {
        List<String> errors = new ArrayList<>();
        if (spec == null || !spec.isObject()) {
            errors.add("spec must be an object");
            return errors;
        }
        String kind = spec.path("kind").asText("");
        switch (kind) {
            case "legacy-html" -> {
                if (!spec.path("html").isTextual()) errors.add("legacy-html needs a string 'html'");
            }
            case "chain" -> {
                if (!spec.path("frames").isArray()) errors.add("chain needs a 'frames' array");
            }
            case "grid" -> {
                if (!spec.path("grid").path("cards").isArray()) errors.add("grid needs 'grid.cards'");
            }
            case "list" -> validateList(spec, errors);
            case "tree" -> validateTree(spec, errors);
            case "memory" -> validateMemory(spec, errors);
            default -> errors.add("unknown spec kind '" + kind + "'");
        }
        return errors;
    }

    private void validateList(JsonNode spec, List<String> errors) {
        if (!LIST_VARIANTS.contains(spec.path("variant").asText(""))) {
            errors.add("list.variant must be one of " + LIST_VARIANTS);
        }
        forEachPanel(spec, "list", errors, (panel, where) -> {
            Set<String> ids = collectIds(panel.path("nodes"), where + ".nodes", errors);
            checkRefs(panel.path("highlight"), ids, where + ".highlight", errors);
            for (JsonNode p : panel.path("pointers")) {
                if (!ids.contains(p.path("at").asText())) {
                    errors.add(where + ".pointers refers to unknown node '" + p.path("at").asText() + "'");
                }
            }
        });
    }

    private void validateTree(JsonNode spec, List<String> errors) {
        forEachPanel(spec, "tree", errors, (panel, where) -> validateTreePanel(panel, where, errors));
    }

    private void validateMemory(JsonNode spec, List<String> errors) {
        forEachPanel(spec, "memory", errors, (panel, where) -> {
            Set<String> ids = collectIds(panel.path("cells"), where + ".cells", errors);
            for (JsonNode a : panel.path("arrows")) {
                String from = a.path("from").asText();
                String to = a.path("to").asText();
                if (!ids.contains(from)) errors.add(where + ".arrows refers to unknown cell '" + from + "'");
                if (!ids.contains(to)) errors.add(where + ".arrows refers to unknown cell '" + to + "'");
                if (from.equals(to)) errors.add(where + ".arrows has a self-arrow on '" + from + "'");
            }
            checkRefs(panel.path("highlight"), ids, where + ".highlight", errors);
        });
    }

    /** A diagram slide is one or more captioned panels (e.g. Before / After). */
    private void forEachPanel(JsonNode spec, String kind, List<String> errors, BiConsumer<JsonNode, String> check) {
        JsonNode panels = spec.path("panels");
        if (!panels.isArray() || panels.isEmpty()) {
            errors.add(kind + " needs a non-empty 'panels' array");
            return;
        }
        for (int i = 0; i < panels.size(); i++) {
            check.accept(panels.get(i), kind + ".panels[" + i + "]");
        }
    }

    private void validateTreePanel(JsonNode panel, String where, List<String> errors) {
        JsonNode nodes = panel.path("nodes");
        Set<String> ids = collectIds(nodes, where + ".nodes", errors);
        Map<String, String> parentOf = new HashMap<>();
        Map<String, Integer> childCount = new HashMap<>();
        int roots = 0;
        for (JsonNode n : nodes) {
            String id = n.path("id").asText();
            JsonNode parent = n.path("parent");
            if (parent.isMissingNode() || parent.isNull()) {
                roots++;
                continue;
            }
            if (!ids.contains(parent.asText())) {
                errors.add(where + " node '" + id + "' has unknown parent '" + parent.asText() + "'");
                continue;
            }
            String side = n.path("side").asText("");
            if (!side.equals("left") && !side.equals("right")) {
                errors.add(where + " node '" + id + "' needs side 'left' or 'right'");
            }
            parentOf.put(id, parent.asText());
            childCount.merge(parent.asText() + "/" + side, 1, Integer::sum);
        }
        childCount.forEach((slot, count) -> {
            if (count > 1) errors.add(where + " parent slot '" + slot + "' is used by " + count + " nodes");
        });
        if (nodes.size() > 0 && roots != 1) errors.add(where + " needs exactly one root (parent: null), found " + roots);
        for (String id : parentOf.keySet()) {
            if (hasCycle(id, parentOf)) {
                errors.add(where + " contains a cycle through '" + id + "'");
                break;
            }
        }
        checkRefs(panel.path("highlight"), ids, where + ".highlight", errors);
        checkRefs(panel.path("visitOrder"), ids, where + ".visitOrder", errors);
    }

    private boolean hasCycle(String start, Map<String, String> parentOf) {
        Set<String> seen = new HashSet<>();
        String cur = start;
        while (cur != null) {
            if (!seen.add(cur)) return true;
            cur = parentOf.get(cur);
        }
        return false;
    }

    private Set<String> collectIds(JsonNode nodes, String where, List<String> errors) {
        Set<String> ids = new HashSet<>();
        if (!nodes.isArray()) {
            errors.add(where + " must be an array");
            return ids;
        }
        for (JsonNode n : nodes) {
            String id = n.path("id").asText("");
            if (id.isEmpty()) errors.add(where + " has a node without an id");
            else if (!ids.add(id)) errors.add(where + " has duplicate id '" + id + "'");
        }
        return ids;
    }

    private void checkRefs(JsonNode refs, Set<String> ids, String where, List<String> errors) {
        for (JsonNode r : refs) {
            if (!ids.contains(r.asText())) errors.add(where + " refers to unknown node '" + r.asText() + "'");
        }
    }
}
