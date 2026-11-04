-- Seeds the "Pointers" section and its first lesson, "Memory & Addresses": memory as numbered
-- boxes, addresses, &x vs x, and why neighbouring vs scattered boxes lead to pointers.
-- Data-only: slides are structured `memory` specs rendered by the frontend.
-- The section is placed before "Linked Lists", so existing lesson ordinals shift by 3 (this lesson
-- takes 0; the next two Pointers lessons take 1 and 2).

UPDATE lesson_sections SET ordinal = ordinal + 1;
INSERT INTO lesson_sections (slug, ordinal) VALUES ('pointers', 0);
INSERT INTO lesson_section_i18n (section_id, locale, name)
SELECT id, v.locale, v.name FROM lesson_sections, (VALUES ('en', $q$Pointers$q$), ('ar', $q$المؤشرات$q$)) AS v(locale, name)
WHERE slug = 'pointers';

INSERT INTO lesson_categories (section_id, slug, ordinal)
SELECT id, 'fundamentals', 0 FROM lesson_sections WHERE slug = 'pointers';
INSERT INTO lesson_category_i18n (category_id, locale, name)
SELECT c.id, v.locale, v.name
FROM lesson_categories c JOIN lesson_sections s ON s.id = c.section_id AND s.slug = 'pointers',
     (VALUES ('en', $q$Fundamentals$q$), ('ar', $q$الأساسيات$q$)) AS v(locale, name)
WHERE c.slug = 'fundamentals';

UPDATE lessons SET ordinal = ordinal + 3;

INSERT INTO lessons (slug, ordinal, icon, published, section_id, category_id)
SELECT 'memory-and-addresses', 0, $q$🏠$q$, TRUE, s.id, c.id
FROM lesson_sections s JOIN lesson_categories c ON c.section_id = s.id AND c.slug = 'fundamentals'
WHERE s.slug = 'pointers';

INSERT INTO lesson_i18n (lesson_id, locale, title, description)
SELECT l.id, v.locale, v.title, v.description
FROM lessons l, (VALUES
  ('en', $q$Memory & Addresses$q$, $q$Memory as numbered boxes, what an address is, and the difference between x and &x &mdash; the ground every pointer stands on.$q$),
  ('ar', $q$الذاكرة والعناوين$q$, $q$الذاكرة كصناديق مرقّمة، يعني إيه Address، والفرق بين x و &x &mdash; الأساس اللي كل Pointer واقف عليه.$q$)
) AS v(locale, title, description)
WHERE l.slug = 'memory-and-addresses';


INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 0, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "z", "address": "1008", "name": "z", "value": "100"}]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Pointers · Part 1$q$, $q$Memory: a row of numbered boxes$q$, $q$<p>Look at the picture above &mdash; that is what a program sees when it looks at memory.</p><p>Every variable lives in its own box, and every box has a number on top. We will take it piece by piece, slowly.</p>$q$),
  ('ar', $q$المؤشرات · الجزء 1$q$, $q$الذاكرة: صف من الصناديق المرقّمة$q$, $q$<p>بص على الرسمة اللي فوق &mdash; دي الذاكرة بالشكل اللي البرنامج بيشوفها بيه.</p><p>كل متغيّر (variable) ليه صندوق خاص بيه، وكل صندوق عليه رقم. هنفهمها حتة حتة وبالراحة.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 0;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 1, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "m0", "address": "1000", "color": "gray"}, {"id": "m1", "address": "1004", "color": "gray"}, {"id": "m2", "address": "1008", "color": "gray"}, {"id": "m3", "address": "1012", "color": "gray"}, {"id": "m4", "address": "1016", "color": "gray"}], "highlight": ["m2"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Addresses$q$, $q$Every box has an address$q$, $q$<p>The number above a box is its <strong>address</strong>. It is only a number that says where the box sits in memory.</p><p>Think of houses on a street: the house number is not the family inside &mdash; it only tells you where to find them.</p>$q$),
  ('ar', $q$العناوين$q$, $q$كل صندوق ليه عنوان (Address)$q$, $q$<p>الرقم اللي فوق الصندوق هو <strong>العنوان (Address)</strong>. هو مجرد رقم بيقولك الصندوق ده قاعد فين في الذاكرة.</p><p>زي أرقام البيوت في الشارع: رقم البيت مش هو الناس اللي جواه، هو بس بيقولك تلاقيهم فين.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 1;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 2, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Variables$q$, $q$A variable is a named box$q$, $q$<p>When you write <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 42;</code> the computer picks a free box, puts <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code> inside it, and remembers that the name <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> means that box.</p>$q$),
  ('ar', $q$المتغيّرات$q$, $q$المتغيّر صندوق له اسم$q$, $q$<p>لما تكتب <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 42;</code> الكمبيوتر بيختار صندوق فاضي، وبيحط فيه <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>، وبيفتكر إن الاسم <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> معناه الصندوق ده.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 2;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 3, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "z", "address": "1008", "name": "z", "value": "100"}]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Variables$q$, $q$Many variables, many boxes$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 42; int y = 7; int z = 100;</code> gives three boxes side by side.</p><p>Notice the addresses jump by <strong>4</strong>, not 1: an <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int</code> takes 4 bytes, so each one uses 4 addresses.</p>$q$),
  ('ar', $q$المتغيّرات$q$, $q$كذا متغيّر، كذا صندوق$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 42; int y = 7; int z = 100;</code> بتدّينا تلات صناديق جنب بعض.</p><p>لاحظ إن العناوين بتزيد بـ <strong>4</strong> مش بـ 1: الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int</code> بياخد 4 bytes، فكل واحد بيحجز 4 عناوين.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 3;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 4, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Operator$q$, $q$&amp;x &mdash; where is the box?$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> gives what is <em>inside</em> the box: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> gives the box's <em>address</em>: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>. Read it as &ldquo;the address of x&rdquo;.</p><p><strong>Java note:</strong> Java never shows you real addresses, but the question &ldquo;where does this object live?&rdquo; still exists. We will connect the two later.</p>$q$),
  ('ar', $q$عملية$q$, $q$&amp;x &mdash; الصندوق ده فين؟$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> بيرجّع اللي <em>جوه</em> الصندوق: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> بيرجّع <em>عنوان</em> الصندوق: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>. اقراها &laquo;عنوان x&raquo;.</p><p><strong>ملحوظة Java:</strong> الـ Java مش بتوريك العناوين الحقيقية، بس السؤال &laquo;الـ object ده قاعد فين؟&raquo; لسه موجود. هنربطهم ببعض بعدين.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 4;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 5, $q$ {"kind": "memory", "panels": [{"caption": "x → what is inside", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42", "color": "orange"}]}, {"caption": "&x → where it lives", "cells": [{"id": "a", "name": "&x", "value": "1000", "color": "teal"}]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Key idea$q$, $q$Value vs address$q$, $q$<p>Two different questions, two different answers:</p><ul><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> &rarr; <strong>what</strong> is inside? <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code></li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> &rarr; <strong>where</strong> is it? <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code></li></ul><p>Mixing these two up is the most common beginner mistake with pointers.</p>$q$),
  ('ar', $q$فكرة أساسية$q$, $q$القيمة مقابل العنوان$q$, $q$<p>سؤالين مختلفين، وإجابتين مختلفتين:</p><ul><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> &rarr; إيه <strong>اللي جوه</strong> الصندوق؟ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code></li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> &rarr; الصندوق <strong>فين</strong>؟ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code></li></ul><p>الخلط بين الاتنين هو أكتر غلطة بتحصل للمبتدئين مع الـ Pointers.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 5;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 6, $q$ {"kind": "memory", "panels": [{"caption": "int x = 42;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}]}, {"caption": "x = 99;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "99"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Change$q$, $q$Changing the value, not the address$q$, $q$<p>When we run <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x = 99;</code> the number <em>inside</em> the box changes. The box itself stays exactly where it was.</p><p>As long as a variable is alive, its address never changes.</p>$q$),
  ('ar', $q$التغيير$q$, $q$بنغيّر القيمة، مش العنوان$q$, $q$<p>لما نكتب <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x = 99;</code> الرقم <em>اللي جوه</em> الصندوق هو اللي بيتغيّر. الصندوق نفسه بيفضل في مكانه بالظبط.</p><p>طول ما المتغيّر عايش، العنوان بتاعه عمره ما بيتغيّر.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 6;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 7, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y"}], "highlight": ["y"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Careful$q$, $q$A box you never filled$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int y;</code> reserves a box but puts nothing meaningful in it. It holds whatever was left there before &mdash; garbage.</p><p>We draw it as <strong>?</strong>. Always give a variable a value before you read it.</p>$q$),
  ('ar', $q$خلّي بالك$q$, $q$صندوق ما حطّيناش فيه حاجة$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int y;</code> بتحجز صندوق بس مبتحطش فيه قيمة مفهومة. هو شايل أي حاجة كانت متسابة فيه قبل كده &mdash; يعني قيمة عشوائية.</p><p>بنرسمه <strong>؟</strong>. ادّي المتغيّر قيمة دايمًا قبل ما تقراه.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 7;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 8, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "a0", "address": "2000", "name": "a[0]", "value": "10"}, {"id": "a1", "address": "2004", "name": "a[1]", "value": "20"}, {"id": "a2", "address": "2008", "name": "a[2]", "value": "30"}, {"id": "a3", "address": "2012", "name": "a[3]", "value": "40"}], "highlight": ["a2"]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Arrays$q$, $q$Arrays: boxes side by side$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int a[4] = {10, 20, 30, 40};</code> gets four boxes <strong>in a row</strong>, one right after another.</p><p>Because they are neighbours, the computer finds <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[2]</code> instantly: start address + 2 &times; 4 = <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">2008</code>. That is why arrays are fast.</p>$q$),
  ('ar', $q$المصفوفات$q$, $q$المصفوفة: صناديق جنب بعض$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int a[4] = {10, 20, 30, 40};</code> بتاخد أربع صناديق <strong>ورا بعض</strong> في صف واحد.</p><p>عشان هما جيران، الكمبيوتر بيوصل لـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[2]</code> فورًا: عنوان البداية + 2 &times; 4 = <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">2008</code>. ده سبب سرعة الـ arrays.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 8;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 9, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "A", "address": "1000", "name": "A", "value": "10"}, {"id": "B", "address": "3016", "name": "B", "value": "20"}, {"id": "C", "address": "1512", "name": "C", "value": "30"}]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$A thought$q$, $q$Boxes don't have to be neighbours$q$, $q$<p>Sometimes we need boxes that are <em>not</em> side by side &mdash; for example in a linked list, where every new node goes wherever there is free space.</p><p>So how does one box find the next one? By <strong>storing the address of the next box</strong>. A variable that stores an address has a name: a <strong>pointer</strong>. That is the next lesson.</p>$q$),
  ('ar', $q$فكرة$q$, $q$الصناديق مش لازم تكون جنب بعض$q$, $q$<p>أوقات بنحتاج صناديق <em>مش</em> جنب بعض &mdash; زي الـ Linked List، كل node جديدة بتتحط في أي مكان فاضي.</p><p>طب الصندوق بيوصل للي بعده إزاي؟ بإنه <strong>يخزّن عنوان الصندوق التالي</strong>. والمتغيّر اللي بيخزّن عنوان اسمه <strong>Pointer</strong>. وده موضوع الدرس الجاي.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 9;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 10, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}]}]}$q$::jsonb FROM lessons WHERE slug = 'memory-and-addresses';
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = 'memory-and-addresses', (VALUES
  ('en', $q$Recap$q$, $q$What to remember$q$, $q$<ul><li>Memory is a row of <strong>numbered boxes</strong>.</li><li>An <strong>address</strong> is the number of a box.</li><li>A variable is a <strong>named box</strong> holding a value.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> is <em>what is inside</em>; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> is <em>where it lives</em>.</li><li>Changing a value never moves the box.</li></ul>$q$),
  ('ar', $q$ملخّص$q$, $q$اللي لازم تفتكره$q$, $q$<ul><li>الذاكرة صف من <strong>الصناديق المرقّمة</strong>.</li><li>الـ <strong>Address</strong> هو رقم الصندوق.</li><li>المتغيّر هو <strong>صندوق له اسم</strong> وفيه قيمة.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> هو <em>اللي جوه</em>، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> هو <em>مكانه</em>.</li><li>تغيير القيمة عمره ما بيحرّك الصندوق.</li></ul>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 10;
