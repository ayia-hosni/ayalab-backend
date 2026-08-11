-- Move Pointer, Both Solutions, and Trace Game now have dedicated visualizer
-- components for Remove Linked List Elements (frontend picks them per-slug),
-- so this problem can carry the same POINTER_TRACE visualizer as problem 206.
UPDATE problems SET visualizer_type = 'POINTER_TRACE' WHERE id = 203;
