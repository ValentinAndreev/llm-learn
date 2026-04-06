# Сборка финального prompt на conspect

**Brief:** `memory_bank/features/008_build_final_conspect_prompt/brief.md`

## Цель

Собрать и сохранить один воспроизводимый prompt, по которому можно генерировать conspect для текущего диалога.

## Scope

- Входит (2 компонента: `Dialog`, prompt runner):
  - Сборка итогового prompt из `current_brief`, `goal` и истории диалога
  - Сохранение результата в `current_conspect_prompt`
  - Пересборка prompt после продолжения диалога
  - Обновление `workflow_state`
- НЕ входит:
  - Выполнение итогового prompt
  - Запись файлов темы на диск
  - Версионирование prompt

## Требования

1. Feature должна запускаться только если у диалога есть непустой `current_brief`.
2. Допустимые входные состояния для запуска: `brief_ready`, `prompt_ready`, `conspect_needs_revision`.
3. Если `current_brief` отсутствует, feature должна вернуть failure с кодом `missing_brief` и не вызывать LLM.
4. Если `workflow_state` не входит в допустимый набор, feature должна вернуть failure с кодом `invalid_state` и не вызывать LLM.
5. Feature должна запускать template `learning/prompts/conspect/build_prompt.md` через prompt runner.
6. В template должны передаваться как минимум `current_brief`, `goal` и сообщения диалога в порядке `created_at ASC`.
7. Успешный результат должен сохраняться в `Dialog#current_conspect_prompt`.
8. Если в диалоге уже был `current_conspect_prompt`, успешная пересборка должна полностью заменять его новым значением.
9. Если prompt runner завершился ошибкой или вернул пустой prompt, старое значение `current_conspect_prompt` не должно изменяться.
10. Если prompt runner завершился ошибкой или вернул пустой prompt, `workflow_state` диалога не должен изменяться.
11. После успешной сборки prompt `workflow_state` диалога должен обновляться на `prompt_ready`.

## Инварианты

- У каждого диалога хранится только один актуальный `current_conspect_prompt`
- `current_brief` не меняется в рамках этой фичи
- Feature не создаёт файлов в `learning/topics/`
- При неуспешной сборке старый `current_conspect_prompt` не теряется

## Acceptance Criteria

- [ ] Без `current_brief` feature возвращает `missing_brief` и не вызывает LLM
- [ ] Для недопустимого `workflow_state` feature возвращает `invalid_state` и не вызывает LLM
- [ ] При корректном входе вызывается template `learning/prompts/conspect/build_prompt.md`
- [ ] Успешный результат сохраняется в `current_conspect_prompt`
- [ ] При успешной пересборке старый `current_conspect_prompt` заменяется новым
- [ ] При ошибке runner или пустом prompt старый `current_conspect_prompt` не меняется
- [ ] При ошибке runner или пустом prompt `workflow_state` не меняется
- [ ] После успешной сборки `workflow_state` обновляется на `prompt_ready`
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Использовать prompt runner из задачи 005
- Не добавлять версионирование prompt в этой фиче
- Не выполнять генерацию conspect
