# Прайминг: Spec

## Контекст для агента перед работой со Spec

Прочитай:
1. Апрувнутый brief для фичи (в `memory_bank/features/<id>_<name>/brief.md`)
2. `memory_bank/project/glossary.md` — термины
3. `memory_bank/engineering/conventions.md` — ограничения реализации и testing rules

---

## Fail-Fast Preconditions

- Для `spec: <id>` обязателен существующий `memory_bank/features/<id>_<name>/brief.md`.
- Для `review spec: <id>` обязателен существующий `memory_bank/features/<id>_<name>/spec.md`.
- Если существует `memory_bank/features/<id>_<name>/reviews/brief.md` и в нём `Статус: blocking`, нельзя переходить к `spec: <id>` до `fix review: <id> brief` и повторного `review brief: <id>`.
- Если обязательный артефакт отсутствует или предыдущая стадия находится в blocking-review, остановись и верни blocker-сообщение.
- Примеры:
  `BLOCKER: missing memory_bank/features/<id>_<name>/brief.md. Cannot run spec: <id>. Next step: create or restore the Brief first.`
  `BLOCKER: brief review is blocking in memory_bank/features/<id>_<name>/reviews/brief.md. Cannot run spec: <id>. Next step: fix review: <id> brief, then review brief: <id>.`
- Не пытайся писать или исправлять spec по `plan.md`, `current-focus.md` или соседним файлам, если исходный brief/spec отсутствует.


## Создание Spec

Помоги создать спецификацию для фичи по шаблону:

```markdown
# [Название фичи]

**Brief:** `memory_bank/features/<id>_<name>/brief.md`

## Цель
[Одно предложение — зачем]

## Scope
- Входит: [что делаем]
- НЕ входит: [что не делаем]

## Требования
1. [Конкретное требование]
2. [Конкретное требование]

## Инварианты
- [Условие, которое должно оставаться истинным]

## Acceptance Criteria
1. [Проверяемый критерий]
2. [Проверяемый критерий]

## Ограничения реализации
- [Что НЕ менять, какие паттерны использовать]
```

---

## Ревью Spec

Ты — строгий ревьюер спецификаций для AI-агентов. Проверь спеку по критериям TAUS.

Сохрани результат ревью в `memory_bank/features/<id>_<name>/reviews/spec.md`.
Если это повторное ревью после исправлений, перезапиши тот же файл; историю сохранит git.

Используй единый формат review note:

```md
# Review

Фича: <id>_<name>
Стадия: spec
Статус: advisory | blocking
Дата: YYYY-MM-DD

## Итог
[Короткий вывод о готовности spec]

## Замечания
1. [Замечание]

## Следующий шаг
[Либо `Можно продолжать: plan: <id>`, либо `Исправить замечания: fix review: <id> spec` и затем `review spec: <id>`]
```

Статусы:
- `advisory` — spec пригодна для перехода к `plan`, замечания могут быть необязательными или отсутствовать
- `blocking` — spec нельзя считать готовой к следующей стадии до исправлений и повторного review

Для каждого критерия дай оценку pass/fail:

1. **Testable** — есть ли конкретные acceptance criteria, по которым можно написать автотест?
2. **Ambiguous-free** — есть ли двусмысленные слова («быстро», «удобно», «при необходимости»)?
3. **Uniform** — описаны ли все состояния (loading, error, success, empty)? Все сценарии ошибок?
4. **Scoped** — это одна фича? Меньше 1500 слов? Не затрагивает больше 3 модулей?

Дополнительно:
5. Есть ли ссылка на Brief?
6. Указан ли scope (что входит И что НЕ входит)?
7. Перечислены ли инварианты?
8. Указаны ли ограничения на реализацию (паттерны, запреты)?

Для каждого fail:
- Цитата из спеки
- Почему это проблема для агента
- Конкретное предложение по исправлению

Если все критерии pass:
- используй `Статус: advisory`
- в `## Замечания` напиши `0 замечаний.`
- в `## Следующий шаг` напиши `Можно продолжать: plan: <id>`
