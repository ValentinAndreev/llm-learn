# Первая генерация conspect и создание директории темы

**Brief:** `memory_bank/features/009_generate_first_conspect_and_create_topic_directory/brief.md`

## Цель

После первой успешной генерации conspect превратить диалог в файловую conspect-тему с набором стартовых артефактов.

## Scope

- Входит (3 компонента: `Dialog`, prompt runner, файловый слой темы):
  - Генерация первого conspect по `current_conspect_prompt`
  - Генерация и сохранение `topic_slug`
  - Создание каталога темы и стартовых файлов по контракту задачи 002
  - Обновление `workflow_state`
- НЕ входит:
  - Self-review conspect
  - Регенерация и версионирование
  - Definitions и другие производные артефакты

## Требования

1. Feature должна запускаться только если у диалога `workflow_state = prompt_ready`.
2. Если `workflow_state` диалога отличается от `prompt_ready`, feature должна вернуть failure с кодом `invalid_state` и не вызывать LLM.
3. У диалога должен быть непустой `current_conspect_prompt` и пустой `topic_slug`.
4. Если `current_conspect_prompt` отсутствует, feature должна вернуть failure с кодом `missing_prompt` и не вызывать LLM.
5. Если `topic_slug` уже заполнен, feature должна вернуть failure с кодом `topic_already_exists` и не вызывать LLM.
6. `topic_slug` должен строиться из `goal`, а если `goal` пустой — из `title` диалога.
7. При коллизии slug должен получать числовой суффикс `-2`, `-3` и так далее до уникального значения.
8. LLM должна вызываться только для генерации текста conspect; если результат пустой, feature должна вернуть failure с кодом `empty_conspect`.
9. Каталог `learning/topics/<topic_slug>/` должен создаваться только после успешного получения непустого текста conspect.
10. В каталоге темы должны быть созданы:
   - `meta.yml`
   - `brief.md`
   - `conspect_prompt.md`
   - `conspects/current.md`
   - директории `conspects/versions/` и `reviews/`
11. `meta.yml` должен содержать ключи `topic_slug`, `source_dialog_id`, `created_at`, `updated_at`, `current_state`.
12. `brief.md` должен содержать markdown-представление `current_brief` с разделами по обязательным ключам brief.
13. `conspect_prompt.md` должен содержать актуальный `current_conspect_prompt`.
14. `conspects/current.md` должен содержать сгенерированный текст conspect.
15. После успешной записи файлов в `Dialog` должны быть сохранены `topic_slug` и `workflow_state = conspect_generated`.
16. Если запись файлов завершилась ошибкой, feature должна удалить частично созданный каталог темы, оставить `topic_slug = NULL` и не менять `workflow_state`.

## Инварианты

- Каталог conspect-темы не создаётся до успешной генерации conspect
- После успешного создания у темы всегда есть `meta.yml` и `conspects/current.md`
- Один диалог получает ровно один `topic_slug` на этапе первой генерации
- При ошибке записи на диск частично созданный каталог не остаётся в файловой системе

## Acceptance Criteria

- [ ] Если `workflow_state` отличается от `prompt_ready`, feature возвращает `invalid_state` и не вызывает LLM
- [ ] Feature не запускается без `current_conspect_prompt`
- [ ] Если `topic_slug` уже заполнен, feature возвращает `topic_already_exists` и не вызывает LLM
- [ ] При пустом результате генерации возвращается `empty_conspect`, и каталог темы не создаётся
- [ ] После успешной генерации создаётся уникальный `topic_slug`
- [ ] После успешной генерации создаётся каталог `learning/topics/<topic_slug>/`
- [ ] В каталоге создаются `meta.yml`, `brief.md`, `conspect_prompt.md`, `conspects/current.md`
- [ ] В каталоге создаются `conspects/versions/` и `reviews/`
- [ ] `Dialog#topic_slug` обновляется только после успешной записи всех файлов
- [ ] После успеха `workflow_state` обновляется на `conspect_generated`
- [ ] При ошибке записи на диск частично созданный каталог удаляется, `topic_slug` не сохраняется, `workflow_state` не меняется
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Следовать контракту хранения из задачи 002
- Не запускать self-review в этой фиче
- Не добавлять definitions и другие производные артефакты
