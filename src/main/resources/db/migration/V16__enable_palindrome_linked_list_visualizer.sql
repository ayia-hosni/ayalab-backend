-- Enable the three visualizer tabs (Move the Pointer, Both Solutions, Trace Game)
-- for LeetCode 234, now that palindrome-linked-list visualizer bundles exist
-- in the frontend (move-pointer-palindrome-react.tsx and siblings).

UPDATE problems SET visualizer_type = 'POINTER_TRACE' WHERE id = 234;
