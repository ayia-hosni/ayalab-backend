-- Seeds Lesson 5: "Insert Last" — inserting a node at the tail of a linked list,
-- both the O(n) walk-to-the-end way and the O(1) way using a Tail pointer.
-- Follows the same hand-authored visual/HTML conventions as V8/V10.

INSERT INTO lessons (id, ordinal, icon, title_en, title_ar, description_en, description_ar) VALUES (5, 4, $q$&#128282;$q$, $q$Insert Last$q$, $q$Insert Last$q$, $q$Adding a node to the end of a linked list two ways: the classic O(n) walk, and the O(1) trick every real-world implementation uses &mdash; a Tail pointer.$q$, $q$إضافة Node في آخر الـ Linked List بطريقتين: المشي الكلاسيكي O(n)، والحيلة اللي كل تطبيق حقيقي بيستخدمها عشان تبقى O(1) &mdash; الـ Tail Pointer.$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 0, $q$Operation$q$, $q$عملية$q$, $q$Insert Last: adding to the end$q$, $q$Insert Last: الإضافة في آخر القائمة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-6 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Before</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Goal: insert 40 at the end</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-1 bg-teal-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-teal-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Here's our linked list: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; NULL</code>.</p>
         <p>We want to add <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">40</code> at the very end, so it becomes <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40 &rarr; NULL</code>.</p>
         <p>We'll explain it two ways: the classic way first, and then a much faster way using an extra pointer.</p>$q$, $q$<p>نفترض عندنا الـ Linked List دي: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; NULL</code>.</p>
         <p>وعايزين نضيف <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">40</code> في آخر القائمة، يعني تبقى <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40 &rarr; NULL</code>.</p>
         <p>هنشرحها بطريقتين: الطريقة الكلاسيكية الأول، وبعدين طريقة أسرع بكتير باستخدام Pointer إضافي.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 1, $q$First step$q$, $q$أول خطوة$q$, $q$Create the new node$q$, $q$أنشئ الـ Node الجديدة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">newNode</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex rounded-2xl border-[3px] border-rose-400 overflow-hidden node-3d">
            <div class="w-16 h-16 sm:w-20 sm:h-20 bg-rose-50 text-rose-600 flex items-center justify-center font-bold text-sm border-r-2 border-rose-400">40</div>
            <div class="w-16 h-16 sm:w-20 sm:h-20 bg-white text-rose-400 flex items-center justify-center font-mono font-bold text-xs">NULL</div>
        </div>
    </div>
    </div>$q$, $q$<p>First step, same as always: create the new node.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* newNode = new Node(40);</div>
         <p>Notice its <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> from the start &mdash; because this node is going to be the last one, and the last node always points at nothing.</p>$q$, $q$<p>أول خطوة، زي العادة: اعملي Node جديدة.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* newNode = new Node(40);</div>
         <p>لاحظي إن الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> بتاعها <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> من الأول &mdash; لأنها هتبقى آخر Node، وآخر Node دايمًا بتشاور على مفيش حاجة.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 2, $q$Key question$q$, $q$سؤال مهم$q$, $q$How do we reach the last node?$q$, $q$إزاي نوصل لآخر Node؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Head only points here</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Key question: how do we actually reach the last node?</p>
         <p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> only points at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code>. It has no idea where <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">30</code> is &mdash; there's no shortcut. We have to walk there ourselves.</p>$q$, $q$<p>سؤال مهم: إزاي هنوصل لآخر Node فعليًا؟</p>
         <p>الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> بس. مش عارف <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">30</code> فين &mdash; مفيش طريق مختصر. لازم نمشي بنفسنا.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 3, $q$Setup$q$, $q$تجهيز$q$, $q$Start a current pointer at Head$q$, $q$ابدأ current من عند Head$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2 gap-1">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="relative flex flex-col items-center animate-bounce-subtle" style="animation-delay:0.1s">
        <div class="bg-teal-500 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">current</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-teal-500 mt-0.5"></div>
    </div>
            <div class="w-0 h-2"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>We'll use the exact same technique from Traversal: a <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> pointer that starts at Head and walks forward, one node at a time.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* current = Head;</div>$q$, $q$<p>هنستخدم نفس فكرة درس Traversal بالظبط: Pointer اسمه <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> بيبدأ من عند Head ويمشي خطوة خطوة.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* current = Head;</div>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 4, $q$Walking$q$, $q$المشي$q$, $q$Walk until current-&gt;next is NULL$q$, $q$امشِ لحد ما current-&gt;next تبقى NULL$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center">
            <span class="text-[10px] font-bold text-gray-400 mb-1">1</span>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        </div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="flex flex-col items-center">
            <span class="text-[10px] font-bold text-gray-400 mb-1">2</span>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        </div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-teal-500 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">current</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-teal-500 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="flex flex-col items-center">
            <span class="text-[10px] font-bold text-gray-400 mb-1">stop</span>
            <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
        </div>
    </div>
    </div>$q$, $q$<p>At each node, we ask one question: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current-&gt;next == NULL</code>? If the answer is no, there's more list ahead, so we move on: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current = current-&gt;next;</code>.</p>
         <p>We keep asking and moving until the answer is finally yes &mdash; that's the moment <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> is sitting on the very last node.</p>$q$, $q$<p>عند كل Node، بنسأل سؤال واحد: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current-&gt;next == NULL</code>؟ لو الإجابة لأ، يبقى فيه قائمة لسه قدامنا، فنكمل: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current = current-&gt;next;</code>.</p>
         <p>بنفضل نسأل ونمشي لحد ما الإجابة تبقى آه أخيرًا &mdash; دي اللحظة اللي الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> بيبقى واقف عند آخر Node بالظبط.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 5, $q$Connect$q$, $q$وصّل$q$, $q$Link current to the new node$q$, $q$وصّل current بالـ Node الجديدة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-teal-500 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">current</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-teal-500 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> is now standing on <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">30</code>, the last node. Time to connect it:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">current-&gt;next = newNode;</div>
         <p>And since <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode.next</code> was already <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>, the list is now correctly terminated: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40 &rarr; NULL</code>. Done.</p>$q$, $q$<p>الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> دلوقتي واقف عند <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">30</code>، آخر Node. وقت الربط:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">current-&gt;next = newNode;</div>
         <p>وبما إن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode.next</code> كانت أصلاً <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>، القائمة بقت منتهية صح: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40 &rarr; NULL</code>. خلصنا.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 6, $q$Code$q$, $q$الكود$q$, $q$InsertLast &mdash; the full function$q$, $q$InsertLast &mdash; الكود الكامل$q$, $q$<div class="code-cpp bg-[#1E1E2E] rounded-xl p-5 shadow-inner border border-gray-800 font-mono text-[13px] text-gray-300 leading-relaxed overflow-x-auto my-4" dir="ltr"><pre class="m-0"><code>void InsertLast(int value)
{
    <span class="text-brand-purple">Node*</span> newNode = new Node(value);

    if (Head == NULL)
    {
        Head = newNode;
        return;
    }

    <span class="text-brand-purple">Node*</span> current = Head;

    while (current-&gt;next != NULL)
    {
        current = current-&gt;next;
    }

    current-&gt;next = newNode;
}</code></pre></div><div class="code-java bg-[#1E1E2E] rounded-xl p-5 shadow-inner border border-gray-800 font-mono text-[13px] text-gray-300 leading-relaxed overflow-x-auto my-4" dir="ltr"><pre class="m-0"><code>void insertLast(int value) {
    <span class="text-brand-purple">Node</span> newNode = new Node(value);

    if (head == null) {
        head = newNode;
        return;
    }

    <span class="text-brand-purple">Node</span> current = head;

    while (current.next != null) {
        current = current.next;
    }

    current.next = newNode;
}</code></pre></div>$q$, $q$<p>Put together, <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">InsertLast</code> looks like this:</p>
         <p>An empty-list check, then a walk to the end, then one link.</p>$q$, $q$<p>لما نجمعها كلها، <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">InsertLast</code> بتبقى كده:</p>
         <p>تأكد إن القائمة مش فاضية، بعدين مشي لآخرها، بعدين ربط واحد.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 7, $q$Edge case$q$, $q$حالة خاصة$q$, $q$Why check if Head == NULL?$q$, $q$ليه بنتأكد الأول إن Head == NULL؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Before: empty list</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">After InsertLast(40)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Why check <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head == NULL</code> first?</p>
         <p>Because the list might be empty. If it is, the new node isn't just the last node &mdash; it's the <em>only</em> node, so it's the first node too.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">if (Head == NULL) { Head = newNode; return; }</div>
         <p>Skip this check, and the walking loop below would crash trying to read <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head-&gt;next</code> on a <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> Head.</p>$q$, $q$<p>ليه بنتأكد الأول إن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head == NULL</code>؟</p>
         <p>لأن القائمة ممكن تكون فاضية. لو فاضية، الـ Node الجديدة مش بس آخر Node &mdash; هي كمان <em>أول</em> Node، يعني هي الوحيدة.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">if (Head == NULL) { Head = newNode; return; }</div>
         <p>لو تخطينا الشرط ده، حلقة المشي اللي بعده هتعمل Crash وهي بتحاول تقرا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head-&gt;next</code> والـ Head أصلاً NULL.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 8, $q$Common trap$q$, $q$فخ شائع$q$, $q$Why current-&gt;next, not current?$q$, $q$ليه current-&gt;next، مش current؟$q$, $q$<div class="visual-box bg-gray-50 border border-emerald-200 rounded-xl p-5 sm:p-6 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-emerald-200 px-3 py-1 rounded-md text-[10px] font-bold text-emerald-600 uppercase tracking-wider shadow-sm">Correct: while (current-&gt;next != NULL)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-teal-500 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">current</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-teal-500 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
        <div class="text-center text-[11px] font-bold text-emerald-600 mt-3 uppercase tracking-wider">current stops ON the last node</div>
    </div>
    <div class="visual-box bg-gray-50 border border-rose-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-rose-200 px-3 py-1 rounded-md text-[10px] font-bold text-rose-500 uppercase tracking-wider shadow-sm">Wrong: while (current != NULL)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-rose-500 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">current</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-rose-500 mt-0.5"></div>
    </div>
            <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-rose-300 flex items-center justify-center text-rose-400 font-bold bg-white flex-shrink-0">∅</div>
        </div>
    </div>
        <div class="text-center text-[11px] font-bold text-rose-500 mt-3 uppercase tracking-wider">current-&gt;next now crashes &mdash; nothing there to read</div>
    </div>$q$, $q$<p>Focus here &mdash; this one trips people up in interviews.</p>
         <p>We want <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> to stop <strong>at</strong> the last node, not <em>after</em> it.</p>
         <p>If we'd written <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while (current != NULL)</code> instead, the loop would run one extra time and leave <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> sitting on <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>. Then <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current-&gt;next</code> would crash the program.</p>
         <p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while (current-&gt;next != NULL)</code> stops one step earlier &mdash; exactly where we need it.</p>$q$, $q$<p>ركزي هنا &mdash; النقطة دي بتوقع ناس كتير في المقابلات.</p>
         <p>إحنا عايزين الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> يوقف <strong>عند</strong> آخر Node، مش <em>بعدها</em>.</p>
         <p>لو كتبنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while (current != NULL)</code> بدالها، الحلقة هتلف مرة زيادة وتسيب الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> واقف على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>. وساعتها <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current-&gt;next</code> هتعمل Crash للبرنامج.</p>
         <p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while (current-&gt;next != NULL)</code> بتوقف خطوة قبلها &mdash; بالظبط المكان اللي محتاجينه.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 9, $q$Worked example$q$, $q$مثال عملي$q$, $q$Let's trace an example$q$, $q$نتابع مثال خطوة بخطوة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Before</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">8</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">12</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">After: insert 20</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">8</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">12</div>
        <div class="w-8 sm:w-10 h-1 bg-teal-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-teal-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Let's trace it. List: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 8 &rarr; 12</code>, and we want to insert <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code> at the end.</p>
         <p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> checks <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>, then <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">8</code>, then reaches <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12</code> &mdash; where <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12.next == NULL</code> is finally true.</p>
         <p>So: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12.next = newNode;</code>, giving us <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 8 &rarr; 12 &rarr; 20</code>.</p>$q$, $q$<p>نتابعها. القائمة: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 8 &rarr; 12</code>، وعايزين نضيف <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code> في الآخر.</p>
         <p>الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">current</code> بيفحص <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>، بعدين <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">8</code>، وبعدين يوصل لـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12</code> &mdash; واللي فيها <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12.next == NULL</code> أخيرًا بتبقى صح.</p>
         <p>يبقى: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">12.next = newNode;</code>، وتبقى النتيجة <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 8 &rarr; 12 &rarr; 20</code>.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 10, $q$Complexity$q$, $q$التعقيد الزمني$q$, $q$Why is this O(n)?$q$, $q$ليه العملية O(n)؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-8 mb-2 shadow-sm text-center">
        <div class="inline-flex items-center justify-center w-24 h-24 rounded-2xl bg-amber-50 border-[3px] border-amber-400 text-amber-600 font-mono font-bold text-2xl mb-3">O(n)</div>
        <div class="text-xs font-bold text-gray-400 uppercase tracking-wider">Scales with list size</div>
    </div>$q$, $q$<p>With 3 nodes, we walk 3 steps. With 100 nodes, 100 steps. With a million nodes, a million steps.</p>
         <p>The walk always scales with the size of the list, so the time complexity is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(n)</code>.</p>$q$, $q$<p>لو عندنا ٣ Nodes، هنمشي ٣ خطوات. لو ١٠٠ Node، ١٠٠ خطوة. لو مليون Node، هنلف مليون مرة.</p>
         <p>المشي دايمًا بيكبر مع حجم القائمة، يبقى الزمن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(n)</code>.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 11, $q$The trick$q$, $q$الحل$q$, $q$Meet the Tail pointer$q$, $q$نتعرف على الـ Tail$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-blue-600 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Tail</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-blue-600 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>So why do some people say inserting at the end is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code>? Because their linked list keeps an extra pointer &mdash; a <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Tail</code> &mdash; that always points directly at the last node.</p>
         <p>No searching required: the list already knows exactly where its own end is.</p>$q$, $q$<p>طب ليه بعض الناس بتقول إن الإضافة في الآخر <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code>؟ لأن الـ Linked List بتاعتهم فيها Pointer إضافي &mdash; اسمه <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Tail</code> &mdash; بيشاور دايمًا مباشرة على آخر Node.</p>
         <p>مفيش بحث محتاجينه: القائمة أصلاً عارفة آخرها فين بالظبط.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 12, $q$Operation$q$, $q$عملية$q$, $q$Insert Last, with a Tail pointer$q$, $q$Insert Last باستخدام Tail$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Step 1: Tail-&gt;next = newNode</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-blue-600 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Tail</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-blue-600 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Step 2: Tail = newNode (final)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center animate-bounce-subtle mb-1">
        <div class="bg-blue-600 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Tail</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-blue-600 mt-0.5"></div>
    </div>
            <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        </div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>With a Tail pointer, inserting at the end takes just two lines &mdash; the exact same "connect, then move the pointer" pattern from Insert First, just at the other end of the list.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Tail-&gt;next = newNode;</div>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Tail = newNode;</div>$q$, $q$<p>باستخدام Tail، الإضافة في الآخر بتاخد سطرين بس &mdash; نفس نمط "وصّل، وبعدين حرّك الـ Pointer" اللي اتعلمناه في Insert First، بس في الطرف التاني من القائمة.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Tail-&gt;next = newNode;</div>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Tail = newNode;</div>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 13, $q$Complexity$q$, $q$التعقيد الزمني$q$, $q$No loop needed &mdash; O(1)$q$, $q$من غير Loop &mdash; O(1)$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-8 mb-2 shadow-sm text-center">
        <div class="inline-flex items-center justify-center w-24 h-24 rounded-2xl bg-emerald-50 border-[3px] border-emerald-400 text-emerald-600 font-mono font-bold text-2xl mb-3">O(1)</div>
        <div class="text-xs font-bold text-gray-400 uppercase tracking-wider">Constant time &mdash; no walking</div>
    </div>$q$, $q$<p>No loop. No <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while</code>. No search.</p>
         <p>Just two pointer updates, no matter how long the list is: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code>.</p>$q$, $q$<p>من غير Loop. من غير <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">while</code>. من غير بحث.</p>
         <p>مجرد تحديث لسطرين، مهما كانت القائمة طويلة: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code>.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 14, $q$Why it matters$q$, $q$ليه ده مهم$q$, $q$Why most linked lists keep a Tail$q$, $q$ليه معظم الـ Linked Lists فيها Tail$q$, $q$<div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-2">
        <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4 text-center">
            <div class="text-2xl mb-1">&#10133;</div>
            <div class="text-xs font-bold text-emerald-600 uppercase tracking-wider">Add Last</div>
        </div>
        <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4 text-center">
            <div class="text-2xl mb-1">&#128229;</div>
            <div class="text-xs font-bold text-emerald-600 uppercase tracking-wider">Enqueue</div>
        </div>
        <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4 text-center">
            <div class="text-2xl mb-1">&#128230;</div>
            <div class="text-xs font-bold text-emerald-600 uppercase tracking-wider">Push Back</div>
        </div>
    </div>$q$, $q$<p>This is why most real-world linked list implementations keep a Tail pointer &mdash; it makes several common operations instant:</p>
         <p><strong>Add Last</strong>, <strong>Enqueue</strong> (in a Queue), and <strong>Push Back</strong> are really all the same operation wearing different names &mdash; and all of them become <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code> with a Tail.</p>$q$, $q$<p>عشان كده معظم تطبيقات الـ Linked List الحقيقية بتحتفظ بـ Tail Pointer &mdash; بيخلي كذا عملية شائعة فورية:</p>
         <p><strong>Add Last</strong>، و<strong>Enqueue</strong> (في الـ Queue)، و<strong>Push Back</strong> كلهم في الحقيقة نفس العملية بأسامي مختلفة &mdash; وكلهم بيبقوا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code> مع الـ Tail.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 15, $q$Comparison$q$, $q$مقارنة$q$, $q$Without Tail vs. with Tail$q$, $q$بدون Tail مقابل مع Tail$q$, $q$<div class="bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 overflow-x-auto">
        <table class="w-full text-sm min-w-[420px]">
            <thead>
                <tr class="text-gray-400 text-xs uppercase">
                    <th class="text-left pb-2 pr-4"></th>
                    <th class="text-left pb-2 pr-4">Without Tail</th>
                    <th class="text-left pb-2">With Tail</th>
                </tr>
            </thead>
            <tbody class="text-gray-700">
                <tr class="border-t border-gray-200">
                    <td class="py-2 pr-4 font-bold text-gray-500">To reach the end</td>
                    <td class="py-2 pr-4">Walk from Head</td>
                    <td class="py-2">Go directly to Tail</td>
                </tr>
                <tr class="border-t border-gray-200">
                    <td class="py-2 pr-4 font-bold text-gray-500">Needs a loop?</td>
                    <td class="py-2 pr-4 font-mono">while</td>
                    <td class="py-2 text-emerald-600 font-bold">No</td>
                </tr>
                <tr class="border-t border-gray-200">
                    <td class="py-2 pr-4 font-bold text-gray-500">Time complexity</td>
                    <td class="py-2 pr-4 font-mono font-bold text-amber-600">O(n)</td>
                    <td class="py-2 font-mono font-bold text-emerald-600">O(1)</td>
                </tr>
            </tbody>
        </table>
    </div>$q$, $q$<p>Side by side, the difference is stark:</p>$q$, $q$<p>جنب بعض، الفرق واضح جدًا:</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (5, 16, $q$Summary$q$, $q$ملخص$q$, $q$Insert Last &mdash; two ways to do it$q$, $q$Insert Last &mdash; بطريقتين$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 mb-3 shadow-sm">
        <div class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Without Tail &mdash; O(n)</div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-gray-400 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">1</div><div class="text-xs text-gray-600 pt-0.5">Create a new node</div></div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-gray-400 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">2</div><div class="text-xs text-gray-600 pt-0.5">If Head == NULL, set Head = newNode</div></div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-gray-400 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">3</div><div class="text-xs text-gray-600 pt-0.5">Start current at Head</div></div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-gray-400 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">4</div><div class="text-xs text-gray-600 pt-0.5">Walk while current-&gt;next != NULL</div></div>
        <div class="flex items-start gap-2"><div class="w-5 h-5 rounded-full bg-gray-400 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">5</div><div class="text-xs text-gray-600 pt-0.5">Set current-&gt;next = newNode</div></div>
    </div>
    <div class="visual-box bg-emerald-50 border border-emerald-200 rounded-xl p-5 mb-4 shadow-sm">
        <div class="text-xs font-bold text-emerald-600 uppercase tracking-wider mb-3">With Tail &mdash; O(1)</div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">1</div><div class="text-xs text-emerald-800 pt-0.5">Create a new node</div></div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">2</div><div class="text-xs text-emerald-800 pt-0.5">If empty, set Head = Tail = newNode</div></div>
        <div class="flex items-start gap-2 mb-2"><div class="w-5 h-5 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">3</div><div class="text-xs text-emerald-800 pt-0.5">Set Tail-&gt;next = newNode</div></div>
        <div class="flex items-start gap-2"><div class="w-5 h-5 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">4</div><div class="text-xs text-emerald-800 pt-0.5">Update Tail = newNode</div></div>
    </div>
    <div class="visual-box bg-brand-light/40 border border-brand-purple/20 rounded-xl p-5 sm:p-6 mb-2 text-center">
        <div class="text-2xl mb-2">&#128260;</div>
        <div class="text-sm font-bold text-brand-dark">Coming next: Insert After &amp; Insert Before</div>
    </div>$q$, $q$<p>Two ways to insert at the end &mdash; pick based on whether your list keeps a Tail pointer.</p>
         <p>Next up: <strong>Insert After</strong> and <strong>Insert Before</strong> &mdash; and why "before" is the trickier one in a singly linked list.</p>$q$, $q$<p>طريقتين للإضافة في الآخر &mdash; اختاري حسب لو القائمة بتاعتك فيها Tail Pointer ولا لأ.</p>
         <p>الدرس الجاي: <strong>Insert After</strong> و<strong>Insert Before</strong> &mdash; وهتفهمي ليه "before" أصعب في الـ Singly Linked List.</p>$q$);

SELECT setval(pg_get_serial_sequence('lessons', 'id'), (SELECT MAX(id) FROM lessons));
