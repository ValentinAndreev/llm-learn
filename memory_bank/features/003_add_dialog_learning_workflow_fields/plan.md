# Поля workflow для диалога обучения — план реализации

## Обзор подхода

Сначала расширяем схему `dialogs`, затем добавляем валидации и нормализацию в `Dialog`, после чего обновляем RBS и модельные тесты. Отдельно проверяем, что текущие сценарии чата продолжают работать без дополнительных полей в UI и контроллерах.

## Шаги

### 1. Добавить workflow-поля в `dialogs`
**Файлы:** `db/migrate/TIMESTAMP_add_learning_workflow_fields_to_dialogs.rb` (новый)
**Что делаем:** Создать миграцию, которая добавляет в `dialogs` поля `goal:text`, `workflow_state:string`, `topic_slug:string`, `current_conspect_prompt:text`; задать `workflow_state` значение по умолчанию `collecting_info`, `NOT NULL` и явно backfill-ить существующие записи значением `collecting_info`.
**Проверка:** `bin/rails db:migrate` завершается без ошибок, новые колонки видны в `db/schema.rb`, а существующие записи `dialogs` получают `workflow_state = collecting_info`.

### 2. Зафиксировать допустимые значения и нормализацию в `Dialog`
**Файлы:** `app/models/dialog.rb` (изменить)
**Что делаем:** Добавить список допустимых `workflow_state` со всеми значениями из спеки: `collecting_info`, `intake_complete`, `brief_ready`, `prompt_ready`, `conspect_generated`, `conspect_reviewed`, `conspect_needs_revision`; добавить валидацию `workflow_state`, валидацию `topic_slug` по regex и нормализацию `goal`, чтобы строки из пробелов не сохранялись как осмысленное значение.
**Проверка:** Через модель нельзя сохранить невалидный `workflow_state`, невалидный `topic_slug` и пустой `goal` после `strip`.

### 3. Обновить RBS для `Dialog`
**Файлы:** `sig/dialog.rbs` (изменить)
**Что делаем:** Добавить новые атрибуты и, если потребуется, сигнатуры для нормализации/валидации workflow-полей.
**Проверка:** `bundle exec steep check` не выдаёт новых ошибок по `Dialog`.

### 4. Расширить модельные тесты `Dialog`
**Файлы:** `spec/models/dialog_spec.rb` (изменить), `spec/factories/dialogs.rb` (изменить при необходимости)
**Что делаем:** Добавить проверки на default `workflow_state`, запрет невалидных состояний, запрет невалидного `topic_slug` и нормализацию `goal`.
**Проверка:** `bundle exec rspec spec/models/dialog_spec.rb` — всё зелёное.

### 5. Проверить совместимость текущего chat flow
**Файлы:** `spec/channels/chat_channel_spec.rb` (проверка), `spec/requests/dialogs_spec.rb` (проверка), `spec/system/dialogs_spec.rb` (проверка)
**Что делаем:** Прогнать существующие channel/request/system сценарии без дополнительных изменений в контроллерах и UI, чтобы подтвердить работу с `NULL` в новых полях.
**Проверка:** `bundle exec rspec spec/channels/chat_channel_spec.rb spec/requests/dialogs_spec.rb spec/system/dialogs_spec.rb` завершается без ошибок.

## Зависимости между шагами

- Шаг 2 требует шага 1, потому что модель не может валидировать несуществующие колонки
- Шаг 3 требует шага 2, потому что RBS должен отражать уже зафиксированный публичный API модели
- Шаг 4 требует шагов 1–2, потому что тесты проверяют и схему, и поведение модели
- Шаг 5 выполняется после шага 4, потому что сначала нужно зафиксировать локальное поведение `Dialog`, а затем проверять совместимость поверх существующего chat flow
