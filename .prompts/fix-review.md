# Прайминг: Fix Review Notes

## Контекст для агента перед исправлением замечаний

Прочитай:
1. `memory_bank/process/current-focus.md`
2. Соответствующий review note: `memory_bank/features/<id>_<name>/reviews/<stage>.md`
3. Артефакт, который нужно исправить:
   - `brief` → `brief.md`
   - `spec` → `spec.md`
   - `plan` → `plan.md`
   - `impl` → spec + plan + релевантный код / дифф
4. `memory_bank/engineering/conventions.md`, если исправления затрагивают реализацию

---

## Fail-Fast Preconditions

- `fix review: <id> <stage>` требует существующий `memory_bank/features/<id>_<name>/reviews/<stage>.md`.
- Также должен существовать артефакт, который исправляется: `brief.md`, `spec.md`, `plan.md` или релевантный код/дифф для `impl`.
- Если любой из этих входов отсутствует, остановись и верни blocker-сообщение.
- Пример:
  `BLOCKER: missing memory_bank/features/005_add_markdown_prompt_runner/reviews/spec.md. Cannot run fix review: 005 spec. Next step: run review spec: 005 or restore the review note.`
- Не ревьюй package "по ощущениям" и не придумывай замечания, если review note отсутствует.


## Что делать

- Исправляй только замечания из `reviews/<stage>.md`, если пользователь явно не расширил scope.
- Не удаляй и не обнуляй review note сам по себе: после правок нужен повторный review той же стадии.
- Если замечание не подтверждается кодом или конфликтует с текущим решением, зафиксируй это явно вместо того, чтобы гадать.
- Для `impl`-исправлений обязательно прогоняй релевантные проверки и тесты.

---

## Что обновить в `current-focus.md`

После исправлений:
- `Текущий этап` → `review_fixes`, пока правки не перепроверены
- `Review notes` → путь до активного `reviews/<stage>.md`
- `Следующий шаг` → команда повторного review той же стадии

Примеры:
- после `fix review: 005 spec` → `Следующий шаг: review spec: 005`
- после `fix review: 005 plan` → `Следующий шаг: review plan: 005`
- после `fix review: 005 brief` → `Следующий шаг: review brief: 005`
- после `fix review: 005 impl` → `Следующий шаг: review: 005`

---

## Принцип простоты

- `review ...` пишет замечания в `reviews/<stage>.md`
- `fix review: <id> <stage>` читает `reviews/<stage>.md` и правит соответствующий артефакт (`brief.md`, `spec.md`, `plan.md` или код/дифф для `impl`)
- повторный `review ...` перезаписывает тот же review note новым результатом

Отдельный history для review notes не нужен: историю уже хранит git.
