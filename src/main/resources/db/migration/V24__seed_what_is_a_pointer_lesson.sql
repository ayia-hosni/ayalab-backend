-- Seeds Pointers lesson 2: "What is a Pointer": a pointer is a box holding an address, declaring and
-- pointing, dereferencing (*p), p vs *p, aliasing, re-pointing, NULL, and p->field on a node.
-- Data-only: structured `memory` slides. Takes ordinal 1 (reserved by V23).

INSERT INTO lessons (slug, ordinal, icon, published, section_id, category_id)
SELECT $q$what-is-a-pointer$q$, 1, $q$🎯$q$, TRUE, s.id, c.id
FROM lesson_sections s JOIN lesson_categories c ON c.section_id = s.id AND c.slug = 'fundamentals'
WHERE s.slug = 'pointers';

INSERT INTO lesson_i18n (lesson_id, locale, title, description)
SELECT l.id, v.locale, v.title, v.description
FROM lessons l, (VALUES
  ('en', $q$What is a Pointer$q$, $q$A pointer is a variable that holds an address: declaring one, pointing it, following it with *p, and NULL.$q$),
  ('ar', $q$يعني إيه Pointer$q$, $q$الـ Pointer متغيّر بيشيل عنوان: إزاي تعرّفه، تخلّيه يشاور، تمشي وراه بـ *p، ومعنى NULL.$q$)
) AS v(locale, title, description)
WHERE l.slug = $q$what-is-a-pointer$q$;


INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 0, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Pointers · Part 2$q$, $q$A pointer is a box that holds an address$q$, $q$<p>Look at the picture: the box <strong>p</strong> does not hold a normal number like 42. It holds the <em>address</em> of another box, and the arrow shows which one.</p><p>That is the whole idea of a pointer. Now we will build it step by step.</p>$q$),
  ('ar', $q$المؤشرات · الجزء 2$q$, $q$الـ Pointer صندوق جواه عنوان$q$, $q$<p>بص على الرسمة: الصندوق <strong>p</strong> مش شايل رقم عادي زي 42. هو شايل <em>عنوان</em> صندوق تاني، والسهم بيوريك هو أنهي صندوق.</p><p>ده هو الـ Pointer كله. دلوقتي هنبنيه خطوة خطوة.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 0;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 1, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42", "color": "orange"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Two kinds of boxes$q$, $q$Value boxes and address boxes$q$, $q$<p>A normal variable like <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> holds a <strong>value</strong>: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>.</p><p>A pointer like <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> is also a variable &mdash; a box with its own address &mdash; but what it holds is an <strong>address</strong>: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>.</p><p>Same kind of box. Different kind of thing inside.</p>$q$),
  ('ar', $q$نوعين من الصناديق$q$, $q$صناديق للقيم وصناديق للعناوين$q$, $q$<p>المتغيّر العادي زي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x</code> بيشيل <strong>قيمة</strong>: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>.</p><p>الـ Pointer زي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> هو كمان متغيّر &mdash; صندوق ليه عنوانه &mdash; بس اللي جواه <strong>عنوان</strong>: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>.</p><p>نفس شكل الصندوق. بس اللي جواه نوع تاني.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 1;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 2, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "p", "address": "1008", "name": "p", "color": "teal"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Declaring$q$, $q$int *p; &mdash; a pointer to an int$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> says: <em>p is a box that will hold the address of an int</em>. The <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*</code> here means &ldquo;pointer to&rdquo;.</p><p>Right now it is an empty box (<strong>?</strong>) &mdash; it points at nothing meaningful yet.</p>$q$),
  ('ar', $q$التعريف$q$, $q$int *p; &mdash; Pointer بيشاور على int$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> معناها: <em>p صندوق هيشيل عنوان متغيّر من نوع int</em>. والـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*</code> هنا معناها &laquo;Pointer على&raquo;.</p><p>لحد دلوقتي الصندوق فاضي (<strong>؟</strong>) &mdash; مش بيشاور على حاجة مفهومة.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 2;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 3, $q$ {"kind": "memory", "panels": [{"caption": "before", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "color": "teal"}]}, {"caption": "p = &x;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Pointing$q$, $q$p = &amp;x; &mdash; make it point$q$, $q$<p>Remember <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> is the address of x: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>. The line <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;x;</code> copies that address into the box p.</p><p>Now p &ldquo;points to&rdquo; x. We draw it as an arrow.</p>$q$),
  ('ar', $q$المشاورة$q$, $q$p = &amp;x; &mdash; خلّيه يشاور$q$, $q$<p>فاكر إن <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;x</code> هو عنوان x: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code>. السطر <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;x;</code> بينسخ العنوان ده جوه الصندوق p.</p><p>دلوقتي p &laquo;بيشاور على&raquo; x. وبنرسمها سهم.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 3;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 4, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Key idea$q$, $q$The arrow is just an address$q$, $q$<p>There is no real arrow in the computer. The &ldquo;arrow&rdquo; is only the number <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code> stored inside p &mdash; the arrow is how <em>we</em> draw it.</p><p>To find x, the computer reads p, gets 1000, and goes to the box numbered 1000.</p>$q$),
  ('ar', $q$فكرة أساسية$q$, $q$السهم هو مجرد عنوان$q$, $q$<p>مفيش سهم حقيقي جوه الكمبيوتر. الـ &laquo;سهم&raquo; هو بس الرقم <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code> المخزّن جوه p &mdash; السهم هو الطريقة اللي <em>إحنا</em> بنرسم بيها.</p><p>عشان يوصل لـ x، الكمبيوتر بيقرا p، ياخد 1000، ويروح للصندوق اللي رقمه 1000.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 4;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 5, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42", "color": "orange"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Dereferencing$q$, $q$*p &mdash; follow the arrow$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> means &ldquo;go to the address stored in p and look at the box there&rdquo;.</p><p>So <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> gives <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>. We say we <strong>dereference</strong> p.</p><p>The same star appears in two places: in <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> it means &ldquo;p is a pointer&rdquo;; in <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> on its own it means &ldquo;follow it&rdquo;.</p>$q$),
  ('ar', $q$فكّ المؤشر$q$, $q$*p &mdash; امشي ورا السهم$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> معناها &laquo;روح للعنوان المخزّن في p وبص على الصندوق اللي هناك&raquo;.</p><p>يعني <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> بترجّع <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code>. وبنقول إننا عملنا <strong>dereference</strong> لـ p.</p><p>النجمة بتظهر في مكانين: في <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> معناها &laquo;p هو Pointer&raquo;، وفي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> لوحدها معناها &laquo;امشي ورا السهم&raquo;.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 5;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 6, $q$ {"kind": "memory", "panels": [{"caption": "before", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}, {"caption": "*p = 99;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "99"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Writing through a pointer$q$, $q$*p = 99; changes x$q$, $q$<p>We never wrote <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x = 99</code>. We followed the arrow and changed the box at the other end &mdash; and that box <em>is</em> x.</p><p>Notice that p itself did not change: it still holds 1000.</p>$q$),
  ('ar', $q$الكتابة من خلال المؤشر$q$, $q$*p = 99; بتغيّر x$q$, $q$<p>إحنا عمرنا ما كتبنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">x = 99</code>. مشينا ورا السهم وغيّرنا الصندوق اللي في الناحية التانية &mdash; والصندوق ده <em>هو</em> x.</p><p>لاحظ إن p نفسه ما اتغيّرش: لسه شايل 1000.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 6;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 7, $q$ {"kind": "memory", "panels": [{"caption": "p → the address inside p", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}, {"caption": "*p → the value it points to", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["x"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Key idea$q$, $q$p vs *p$q$, $q$<ul><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> &rarr; what is <strong>inside p</strong>: the address <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code></li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> &rarr; what is <strong>at that address</strong>: the value <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code></li></ul><p>It is the same pair of questions as <em>x</em> vs <em>&amp;x</em> &mdash; one level up.</p>$q$),
  ('ar', $q$فكرة أساسية$q$, $q$p مقابل *p$q$, $q$<ul><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> &rarr; اللي <strong>جوه p</strong>: العنوان <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1000</code></li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> &rarr; اللي <strong>موجود في العنوان ده</strong>: القيمة <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">42</code></li></ul><p>ده نفس السؤالين بتوع <em>x</em> مقابل <em>&amp;x</em> &mdash; بس مستوى أعلى.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 7;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 8, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$A pointer is a box too$q$, $q$A pointer has its own address$q$, $q$<p>p is a box, so it lives somewhere: at address <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1008</code>. That means <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;p</code> is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1008</code>.</p><p>Pointers are ordinary variables. They can even be pointed to by other pointers &mdash; but we will leave that for later.</p>$q$),
  ('ar', $q$الـ Pointer كمان صندوق$q$, $q$الـ Pointer ليه عنوانه هو كمان$q$, $q$<p>p صندوق، يعني قاعد في مكان: عنوانه <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1008</code>. يعني <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;p</code> بتساوي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1008</code>.</p><p>الـ Pointers متغيّرات عادية. وممكن Pointer تاني يشاور عليهم كمان &mdash; بس نسيب ده لبعدين.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 8;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 9, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}, {"id": "q", "address": "1012", "name": "q", "value": "1000", "color": "rose"}], "arrows": [{"from": "p", "to": "x"}, {"from": "q", "to": "x"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Sharing$q$, $q$Two pointers, one box$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = &amp;x; int *q = &amp;x;</code> &mdash; both p and q hold the address 1000.</p><p>If we run <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*q = 5;</code>, then reading <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> gives <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code> too: there is only one box, and both arrows lead to it.</p>$q$),
  ('ar', $q$المشاركة$q$, $q$اتنين Pointers على صندوق واحد$q$, $q$<p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p = &amp;x; int *q = &amp;x;</code> &mdash; الاتنين p و q شايلين العنوان 1000.</p><p>لو نفّذنا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*q = 5;</code> هنلاقي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> كمان بقت <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">5</code>: في صندوق واحد بس، والسهمين بيوصلوا له.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 9;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 10, $q$ {"kind": "memory", "panels": [{"caption": "before", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}, {"caption": "p = &y;", "cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "y", "address": "1004", "name": "y", "value": "7"}, {"id": "p", "address": "1008", "name": "p", "value": "1004", "color": "teal"}], "arrows": [{"from": "p", "to": "y"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Re-pointing$q$, $q$p = &amp;y; &mdash; move the arrow$q$, $q$<p>Assigning to p itself changes <em>where it points</em>. Now p holds <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1004</code>, so <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> is <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">7</code>.</p><p>x was not touched at all.</p>$q$),
  ('ar', $q$تغيير المشاورة$q$, $q$p = &amp;y; &mdash; حرّك السهم$q$, $q$<p>لما نكتب في p نفسه ده بيغيّر <em>هو بيشاور على إيه</em>. دلوقتي p شايل <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">1004</code>، يعني <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> بتساوي <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">7</code>.</p><p>و x ما اتلمسش خالص.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 10;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 11, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "NULL", "color": "teal"}], "highlight": ["p"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Nothing to point at$q$, $q$NULL &mdash; a pointer that points nowhere$q$, $q$<p>When a pointer has nothing to point at, we set it to <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> (or <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">nullptr</code> in modern C++). That is a deliberate, safe &ldquo;no target&rdquo;.</p><p>Never write <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> while p is NULL &mdash; there is no box to follow, and the program crashes. So we check first: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">if (p != NULL) { ... }</code>.</p>$q$),
  ('ar', $q$مفيش حاجة يشاور عليها$q$, $q$NULL &mdash; Pointer مبيشاورش على حاجة$q$, $q$<p>لما الـ Pointer مفيش حاجة يشاور عليها، بنخلّيه <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> (أو <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">nullptr</code> في C++ الحديثة). ده معناه &laquo;مفيش هدف&raquo; بشكل مقصود وآمن.</p><p>عمرك ما تكتب <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> وp بـ NULL &mdash; مفيش صندوق تمشي له، والبرنامج هيقع. عشان كده بنتأكد الأول: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">if (p != NULL) { ... }</code>.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 11;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 12, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "d", "address": "2000", "name": "data", "value": "10", "color": "orange"}, {"id": "n", "address": "2004", "name": "next", "value": "NULL", "color": "orange"}, {"id": "p", "address": "1000", "name": "p", "value": "2000", "color": "teal"}], "arrows": [{"from": "p", "to": "d"}], "highlight": ["d"]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Pointers to structs$q$, $q$p-&gt;data &mdash; reaching inside a node$q$, $q$<p>A <strong>Node</strong> is a struct with two fields side by side: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">data</code> and <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code>. p points to the node &mdash; to its first byte.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;data</code> means &ldquo;follow p, then take the field data&rdquo;. It is a shorthand for <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">(*p).data</code>.</p><p>And <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;next</code> is just another pointer, stored inside the node. Hold on to that sentence &mdash; it is how a Linked List works.</p>$q$),
  ('ar', $q$المؤشر على struct$q$, $q$p-&gt;data &mdash; الوصول لجوه الـ Node$q$, $q$<p>الـ <strong>Node</strong> هو struct فيه حقلين جنب بعض: <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">data</code> و <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">next</code>. و p بيشاور على الـ node &mdash; على أول byte فيها.</p><p><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;data</code> معناها &laquo;امشي ورا p وبعدين هات الحقل data&raquo;. وهي اختصار لـ <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">(*p).data</code>.</p><p>و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;next</code> هو كمان Pointer عادي، متخزّن جوه الـ node. افتكر الجملة دي &mdash; هي سر عمل الـ Linked List.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 12;

INSERT INTO lesson_slides (lesson_id, ordinal, spec)
SELECT id, 13, $q$ {"kind": "memory", "panels": [{"cells": [{"id": "x", "address": "1000", "name": "x", "value": "42"}, {"id": "p", "address": "1008", "name": "p", "value": "1000", "color": "teal"}], "arrows": [{"from": "p", "to": "x"}]}]}$q$::jsonb FROM lessons WHERE slug = $q$what-is-a-pointer$q$;
INSERT INTO lesson_slide_i18n (slide_id, locale, kicker, title, body)
SELECT s.id, v.locale, v.kicker, v.title, v.body
FROM lesson_slides s JOIN lessons l ON l.id = s.lesson_id AND l.slug = $q$what-is-a-pointer$q$, (VALUES
  ('en', $q$Recap$q$, $q$What to remember$q$, $q$<ul><li>A <strong>pointer</strong> is a variable whose value is an <strong>address</strong>.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> declares it; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;x;</code> makes it point at x.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> is the address; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> is the thing at that address.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p = 99;</code> changes x; <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;y;</code> moves the arrow.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> means &ldquo;points nowhere&rdquo; &mdash; check before you use <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code>.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;field</code> reaches into the struct p points to.</li></ul><p><strong>Java note:</strong> Java has no <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*</code> or <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;</code>, but every variable of an object type is a <em>reference</em> &mdash; the same arrow, drawn for you. <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">node.next</code> is a pointer in everything but name.</p>$q$),
  ('ar', $q$ملخّص$q$, $q$اللي لازم تفتكره$q$, $q$<ul><li>الـ <strong>Pointer</strong> متغيّر قيمته <strong>عنوان</strong>.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">int *p;</code> بتعرّفه، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;x;</code> بتخلّيه يشاور على x.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p</code> هو العنوان، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code> هو اللي موجود في العنوان ده.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p = 99;</code> بتغيّر x، و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p = &amp;y;</code> بتحرّك السهم.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">NULL</code> معناها &laquo;مبيشاورش على حاجة&raquo; &mdash; اتأكد قبل ما تستخدم <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*p</code>.</li><li><code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">p-&gt;field</code> بتوصل لجوه الـ struct اللي p بيشاور عليه.</li></ul><p><strong>ملحوظة Java:</strong> الـ Java مفيهاش <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">*</code> ولا <code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">&amp;</code>، بس أي متغيّر من نوع object هو <em>reference</em> &mdash; نفس السهم، بس مرسوم لك. و<code class="bg-white border border-gray-200 px-1.5 py-0.5 rounded font-mono text-sm">node.next</code> هو Pointer في كل حاجة ما عدا الاسم.</p>$q$)
) AS v(locale, kicker, title, body)
WHERE s.ordinal = 13;
