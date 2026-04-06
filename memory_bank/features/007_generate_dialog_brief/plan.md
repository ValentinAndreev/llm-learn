# Генерация brief из диалога — план реализации

## Обзор подхода

Сначала расширяем `dialogs` полем для хранения актуального brief, затем уточняем output-контракт `build_brief` template и добавляем lib-класс, который строит, валидирует и сохраняет YAML brief. После этого обновляем RBS и unit-спеки.

## Шаги

### 1. Добавить `current_brief` в `dialogs`
**Файлы:** `db/migrate/TIMESTAMP_add_current_brief_to_dialogs.rb` (новый)
**Что делаем:** Создать миграцию, которая добавляет в `dialogs` поле `current_brief:text`.
**Проверка:** `bin/rails db:migrate` завершается без ошибок, колонка `current_brief` появляется в `db/schema.rb`.

### 2. Зафиксировать YAML-схему brief в prompt template
**Файлы:** `learning/prompts/intake/build_brief.md` (изменить)
**Что делаем:** Уточнить в template обязательные ключи YAML-ответа: `goal`, `topic_boundaries`, `difficulty_level`, `constraints`, `adjacent_topics`, `expected_outcome`, а также правила для `null` и `[]`.
**Проверка:** Из template явно следует ожидаемая структура YAML brief.

### 3. Реализовать сборку и сохранение brief
**Файлы:** `lib/learning/brief_builder.rb` (новый)
**Что делаем:** Добавить класс, который работает только из состояния `intake_complete`, запускает prompt runner для `build_brief`, парсит YAML, валидирует обязательные ключи и сохраняет результат в `Dialog#current_brief`, обновляя `workflow_state` на `brief_ready`.
**Проверка:** На валидном YAML диалог получает `current_brief` и `brief_ready`; на невалидном YAML возвращается `invalid_brief`, а старый `current_brief` не меняется.

### 4. Обновить RBS для новых API
**Файлы:** `sig/dialog.rbs` (изменить), `sig/learning/brief_builder.rbs` (новый)
**Что делаем:** Добавить `current_brief` в сигнатуру `Dialog` и описать публичный API `BriefBuilder`.
**Проверка:** `bundle exec steep check` не выдаёт ошибок по `Dialog` и `BriefBuilder`.

### 5. Покрыть `BriefBuilder` unit-спеками
**Файлы:** `spec/lib/learning/brief_builder_spec.rb` (новый)
**Что делаем:** Добавить спеки на `invalid_state`, success path, `invalid_brief` при плохом YAML и failure prompt runner без изменения `current_brief` и `workflow_state`.
**Проверка:** `bundle exec rspec spec/lib/learning/brief_builder_spec.rb` — всё зелёное.

### 6. Проверить миграцию и совместимость с текущим `Dialog`
**Файлы:** `spec/models/dialog_spec.rb` (проверка), `spec/lib/learning/brief_builder_spec.rb` (проверка)
**Что делаем:** Убедиться, что новое поле `current_brief` не ломает текущие модельные сценарии и не требует изменений в существующем chat flow.
**Проверка:** `bundle exec rspec spec/models/dialog_spec.rb spec/lib/learning/brief_builder_spec.rb` — всё зелёное.

## Зависимости между шагами

- Шаг 3 требует шагов 1–2, потому что builder должен опираться и на существующую колонку, и на зафиксированный YAML-контракт
- Шаг 4 требует шага 3, потому что RBS должен описывать уже реализованный API
- Шаг 5 требует шага 3 и покрывает все runtime-кейсы builder
- Шаг 6 выполняется последним как проверка совместимости после миграции, runtime-кода и unit-спеков
