# Self-review conspect и цикл регенерации

**Brief:** `memory_bank/features/010_add_conspect_self_review_and_regeneration_loop/brief.md`

## Цель

Дать пользователю цикл доработки conspect в рамках того же диалога без потери предыдущей версии и накопленного контекста.

## Scope

- Входит (3 компонента: `Dialog`, prompt runner, файловый слой темы):
  - Автоматический self-review после каждой генерации conspect
  - Сохранение review-артефакта в каталоге темы
  - Регенерация conspect в рамках того же `Dialog` и `topic_slug`
  - Архивация предыдущих версий conspect и review
  - Обновление `workflow_state`
- НЕ входит:
  - Definitions
  - Quiz / interview modes
  - Scheduler и progress analytics

## Требования

1. Эта фича расширяет задачу 009: после успешного завершения первой генерации conspect управление передаётся в self-review flow этой задачи; прямой вызов self-review из задачи 009 не добавляется.
2. После каждой успешной генерации conspect, включая первую генерацию из задачи 009 и все последующие регенерации, должен автоматически запускаться template `learning/prompts/conspect/self_review.md`.
3. Во вход self-review должны передаваться как минимум текст текущего conspect, `current_brief` и `goal` диалога.
4. Результат self-review должен сохраняться в `learning/topics/<topic_slug>/reviews/latest.md`.
5. Review-файл должен содержать разделы `Verdict`, `Issues`, `Suggestions`.
6. `Verdict` может принимать только значения `pass` или `revise`.
7. Если LLM вернул `Verdict`, отличный от `pass` или `revise`, feature должна вернуть failure с кодом `invalid_review`, `reviews/latest.md` не должен перезаписываться, а `workflow_state` должен оставаться `conspect_generated`.
8. Если `Verdict = pass`, `workflow_state` диалога должен обновляться на `conspect_reviewed`.
9. Если `Verdict = revise`, `workflow_state` диалога должен обновляться на `conspect_needs_revision`.
10. Допустимые входные состояния для ручной регенерации: только `conspect_reviewed` и `conspect_needs_revision`.
11. Если при ручной регенерации `workflow_state` диалога не входит в допустимый набор, feature должна вернуть failure с кодом `invalid_state` и не запускать LLM.
12. При повторной генерации для диалога с существующим `topic_slug` предыдущий `conspects/current.md` должен быть перемещён в `conspects/versions/<timestamp>.md` до записи нового `current.md`.
13. Если `reviews/latest.md` уже существует, перед записью нового review он должен быть перемещён в `reviews/history/<timestamp>.md`.
14. При неуспешной регенерации старые `conspects/current.md` и `reviews/latest.md` должны оставаться без изменений.
15. Если self-review завершился ошибкой после успешной генерации conspect, новый `conspects/current.md` должен остаться текущим, `reviews/latest.md` не должен перезаписываться частичными данными, а `workflow_state` должен остаться `conspect_generated`.
16. Регенерация должна использовать тот же `Dialog` и тот же `topic_slug`; новый каталог темы не создаётся.

## Инварианты

- Ни одна регенерация не перезаписывает предыдущий conspect без архивации
- Ни одна регенерация не создаёт новый `topic_slug`
- `reviews/latest.md` всегда либо отсутствует, либо содержит завершённый review
- Сообщения диалога не изменяются в ходе self-review и регенерации

## Acceptance Criteria

- [ ] После успешного завершения задачи 009 управление передаётся в self-review flow этой фичи без расширения прямого скоупа задачи 009
- [ ] После успешной генерации автоматически запускается `learning/prompts/conspect/self_review.md`
- [ ] После self-review создаётся или обновляется `reviews/latest.md`
- [ ] `reviews/latest.md` содержит разделы `Verdict`, `Issues`, `Suggestions`
- [ ] При `Verdict`, отличном от `pass` и `revise`, feature возвращает `invalid_review`, `reviews/latest.md` не перезаписывается, а `workflow_state` остаётся `conspect_generated`
- [ ] При `Verdict = pass` `workflow_state` обновляется на `conspect_reviewed`
- [ ] При `Verdict = revise` `workflow_state` обновляется на `conspect_needs_revision`
- [ ] При ручной регенерации из состояния, отличного от `conspect_reviewed` и `conspect_needs_revision`, feature возвращает `invalid_state` и не запускает LLM
- [ ] При повторной генерации предыдущий `conspects/current.md` архивируется в `conspects/versions/`
- [ ] При повторной генерации предыдущий `reviews/latest.md` архивируется в `reviews/history/`
- [ ] При неуспешной регенерации текущий conspect и текущий review не теряются
- [ ] При ошибке self-review новый conspect остаётся текущим, а `workflow_state` остаётся `conspect_generated`
- [ ] Новый каталог темы не создаётся во время регенерации
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Использовать существующий `topic_slug` и существующий каталог темы
- Не добавлять новые режимы обучения в этой фиче
- Не добавлять новые гемы
