-- Seeds Pointers lesson 3: "Pointers in Action": pass by value vs by pointer, increment and swap,
-- pointer arithmetic on arrays, the three classic pointer bugs, and the bridge to linked lists.
-- Data-only: structured `memory` slides. Takes ordinal 2 (reserved by V23).

INSERT INTO lessons (slug, ordinal, icon, published, section_id, category_id)
SELECT $q$pointers-in-action$q$, 2, $q$⚙️$q$, TRUE, s.id, c.id
FROM lesson_sections s JOIN lesson_categories c ON c.section_id = s.id AND c.slug = 'fundamentals'
WHERE s.slug = 'pointers';

INSERT INTO lesson_i18n (lesson_id, locale, title, description)
SELECT l.id, v.locale, v.title, v.description
FROM lessons l, (VALUES
  ('en', $q$Pointers in Action$q$, $q$Why a function can't change your variable, how passing an address fixes it (increment and swap), walking an array, and the bugs to avoid.$q$),
  ('ar', $q$الـ Pointers في التطبيق$q$, $q$ليه الدالة مش قادرة تغيّر متغيّرك، وإزاي تمرير العنوان بيحل المشكلة (increment و swap)، والمشي على مصفوفة، والأخطاء اللي لازم تتجنبها.$q$)
) AS v(locale, title, description)
WHERE l.slug = $q$pointers-in-action$q$;


INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 0, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "5"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pointers · Part 3$q$, $q$The problem: a function that can't change your variable$q$, $q$<p>We have <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 5;</code> and we want a function that adds one to it:</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void addOne(int a) { a = a + 1; }</code></p><p>We call <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(x);</code> &hellip; and x is still 5. Why? Let us look at what really happens in memory.</p>$q$),
  ('ar', $q$المؤشرات · الجزء 3$q$, $q$المشكلة: دالة مش قادرة تغيّر متغيّرك$q$, $q$<p>عندنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int x = 5;</code> وعايزين دالة تزوّد عليه واحد:</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void addOne(int a) { a = a + 1; }</code></p><p>ننادي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(x);</code> &hellip; وx لسه 5. ليه؟ تعالى نشوف اللي بيحصل فعلًا في الذاكرة.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 0;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 1, $q$ {"kind": "memory", "panels": [{"caption": "inside addOne(x)", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "5", "color": "orange"}, {"id": "a", "address": "2000", "name": "a", "value": "5", "color": "gray"}], "highlight": ["a"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pass by value$q$, $q$A call makes a photocopy$q$, $q$<p>When we call <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(x)</code> the computer creates a <strong>new box</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a</code> (at its own address, 2000) and <strong>copies</strong> the value 5 into it.</p><p>The function only ever sees <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a</code>. It has no idea that <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> exists.</p>$q$),
  ('ar', $q$التمرير بالقيمة$q$, $q$النداء بيعمل نسخة$q$, $q$<p>لما ننادي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(x)</code> الكمبيوتر بيعمل <strong>صندوق جديد</strong> <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a</code> (بعنوانه الخاص 2000) و<strong>بينسخ</strong> القيمة 5 فيه.</p><p>الدالة مبتشوفش غير <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a</code>. ومعندهاش أي فكرة إن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> موجود.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 1;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 2, $q$ {"kind": "memory", "panels": [{"caption": "a = a + 1;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "5"}, {"id": "a", "address": "2000", "name": "a", "value": "5", "color": "gray"}], "highlight": ["a"]}, {"caption": "after the call", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "5"}, {"id": "a", "address": "2000", "name": "a", "value": "6", "color": "gray"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pass by value$q$, $q$Only the copy changes$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a = a + 1</code> turns the copy into 6. When the function returns, the copy is thrown away &mdash; and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> was never touched.</p><p>To change the caller's variable, the function needs to know <strong>where</strong> it lives. In other words: its address.</p>$q$),
  ('ar', $q$التمرير بالقيمة$q$, $q$النسخة بس هي اللي بتتغيّر$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a = a + 1</code> بتخلّي النسخة 6. ولما الدالة تخلص، النسخة بتتمسح &mdash; و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> عمره ما اتلمس.</p><p>عشان الدالة تغيّر متغيّر اللي ناداها، لازم تعرف هو <strong>فين</strong>. يعني: عنوانه.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 2;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 3, $q$ {"kind": "memory", "panels": [{"caption": "inside addOne(&x)", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "5", "color": "orange"}, {"id": "p", "address": "2000", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pass by pointer$q$, $q$Pass the address instead$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void addOne(int *p) { *p = *p + 1; }</code> &nbsp; called as <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(&amp;x);</code></p><p>The copy is still made &mdash; but now it is a copy of the <em>address</em>. The new box p holds <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>, so it still leads to x.</p><p><strong>Java note:</strong> Java copies too. For an <em>object</em>, what it copies is the reference (the arrow), so the callee reaches the same object. For an <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int</code> it copies the number, exactly like our first example.</p>$q$),
  ('ar', $q$التمرير بالـ Pointer$q$, $q$ابعت العنوان بدل القيمة$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void addOne(int *p) { *p = *p + 1; }</code> &nbsp; وبننادي عليها <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">addOne(&amp;x);</code></p><p>النسخة لسه بتتعمل &mdash; بس دلوقتي هي نسخة من <em>العنوان</em>. الصندوق الجديد p شايل <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>، يعني لسه بيوصل لـ x.</p><p><strong>ملحوظة Java:</strong> الـ Java كمان بتنسخ. ولو الحاجة <em>object</em> فاللي بتنسخه هو الـ reference (السهم)، فالدالة بتوصل لنفس الـ object. أما <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int</code> فبتنسخ الرقم زي مثالنا الأول بالظبط.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 3;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 4, $q$ {"kind": "memory", "panels": [{"caption": "before", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "5"}, {"id": "p", "address": "2000", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}, {"caption": "*p = *p + 1;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "6"}, {"id": "p", "address": "2000", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pass by pointer$q$, $q$Follow the arrow to change x$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p + 1</code> reads the box p points to (5) and adds 1. Assigning to <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> writes the result (6) back into <strong>x itself</strong>.</p><p>When the function returns, p disappears &mdash; but the change to x stays. That is the whole power of passing a pointer.</p>$q$),
  ('ar', $q$التمرير بالـ Pointer$q$, $q$امشي ورا السهم عشان تغيّر x$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p + 1</code> بتقرا الصندوق اللي p بيشاور عليه (5) وتزوّد 1. والكتابة في <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> بترجّع النتيجة (6) جوه <strong>x نفسه</strong>.</p><p>لما الدالة تخلص، p بيختفي &mdash; بس التغيير في x بيفضل. ودي قوة تمرير الـ Pointer كلها.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 4;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 5, $q$ {"kind": "memory", "panels": [{"caption": "swap(x, y) swapped the copies", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "3"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "a", "address": "2000", "name": "a", "value": "7", "color": "gray"}, {"id": "b", "address": "2004", "name": "b", "value": "3", "color": "gray"}], "highlight": ["a", "b"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Classic example$q$, $q$A swap that doesn't work$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void swap(int a, int b) { int t = a; a = b; b = t; }</code></p><p>Called as <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap(x, y);</code> it swaps the <em>photocopies</em> a and b. Back in the caller, x is still 3 and y is still 7.</p>$q$),
  ('ar', $q$مثال كلاسيكي$q$, $q$swap مبتشتغلش$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void swap(int a, int b) { int t = a; a = b; b = t; }</code></p><p>لما ننادي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap(x, y);</code> هي بتبدّل <em>النسخ</em> a و b. ولما نرجع، x لسه 3 و y لسه 7.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 5;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 6, $q$ {"kind": "memory", "panels": [{"caption": "1:  int t = *a;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "3"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "a", "address": "2000", "name": "a", "value": "1000", "color": "teal"}, {"id": "b", "address": "2004", "name": "b", "value": "1004", "color": "rose"}, {"id": "t", "address": "2008", "name": "t", "value": "3", "color": "gray"}], "arrows": [{"from": "a", "to": "x"}, {"from": "b", "to": "y"}], "highlight": ["t"]}, {"caption": "2:  *a = *b;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "7"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "a", "address": "2000", "name": "a", "value": "1000", "color": "teal"}, {"id": "b", "address": "2004", "name": "b", "value": "1004", "color": "rose"}, {"id": "t", "address": "2008", "name": "t", "value": "3", "color": "gray"}], "arrows": [{"from": "a", "to": "x"}, {"from": "b", "to": "y"}], "highlight": ["x"]}, {"caption": "3:  *b = t;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "7"}, {"id": "y", "address": "1004", "name": "y", "value": "3"}, {"id": "a", "address": "2000", "name": "a", "value": "1000", "color": "teal"}, {"id": "b", "address": "2004", "name": "b", "value": "1004", "color": "rose"}, {"id": "t", "address": "2008", "name": "t", "value": "3", "color": "gray"}], "arrows": [{"from": "a", "to": "x"}, {"from": "b", "to": "y"}], "highlight": ["y"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Classic example$q$, $q$A swap that works$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void swap(int *a, int *b) { int t = *a; *a = *b; *b = t; }</code> called as <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap(&amp;x, &amp;y);</code></p><p>The temporary <strong>t</strong> keeps x's value safe while we overwrite x. Three steps, and the <em>callers'</em> boxes end up swapped: x = 7, y = 3.</p>$q$),
  ('ar', $q$مثال كلاسيكي$q$, $q$swap بتشتغل$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">void swap(int *a, int *b) { int t = *a; *a = *b; *b = t; }</code> وبننادي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap(&amp;x, &amp;y);</code></p><p>المتغيّر المؤقت <strong>t</strong> بيحفظ قيمة x وإحنا بنكتب فوقه. تلات خطوات، وصناديق <em>اللي ناداها</em> بتتبدّل: x = 7 و y = 3.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 6;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 7, $q$ {"kind": "memory", "panels": [{"caption": "int *p = a;", "cells": [{"id": "a0", "address": "2000", "name": "a[0]", "value": "10"}, {"id": "a1", "address": "2004", "name": "a[1]", "value": "20"}, {"id": "a2", "address": "2008", "name": "a[2]", "value": "30"}, {"id": "p", "address": "1000", "name": "p", "value": "2000", "color": "teal"}], "arrows": [{"from": "p", "to": "a0"}]}, {"caption": "p = p + 1;", "cells": [{"id": "a0", "address": "2000", "name": "a[0]", "value": "10"}, {"id": "a1", "address": "2004", "name": "a[1]", "value": "20"}, {"id": "a2", "address": "2008", "name": "a[2]", "value": "30"}, {"id": "p", "address": "1000", "name": "p", "value": "2004", "color": "teal"}], "arrows": [{"from": "p", "to": "a1"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Pointers and arrays$q$, $q$Moving a pointer along an array$q$, $q$<p>The name of an array is the address of its first box, so <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = a;</code> makes p point to <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[0]</code>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p + 1</code> moves to the <em>next int</em>: the address grows by 4 (an int's size), not by 1. Now <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code>. In fact <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[i]</code> is just shorthand for <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*(a + i)</code>.</p>$q$),
  ('ar', $q$المؤشرات والمصفوفات$q$, $q$تحريك Pointer على مصفوفة$q$, $q$<p>اسم المصفوفة هو عنوان أول صندوق فيها، فـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = a;</code> بتخلّي p يشاور على <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[0]</code>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p + 1</code> بتنقل لـ <em>الـ int اللي بعده</em>: العنوان بيزيد بـ 4 (حجم الـ int) مش بـ 1. دلوقتي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> هي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">20</code>. وفي الحقيقة <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[i]</code> هي اختصار لـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*(a + i)</code>.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 7;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 8, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1004", "name": "p", "color": "teal"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Mistake 1$q$, $q$A pointer you never set$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> alone gives a box with <em>garbage</em> inside &mdash; some random address.</p><p>Writing <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p = 5;</code> then scribbles on a random place in memory: the program may crash now, later, or worse &mdash; seem to work. Always initialise: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = &amp;x;</code> or <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = NULL;</code>.</p>$q$),
  ('ar', $q$الغلطة الأولى$q$, $q$Pointer ما حدّدناش له هدف$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> لوحدها بتدّيك صندوق فيه <em>قيمة عشوائية</em> &mdash; عنوان أي حاجة.</p><p>لو كتبت <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p = 5;</code> هتشخبط في مكان عشوائي في الذاكرة: ممكن البرنامج يقع دلوقتي أو بعدين، أو الأسوأ &mdash; يبان إنه شغّال. دايمًا ادّي له قيمة: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = &amp;x;</code> أو <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = NULL;</code>.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 8;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 9, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1004", "name": "p", "value": "NULL", "color": "teal"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Mistake 2$q$, $q$Following NULL$q$, $q$<p>NULL is a perfectly good pointer value &mdash; but there is no box at the end of it. <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> with p = NULL crashes immediately (a &ldquo;null pointer dereference&rdquo;).</p><p>The habit that saves you: <strong>check before you follow</strong>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">if (p != NULL) { *p = 5; }</code></p>$q$),
  ('ar', $q$الغلطة التانية$q$, $q$المشي ورا NULL$q$, $q$<p>NULL قيمة سليمة للـ Pointer &mdash; بس مفيش صندوق في آخرها. <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> لما p = NULL بتوقّع البرنامج فورًا (&laquo;null pointer dereference&raquo;).</p><p>العادة اللي بتنقذك: <strong>اتأكد قبل ما تمشي ورا السهم</strong>.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">if (p != NULL) { *p = 5; }</code></p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 9;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 10, $q$ {"kind": "memory", "panels": [{"caption": "after x's scope ended", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "gone", "color": "gray"}, {"id": "p", "address": "1004", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Mistake 3$q$, $q$A dangling pointer$q$, $q$<p>If p points to a box that no longer exists &mdash; a local variable whose function returned, or memory you freed &mdash; the arrow still looks fine, but the box now belongs to someone else.</p><p>Reading it gives garbage; writing it corrupts other data. The fix is design, not syntax: never keep an arrow to something that will die before the arrow does.</p>$q$),
  ('ar', $q$الغلطة التالتة$q$, $q$Pointer بيشاور على صندوق اتمسح$q$, $q$<p>لو p بيشاور على صندوق مبقاش موجود &mdash; متغيّر محلي الدالة بتاعته خلصت، أو ذاكرة عملنا لها free &mdash; السهم لسه شكله سليم، بس الصندوق بقى بتاع حد تاني.</p><p>القراءة منه بتدّيك قيمة عشوائية، والكتابة فيه بتبوّظ بيانات تانية. الحل في التصميم مش في الصياغة: متسيبش سهم على حاجة هتموت قبل السهم نفسه.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 10;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 11, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "h", "address": "1000", "name": "head", "value": "2000", "color": "teal"}, {"id": "d1", "address": "2000", "name": "A.data", "value": "10", "color": "orange"}, {"id": "n1", "address": "2004", "name": "A.next", "value": "3016", "color": "orange"}, {"id": "d2", "address": "3016", "name": "B.data", "value": "20", "color": "purple"}, {"id": "n2", "address": "3020", "name": "B.next", "value": "NULL", "color": "purple"}], "arrows": [{"from": "h", "to": "d1"}, {"from": "n1", "to": "d2"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Bridge$q$, $q$A linked list is pointers all the way$q$, $q$<p>Each <strong>Node</strong> is a <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">data</code> box plus a <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> box &mdash; and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> is a pointer holding the address of the following node.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">head</code> points to the first node, A.next points to B, B.next is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>: the end. That is the whole list &mdash; you already know every ingredient.</p>$q$),
  ('ar', $q$الجسر للدرس الجاي$q$, $q$الـ Linked List هي Pointers وبس$q$, $q$<p>كل <strong>Node</strong> هي صندوق <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">data</code> وصندوق <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> &mdash; و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code> هو Pointer شايل عنوان الـ node اللي بعدها.</p><p>الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">head</code> بيشاور على أول node، و A.next بيشاور على B، و B.next هي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code>: النهاية. دي الـ list كلها &mdash; وإنت دلوقتي عارف كل مكوّناتها.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 11;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 12, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "5"}, {"id": "p", "address": "2000", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$pointers-in-action$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$pointers-in-action$q$, (VALUES
  ('en', $q$Recap$q$, $q$What to remember$q$, $q$<ul><li>Function arguments are <strong>copies</strong>. Changing the copy never changes the caller's variable.</li><li>To let a function change something, pass its <strong>address</strong> and write through <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code>.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap</code> needs pointers (or references) &mdash; that is the classic proof.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p + 1</code> moves by the size of the type, and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[i]</code> is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*(a + i)</code>.</li><li>Three bugs to avoid: an <strong>unset</strong> pointer, a <strong>NULL</strong> dereference, a <strong>dangling</strong> pointer.</li><li>Next: a Node's <strong>next</strong> is a pointer &mdash; so you are ready for Linked Lists.</li></ul>$q$),
  ('ar', $q$ملخّص$q$, $q$اللي لازم تفتكره$q$, $q$<ul><li>الـ arguments في الدوال <strong>نسخ</strong>. تغيير النسخة عمره ما بيغيّر متغيّر اللي ناداها.</li><li>عشان الدالة تغيّر حاجة، ابعت <strong>عنوانها</strong> واكتب من خلال <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code>.</li><li>الـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">swap</code> محتاجة pointers (أو references) &mdash; ودي الإثبات الكلاسيكي.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p + 1</code> بتتحرك بحجم النوع، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">a[i]</code> هي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*(a + i)</code>.</li><li>تلات bugs تتجنبها: Pointer <strong>ما اتحددش</strong>، و dereference لـ <strong>NULL</strong>، و Pointer <strong>dangling</strong>.</li><li>الجاي: الـ <strong>next</strong> في الـ Node هو Pointer &mdash; يعني إنت جاهز للـ Linked Lists.</li></ul>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 12;
