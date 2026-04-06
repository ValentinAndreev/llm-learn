# Генерация brief из диалога

**Brief:** `memory_bank/features/007_generate_dialog_brief/brief.md`

## Цель

Перевести содержимое диалога из raw messages в структурированный brief, который можно напрямую использовать на следующем шаге workflow для conspect.

## Scope

- Входит (3 компонента: миграция/schema, `Dialog`, prompt runner):
  - Новое поле для хранения актуального brief в диалоге
  - Генерация brief через template `learning/prompts/intake/build_brief.md`
  - Валидация структуры brief перед сохранением
  - Обновление `workflow_state`
- НЕ входит:
  - Запись brief в `learning/topics/`
  - Пользовательское редактирование brief в UI
  - Генерация final prompt

## Требования

1. В таблицу `dialogs` должно быть добавлено поле `current_brief:text`.
2. Feature должна запускаться только для диалога со значением `workflow_state = intake_complete`.
3. Если `workflow_state` отличается от `intake_complete`, feature должна вернуть failure с кодом `invalid_state` и не вызывать LLM.
4. Feature должна запускать template `learning/prompts/intake/build_brief.md` через prompt runner.
5. Результат brief должен сохраняться в `Dialog#current_brief` как YAML-текст.
6. YAML brief должен содержать все обязательные ключи: `goal`, `topic_boundaries`, `difficulty_level`, `constraints`, `adjacent_topics`, `expected_outcome`.
7. Если скалярное значение неизвестно, в YAML должно сохраняться `null`, а не пропуск ключа.
8. Если список неизвестен, в YAML должен сохраняться пустой список `[]`, а не пропуск ключа.
9. Если LLM вернул невалидный YAML или YAML без обязательных ключей, feature должна вернуть failure с кодом `invalid_brief`, не изменяя `current_brief`.
10. При любом failure prompt runner, отличном от `invalid_brief`, `workflow_state` и `current_brief` не должны изменяться, а вызывающий код должен получить явный failure.
11. После успешной генерации brief `workflow_state` диалога должен обновляться на `brief_ready`.

## Инварианты

- У каждого диалога в каждый момент хранится не более одного актуального `current_brief`
- `current_brief` всегда либо `NULL`, либо валидный YAML с обязательными ключами
- Генерация brief не создаёт файлов в `learning/topics/`
- Генерация brief не изменяет сообщения диалога

## Acceptance Criteria

- [ ] В `dialogs` добавлено поле `current_brief`
- [ ] Генерация brief не запускается для диалога вне состояния `intake_complete`
- [ ] Для диалога в состоянии `intake_complete` вызывается template `learning/prompts/intake/build_brief.md`
- [ ] Успешный результат сохраняется в `current_brief` как валидный YAML
- [ ] YAML содержит ключи `goal`, `topic_boundaries`, `difficulty_level`, `constraints`, `adjacent_topics`, `expected_outcome`
- [ ] При невалидном YAML или отсутствии обязательных ключей возвращается `invalid_brief`, и старый `current_brief` не меняется
- [ ] При любом другом failure prompt runner `workflow_state` и `current_brief` не меняются
- [ ] После успешной генерации `workflow_state` обновляется на `brief_ready`
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Использовать prompt runner из задачи 005
- Не записывать brief на диск в этой фиче
- Если меняется публичный API `Dialog`, обновить RBS
