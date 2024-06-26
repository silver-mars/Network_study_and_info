**XACML** (англ. eXtensible Access Control Markup Language — расширяемый язык разметки контроля доступа) — стандарт, разработанный OASIS, определяющий модель и язык описания политик управления доступом, основанный на языке XML, и способы их обработки.<br>
XACML - это стандарт разграничения доступа на основе атрибутов (ABAC), где атрибуты, связанные с пользователем, действием или ресурсом, являются входными данными для принятия решения о том, может ли данный пользователь получить доступ к данному ресурсу определенным образом.<br>
**Правило** состоит из нескольких частей:<br>
* цель (target);
* эффект (effect);
* условие (condition);
* обязательства (obligation);
* рекомендации (advice).
Цель является одинаковой частью как для правил, так для политик и групп политик. Поэтому описанное здесь верно и для них.<br>
Цель представляет собой логическое выражение, которое должно состоять только из атрибутов и констант.<br>
В цель обычно выносится та часть бизнес-правила, которая соответствует этому требованию.<br>
Основной смысл разделения бизнес-правила на части — более быстрое отсеивание неподходящих правил, политик или групп политик.<br>
Оставшаяся часть бизнес-правила (если такая есть), содержащая более сложное, динамически вычисляемое логическое выражение, должна помещаться в другую часть правила — **условие (condition).**<br>
**Политика** используется для объединения набора правил. Обычно набор таких правил представляет собой одно бизнес-правило. Таким образом решается сразу несколько задач. Во-первых, небольшие части логических условий, выраженные в правилах, можно легко использовать повторно, без дублирования этих условий. Во-вторых, такое разделение на части облегчает понимание всего бизнес-правила и упрощает его сопровождение.<br>
**Источники:**<br>
Подробный путь со всеми компонентами (PIP, PEP, PAP, etc.):<br>
https://ru.wikipedia.org/wiki/XACML<br>
Разбор простыми словами + ABAC:<br>
https://habr.com/ru/companies/custis/articles/258861/
