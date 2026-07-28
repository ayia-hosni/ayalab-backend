-- Arabic problem descriptions. Lessons already have title_ar/description_ar
-- (V7); problems never got the same treatment. Nullable and backfilled only
-- for problem 203 for now — every other problem (206 included) falls back to
-- the English description on the frontend until translated.

ALTER TABLE problems ADD COLUMN description_ar TEXT;

UPDATE problems SET description_ar = $desc$<p>بالنظر إلى رأس (<code>head</code>) قائمة مرتبطة وعدد صحيح <code>val</code>، احذفي كل العُقد اللي قيمتها (<code>Node.val</code>) بتساوي <code>val</code>، وبعدين رجّعي الرأس الجديد.</p>
<h4>مثال ١</h4>
<p>Input: head = [1, 2, 6, 3, 4, 5, 6], val = 6<br>Output: [1, 2, 3, 4, 5]</p>
<h4>مثال ٢</h4>
<p>Input: head = [], val = 1<br>Output: []</p>
<h4>مثال ٣</h4>
<p>Input: head = [7, 7, 7, 7], val = 7<br>Output: []</p>
<h4>القيود</h4>
<p>عدد العُقد بيقع في المدى [0, 10<sup>4</sup>]. 1 &lt;= Node.val &lt;= 50. 0 &lt;= val &lt;= 50.</p>
<h4>الفكرة</h4>
<p>استخدمي عقدة وهمية (dummy) مع مؤشرين، عشان حذف الرأس نفسه ميحتاجش حالة خاصة.</p>
<p>خلّي <code>dummy.next</code> يشاور على <code>head</code>، عشان الرأس الحقيقي يكون دايمًا وراه عقدة — كده مش هتحتاجي تكتبي شرط "هل ده الرأس؟". <code>prev</code> يبدأ عند <code>dummy</code> ويفضل متابع آخر عقدة اتحفظت؛ <code>curr</code> بتمشي في القائمة وتفحص كل عقدة بدورها.</p>
<p>في كل خطوة، احفظي <code>curr.next</code> في <code>nxt</code> قبل ما تلمسي أي مؤشر، عشان متضيعيش باقي القائمة. لو <code>curr.val === val</code>، تخطي العقدة دي بتحديث <code>prev.next = nxt</code>، و<code>prev</code> تفضل مكانها زي ما هي — العقدة الجاية لسه هتتلحق بنفس الـ<code>prev</code> ده. غير كده، العقدة بتتحفظ، فـ<code>prev</code> بتتقدم لـ<code>curr</code>. في الحالتين، <code>curr</code> بعد كده بتتحرك لـ<code>nxt</code>.</p>
<p>رجّعي <code>dummy.next</code> — هو دايمًا بيشاور على الرأس الحقيقي، سواء الرأس الأصلي اتمسح أو لأ.</p>
<h4>التعقيد</h4>
<p>الزمن O(n) · المساحة O(1)</p>
<p>كل عقدة بتتزار مرة واحدة بس، وبنستخدم عدد ثابت من المؤشرات الإضافية (<code>dummy</code>، <code>prev</code>، <code>curr</code>، <code>nxt</code>).</p>$desc$
WHERE id = 203;
