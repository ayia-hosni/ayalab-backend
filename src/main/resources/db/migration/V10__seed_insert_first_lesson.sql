-- Seeds Lesson 3: "Insert First" — inserting a node at the head of a linked list.
-- Follows the same hand-authored visual/HTML conventions as V8 (predates the visual_spec builder).

INSERT INTO lessons (id, ordinal, icon, title_en, title_ar, description_en, description_ar) VALUES (4, 3, $q$&#10133;$q$, $q$Insert First$q$, $q$Insert First$q$, $q$How to add a new node at the very beginning of a linked list in constant time &mdash; and the exact order of pointer updates that makes it work safely.$q$, $q$إزاي تضيف Node جديدة في أول الـ Linked List بزمن ثابت O(1) &mdash; وترتيب تحديث الـ Pointers اللي لازم تتبعه عشان العملية تنجح من غير ما تضيع القائمة.$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 0, $q$Operation$q$, $q$عملية$q$, $q$Insert First: adding to the front$q$, $q$Insert First: الإضافة في أول القائمة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-6 shadow-sm relative overflow-x-auto">
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
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Goal: insert 5 at the front</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Here's our linked list: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; NULL</code>, with <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> pointing at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code>.</p>
         <p>We want to add <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> at the very beginning, so it becomes <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 10 &rarr; 20 &rarr; 30 &rarr; NULL</code>.</p>
         <p>Let's build this from scratch, one pointer update at a time &mdash; as if we were doing it with our own hands.</p>$q$, $q$<p>نفترض عندنا الـ Linked List دي: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; NULL</code>، والـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code>.</p>
         <p>وعايزين نضيف <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> في أول القائمة، يعني النتيجة تبقى: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 10 &rarr; 20 &rarr; 30 &rarr; NULL</code>.</p>
         <p>هنفهمها من أولها خالص، خطوة خطوة، كأننا إحنا اللي بنبنيها بإيدينا.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 1, $q$First question$q$, $q$أول سؤال$q$, $q$Where do we put the new node?$q$, $q$هنحط الـ Node الجديدة فين؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-4 shadow-sm relative overflow-x-auto">
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
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Heap &mdash; freshly allocated</div>
        <div class="flex items-center justify-center gap-3 min-w-max py-2">
        <div class="flex rounded-2xl border-[3px] border-rose-400 overflow-hidden node-3d">
            <div class="w-14 h-14 sm:w-16 sm:h-16 bg-rose-50 text-rose-600 flex items-center justify-center font-bold text-sm border-r-2 border-rose-400">5</div>
            <div class="w-14 h-14 sm:w-16 sm:h-16 bg-white text-rose-400 flex items-center justify-center font-mono font-bold text-xs">?</div>
        </div>
        <span class="text-xs font-mono text-gray-400">newNode</span>
    </div>
    </div>$q$, $q$<p>First question: where does the new node actually live?</p>
         <p>On the <strong>Heap</strong> &mdash; because every node in a linked list is created dynamically:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* newNode = new Node(value);</div>
         <p>Right now, memory looks like this: our existing list <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30</code> is untouched, and a brand-new, disconnected node sits on the heap with <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Data = 5</code> and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Next = ?</code>.</p>$q$, $q$<p>أول سؤال: إحنا هنحط الـ Node الجديدة فين؟</p>
         <p>في الـ <strong>Heap</strong> &mdash; لأن كل الـ Nodes في الـ Linked List بتتعمل Dynamic:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Node* newNode = new Node(value);</div>
         <p>دلوقتي الذاكرة بقت كده: القائمة القديمة <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30</code> زي ما هي، وجنبها Node جديدة لسه مش متوصلة، جواها <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Data = 5</code> و <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Next = ؟</code>.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 2, $q$Key question$q$, $q$سؤال مهم$q$, $q$Where should Next point?$q$, $q$الـ Next يشاور على مين؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
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
    </div>$q$, $q$<p>Key question: who should <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Next</code> point to?</p>
         <p>Since we're inserting at the front, whatever used to be first &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> &mdash; must now come right after <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>. So:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">newNode-&gt;next = Head;</div>
         <p>We're saying: <em>"make the new node point to whatever the old first node was."</em> Notice that <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> itself still points at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> &mdash; we haven't touched it yet.</p>$q$, $q$<p>سؤال مهم: الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Next</code> يشاور على مين؟</p>
         <p>بما إننا بنضيف في الأول، يبقى اللي كان أول واحدة &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> &mdash; لازم يبقى بعد الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> دلوقتي. يبقى:</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">newNode-&gt;next = Head;</div>
         <p>يعني إحنا بنقول: <em>"خلي الـ Node الجديدة تشاور على أول Node قديمة."</em> لاحظ إن الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> لسه بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> &mdash; إحنا لسه ما لمسناهوش.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 3, $q$Final step$q$, $q$الخطوة الثانية$q$, $q$Move Head to the new node$q$, $q$حرّك الـ Head للـ Node الجديدة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>The list itself already looks connected &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 10 &rarr; 20 &rarr; 30</code> &mdash; but <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> hasn't moved yet, so as far as the program is concerned, the list still starts at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code>.</p>
         <p>Last step: make <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> point to the new node.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Head = newNode;</div>
         <p>Now the list officially starts at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>. Done.</p>$q$, $q$<p>القائمة نفسها بقت متوصلة &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5 &rarr; 10 &rarr; 20 &rarr; 30</code> &mdash; بس الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> لسه ما تحركش، يعني بالنسبة للبرنامج القائمة لسه بادئة من <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code>.</p>
         <p>الخطوة الأخيرة: خلي الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> يشاور على الـ Node الجديدة.</p>
         <div class="bg-gray-900 text-white rounded-xl p-4 font-mono text-sm my-3" dir="ltr">Head = newNode;</div>
         <p>دلوقتي القائمة رسميًا بادئة من <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>. خلصنا.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 4, $q$Common trap$q$, $q$فخ شائع$q$, $q$Why does the order matter?$q$, $q$ليه الترتيب مهم جدًا؟$q$, $q$<div class="visual-box bg-gray-50 border border-rose-200 rounded-xl p-5 sm:p-8 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-rose-200 px-3 py-1 rounded-md text-[10px] font-bold text-rose-500 uppercase tracking-wider shadow-sm">Step 1 (wrong): Head = newNode</div>
        <div class="flex items-center justify-center gap-6 min-w-max py-2">
        <div class="flex items-center gap-0">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        </div>
        <div class="w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="flex items-center gap-0 opacity-40">
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">?</div>
        <div class="w-8 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-gray-300 bg-gray-100 text-gray-400 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-gray-300 bg-gray-100 text-gray-400 flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-gray-300 bg-gray-100 text-gray-400 flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        </div>
    </div>
        <div class="text-center text-[11px] font-bold text-rose-500 mt-3 uppercase tracking-wider">10 &rarr; 20 &rarr; 30 is now unreachable</div>
    </div>
    <div class="visual-box bg-gray-50 border border-rose-200 rounded-xl p-5 sm:p-8 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-rose-200 px-3 py-1 rounded-md text-[10px] font-bold text-rose-500 uppercase tracking-wider shadow-sm">Step 2 (wrong): newNode-&gt;next = Head</div>
        <div class="flex items-center justify-center gap-2 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="text-2xl text-rose-400 font-bold ml-1">&#8635;</div>
        </div>
        <div class="text-center text-[11px] font-bold text-rose-500 mt-3 uppercase tracking-wider">5.next now points to itself</div>
    </div>$q$, $q$<p>Order matters here &mdash; a lot. Watch what happens if we flip the two lines and do <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> first.</p>
         <p><strong>Step 1 (wrong):</strong> the moment we move <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code>, it now points only at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>. Nothing points at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> anymore &mdash; the rest of the list, <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30</code>, is instantly unreachable. It's still sitting in memory, but we've lost every way of getting to it.</p>
         <p><strong>Step 2 (wrong):</strong> now if we run <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code>, <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> is currently <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> &mdash; so we're really saying <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5.next = 5</code>. The new node ends up pointing at itself.</p>$q$, $q$<p>الترتيب هنا مهم جدًا. خلينا نشوف هيحصل إيه لو عكسنا السطرين وعملنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> الأول.</p>
         <p><strong>الخطوة ١ (غلط):</strong> في اللحظة اللي نحرك فيها الـ Head، هيبقى بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> بس. محدش بقى بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> &mdash; يعني باقي القائمة <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30</code> ضاعت فورًا. لسه موجودة في الذاكرة، بس مفيش أي طريقة نوصلها بيها.</p>
         <p><strong>الخطوة ٢ (غلط):</strong> دلوقتي لو عملنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code>، الـ Head بقى بيساوي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> &mdash; يعني إحنا فعليًا بنقول <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5.next = 5</code>. الـ Node الجديدة بقت بتشاور على نفسها.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 5, $q$Golden rule$q$, $q$القاعدة الذهبية$q$, $q$Connect first, then move Head$q$, $q$وصّل الأول، وبعدين حرّك الـ Head$q$, $q$<div class="visual-box bg-emerald-50 border border-emerald-200 rounded-xl p-6 mb-2 shadow-sm">
        <div class="flex items-start gap-3 mb-4">
        <div class="w-7 h-7 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">1</div>
        <div class="text-sm font-mono text-emerald-800 pt-1" dir="ltr">newNode-&gt;next = Head;</div>
    </div>
        <div class="flex items-start gap-3">
        <div class="w-7 h-7 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">2</div>
        <div class="text-sm font-mono text-emerald-800 pt-1" dir="ltr">Head = newNode;</div>
    </div>
    </div>$q$, $q$<p>So remember this rule &mdash; it's the foundation of every linked list operation:</p>
         <p><strong>Connect the new node to the old list first. Only then move Head.</strong></p>
         <p>As long as you follow that order, you can never lose a node.</p>$q$, $q$<p>يبقى احفظي القاعدة دي &mdash; هي أساس كل عمليات الـ Linked List:</p>
         <p><strong>وصّلي الـ Node الجديدة بالقائمة القديمة الأول، وبعدين بس حرّكي الـ Head.</strong></p>
         <p>طول ما بتتبعي الترتيب ده، مستحيل تضيعي أي Node.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 6, $q$Code$q$, $q$الكود$q$, $q$InsertFirst &mdash; the full function$q$, $q$InsertFirst &mdash; الكود الكامل$q$, $q$<div class="code-cpp bg-[#1E1E2E] rounded-xl p-5 shadow-inner border border-gray-800 font-mono text-[13px] text-gray-300 leading-relaxed overflow-x-auto my-4" dir="ltr"><pre class="m-0"><code>void InsertFirst(int value)
{
    <span class="text-brand-purple">Node*</span> newNode = new Node(value);

    newNode-&gt;next = Head;

    Head = newNode;
}</code></pre></div><div class="code-java bg-[#1E1E2E] rounded-xl p-5 shadow-inner border border-gray-800 font-mono text-[13px] text-gray-300 leading-relaxed overflow-x-auto my-4" dir="ltr"><pre class="m-0"><code>void insertFirst(int value) {
    <span class="text-brand-purple">Node</span> newNode = new Node(value);

    newNode.next = head;

    head = newNode;
}</code></pre></div>$q$, $q$<p>Put it all together, and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">InsertFirst</code> is just three lines:</p>
         <p>Create the node, link it to the old head, then move Head. That's the entire operation.</p>$q$, $q$<p>لما نجمع كل حاجة مع بعض، <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">InsertFirst</code> بتبقى ٣ أسطر بس:</p>
         <p>اعملي الـ Node، وصّليها بالـ Head القديم، وبعدين حرّكي الـ Head. دي العملية كلها.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 7, $q$Code$q$, $q$الكود$q$, $q$Line by line$q$, $q$سطر سطر$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm">
        <div class="flex items-start gap-3 mb-4 pb-4 border-b border-gray-200">
        <div class="font-mono text-xs text-gray-400 pt-0.5 flex-shrink-0">1</div>
        <div class="font-mono text-sm text-brand-dark" dir="ltr"><span class="code-cpp">Node* newNode = new Node(value);</span><span class="code-java">Node newNode = new Node(value);</span></div>
    </div>
        <div class="flex items-start gap-3 mb-4 pb-4 border-b border-gray-200">
        <div class="font-mono text-xs text-gray-400 pt-0.5 flex-shrink-0">2</div>
        <div class="font-mono text-sm text-brand-dark" dir="ltr"><span class="code-cpp">newNode-&gt;next = Head;</span><span class="code-java">newNode.next = head;</span></div>
    </div>
        <div class="flex items-start gap-3">
        <div class="font-mono text-xs text-gray-400 pt-0.5 flex-shrink-0">3</div>
        <div class="font-mono text-sm text-brand-dark" dir="ltr"><span class="code-cpp">Head = newNode;</span><span class="code-java">head = newNode;</span></div>
    </div>
    </div>$q$, $q$<p>Line by line:</p>
         <ol class="list-decimal list-inside space-y-1 my-3">
            <li>Allocate a new node on the heap holding our value.</li>
            <li>Point its <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> at whatever used to be the first node.</li>
            <li>Move <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> to start from the new node.</li>
         </ol>
         <p>Three lines. No loop. No visiting any other node.</p>$q$, $q$<p>سطر سطر:</p>
         <ol class="list-decimal list-inside space-y-1 my-3">
            <li>اعملي Node جديدة في الـ Heap فيها القيمة بتاعتنا.</li>
            <li>خلي الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> بتاعها يشاور على اللي كانت أول واحدة.</li>
            <li>حرّكي الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> يبدأ من الـ Node الجديدة.</li>
         </ol>
         <p>٣ أسطر بس. من غير Loop. من غير ما نعدي على أي Node تانية.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 8, $q$Complexity$q$, $q$التعقيد الزمني$q$, $q$Why is this O(1)?$q$, $q$ليه العملية O(1)؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-8 mb-2 shadow-sm text-center">
        <div class="inline-flex items-center justify-center w-24 h-24 rounded-2xl bg-emerald-50 border-[3px] border-emerald-400 text-emerald-600 font-mono font-bold text-2xl mb-3">O(1)</div>
        <div class="text-xs font-bold text-gray-400 uppercase tracking-wider">Constant time &mdash; any list size</div>
    </div>$q$, $q$<p>Did we loop over the list? No. Did we need to visit any existing node? No.</p>
         <p>So the time complexity is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code> &mdash; constant time, no matter how many elements are already in the list.</p>
         <p>This is one of the biggest advantages of a linked list: inserting at the front is always instant.</p>$q$, $q$<p>هل لفينا على القائمة؟ لأ. هل احتجنا نعدي على أي Node موجودة؟ لأ.</p>
         <p>يبقى الزمن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">O(1)</code> &mdash; زمن ثابت، مهما كان حجم القائمة.</p>
         <p>وده من أكبر مميزات الـ Linked List: الإضافة في البداية ثابتة مهما كانت القائمة كبيرة قد إيه.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 9, $q$Edge case$q$, $q$حالة خاصة$q$, $q$What about an empty list?$q$, $q$ولو القائمة كانت فاضية؟$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-8 mb-4 shadow-sm relative overflow-x-auto">
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
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">After InsertFirst(5)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">5</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>What if the list is empty to begin with &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = NULL</code>?</p>
         <p>The exact same code still works. <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code> just sets <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> to <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>, and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> makes it the one and only node.</p>
         <p>No special case needed &mdash; that's a nice sign the logic is genuinely correct, not just a lucky coincidence for the example we picked.</p>$q$, $q$<p>طيب لو القائمة أصلاً فاضية &mdash; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = NULL</code>؟</p>
         <p>نفس الكود بالظبط شغال. <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code> هتخلي الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> يبقى <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> هتخليها هي الـ Node الوحيدة.</p>
         <p>مفيش أي حالة خاصة محتاجين نتعامل معاها &mdash; وده مؤشر كويس إن المنطق صح فعلاً، مش مجرد صدفة حصلت مع المثال اللي اخترناه.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 10, $q$Worked example$q$, $q$مثال عملي$q$, $q$Let's trace through an example$q$, $q$نتابع مثال خطوة بخطوة$q$, $q$<div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Before</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-4 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Step 1: 10.next = 20</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>
    <div class="visual-box bg-gray-50 border border-gray-200 rounded-xl p-5 sm:p-6 mb-2 shadow-sm relative overflow-x-auto">
        <div class="absolute -top-3 left-4 bg-white border border-gray-200 px-3 py-1 rounded-md text-[10px] font-bold text-gray-500 uppercase tracking-wider shadow-sm">Step 2: Head = 10 (final)</div>
        <div class="flex items-center justify-center gap-0 min-w-max py-2">
        <div class="flex flex-col items-center mr-2">
            <div class="relative flex flex-col items-center animate-bounce-subtle">
        <div class="bg-gray-900 text-white font-bold text-[10px] px-2.5 py-1 rounded shadow-sm uppercase tracking-wider whitespace-nowrap">Head</div>
        <div class="w-0 h-0 border-x-[6px] border-x-transparent border-t-[7px] border-t-gray-900 mt-0.5"></div>
    </div>
            <div class="w-0 h-4"></div>
        </div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-rose-400 bg-rose-50 text-rose-600 flex items-center justify-center font-bold node-3d flex-shrink-0">10</div>
        <div class="w-8 sm:w-10 h-1 bg-rose-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-rose-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-orange-400 bg-orange-50 text-orange-600 flex items-center justify-center font-bold node-3d flex-shrink-0">20</div>
        <div class="w-8 sm:w-10 h-1 bg-orange-400 relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-orange-400"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-brand-purple bg-brand-light text-brand-dark flex items-center justify-center font-bold node-3d flex-shrink-0">30</div>
        <div class="w-8 sm:w-10 h-1 bg-brand-purple relative flex-shrink-0"><div class="absolute right-0 top-1/2 -translate-y-1/2 w-0 h-0 border-y-4 border-y-transparent border-l-[7px] border-l-brand-purple"></div></div>
        <div class="w-14 h-14 text-lg rounded-2xl border-[3px] border-teal-400 bg-teal-50 text-teal-600 flex items-center justify-center font-bold node-3d flex-shrink-0">40</div>
        <div class="w-8 sm:w-10 h-0 border-t-2 border-dashed border-gray-300 flex-shrink-0"></div>
        <div class="w-9 h-9 text-xs rounded-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-bold bg-white flex-shrink-0">∅</div>
    </div>
    </div>$q$, $q$<p>Let's trace a full example. Starting list: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20 &rarr; 30 &rarr; 40</code>, and we want to insert <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> at the front.</p>
         <p><strong>Step 1:</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10.next = 20</code>. The new node now points at the old first node, but <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> still points at <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code>.</p>
         <p><strong>Step 2:</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = 10</code>. The list is now <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40</code>.</p>$q$, $q$<p>نتابع مثال كامل. القائمة بادئة بـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20 &rarr; 30 &rarr; 40</code>، وعايزين نضيف <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10</code> في الأول.</p>
         <p><strong>الخطوة ١:</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10.next = 20</code>. الـ Node الجديدة بقت تشاور على أول Node قديمة، لكن الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code> لسه بيشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code>.</p>
         <p><strong>الخطوة ٢:</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = 10</code>. القائمة بقت <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">10 &rarr; 20 &rarr; 30 &rarr; 40</code>.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 11, $q$Interview tips$q$, $q$أخطاء شائعة$q$, $q$3 mistakes candidates make$q$, $q$٣ أخطاء شائعة في المقابلات$q$, $q$<div class="bg-rose-50 border border-rose-200 rounded-xl p-4 mb-3 flex items-start gap-3">
        <div class="text-xl flex-shrink-0">&#9888;&#65039;</div>
        <div class="text-xs font-bold text-rose-600 uppercase tracking-wider font-mono pt-1">Head = newNode; before linking next</div>
    </div>
    <div class="bg-rose-50 border border-rose-200 rounded-xl p-4 mb-3 flex items-start gap-3">
        <div class="text-xl flex-shrink-0">&#9888;&#65039;</div>
        <div class="text-xs font-bold text-rose-600 uppercase tracking-wider font-mono pt-1">Forgetting newNode-&gt;next = Head;</div>
    </div>
    <div class="bg-rose-50 border border-rose-200 rounded-xl p-4 flex items-start gap-3">
        <div class="text-xl flex-shrink-0">&#9888;&#65039;</div>
        <div class="text-xs font-bold text-rose-600 uppercase tracking-wider font-mono pt-1">Forgetting to update Head</div>
    </div>$q$, $q$<p><strong>1. Moving Head before linking.</strong> Setting <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> before <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code> loses the entire rest of the list.</p>
         <p><strong>2. Forgetting to set <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> at all.</strong> Without <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code>, the new node just sits there pointing at nothing &mdash; every other node becomes disconnected from it.</p>
         <p><strong>3. Forgetting to update <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code>.</strong> The list quietly stays exactly as it was, and the new node becomes an unreachable memory leak &mdash; it exists, but nothing points to it anymore.</p>$q$, $q$<p><strong>١. تحريك الـ Head قبل الربط.</strong> لو عملتي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code> قبل <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code>، هتضيعي باقي القائمة كلها.</p>
         <p><strong>٢. نسيان تحديد الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> خالص.</strong> من غير <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code>، الـ Node الجديدة هتفضل واقفة مش بتشاور على حاجة &mdash; وباقي القائمة هتبقى منفصلة عنها.</p>
         <p><strong>٣. نسيان تحديث الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head</code>.</strong> القائمة هتفضل زي ما هي من غير ما حد يحس، والـ Node الجديدة هتبقى Memory Leak &mdash; موجودة في الذاكرة، بس مفيش أي Pointer بيوصلها.</p>$q$);

INSERT INTO lesson_slides (lesson_id, ordinal, kicker_en, kicker_ar, title_en, title_ar, visual, body_en, body_ar) VALUES (4, 12, $q$Summary$q$, $q$ملخص$q$, $q$Insert First in 3 steps$q$, $q$Insert First في ٣ خطوات$q$, $q$<div class="visual-box bg-emerald-50 border border-emerald-200 rounded-xl p-6 mb-4 shadow-sm">
        <div class="flex items-start gap-3 mb-3">
        <div class="w-7 h-7 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">1</div>
        <div class="text-sm text-emerald-800 pt-1">Create a new node</div>
    </div>
        <div class="flex items-start gap-3 mb-3">
        <div class="w-7 h-7 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">2</div>
        <div class="text-sm font-mono text-emerald-800 pt-1" dir="ltr">newNode-&gt;next = Head;</div>
    </div>
        <div class="flex items-start gap-3">
        <div class="w-7 h-7 rounded-full bg-emerald-500 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">3</div>
        <div class="text-sm font-mono text-emerald-800 pt-1" dir="ltr">Head = newNode;</div>
    </div>
    </div>
    <div class="visual-box bg-brand-light/40 border border-brand-purple/20 rounded-xl p-5 sm:p-6 mb-2 text-center">
        <div class="text-2xl mb-2">&#128260;</div>
        <div class="text-sm font-bold text-brand-dark">Coming next: Insert Last &mdash; and why a Tail pointer makes it O(1) too</div>
    </div>$q$, $q$<p>Three steps, and that's the whole operation:</p>
         <ol class="list-decimal list-inside space-y-1 my-3">
            <li>Create a new node.</li>
            <li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code></li>
            <li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code></li>
         </ol>
         <p>Keep that order in mind &mdash; it's the same pattern you'll reuse for almost every linked list operation.</p>$q$, $q$<p>٣ خطوات، ودي العملية كلها:</p>
         <ol class="list-decimal list-inside space-y-1 my-3">
            <li>اعملي Node جديدة.</li>
            <li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">newNode-&gt;next = Head;</code></li>
            <li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">Head = newNode;</code></li>
         </ol>
         <p>احفظي الترتيب ده كويس &mdash; هو نفس النمط اللي هتستخدميه في كل عمليات الـ Linked List تقريبًا.</p>$q$);

SELECT setval(pg_get_serial_sequence('lessons', 'id'), (SELECT MAX(id) FROM lessons));
