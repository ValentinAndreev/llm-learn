# Сборка финального prompt на conspect — план реализации

## Обзор подхода

Сначала делаем `build_prompt` template детерминированным по output, затем добавляем lib-класс, который собирает final prompt из `current_brief`, `goal` и истории сообщений диалога. После этого описываем новый API в RBS и закрываем unit-спеками success/failure сценарии.

## Шаги

### 1. Уточнить output-контракт `build_prompt` template
**Файлы:** `learning/prompts/conspect/build_prompt.md` (изменить)
**Что делаем:** Зафиксировать в template, что модель должна возвращать только текст итогового conspect prompt без служебных комментариев и обрамления.
**Проверка:** Из template однозначно следует, что output — только готовый prompt для дальнейшей генерации conspect.

### 2. Реализовать сборку final prompt
**Файлы:** `lib/learning/conspect_prompt_builder.rb` (новый)
**Что делаем:** Добавить класс, который проверяет наличие `current_brief`, допустимые состояния `brief_ready` / `prompt_ready` / `conspect_needs_revision`, запускает prompt runner для `learning/prompts/conspect/build_prompt.md`, сохраняет результат в `current_conspect_prompt` и обновляет `workflow_state`.
**Проверка:** На success `current_conspect_prompt` сохраняется и `workflow_state` становится `prompt_ready`; на failure прежнее значение поля не теряется.

### 3. Добавить RBS для builder
**Файлы:** `sig/learning/conspect_prompt_builder.rbs` (новый), `sig/dialog.rbs` (изменить при необходимости)
**Что делаем:** Описать публичный API builder и, если потребуется, уточнить тип `current_conspect_prompt` в `Dialog`.
**Проверка:** `bundle exec steep check` не выдаёт ошибок по новому builder.

### 4. Покрыть builder unit-спеками
**Файлы:** `spec/lib/learning/conspect_prompt_builder_spec.rb` (новый)
**Что делаем:** Добавить спеки на `missing_brief`, `invalid_state`, success path, успешную пересборку prompt и failure prompt runner без изменения `current_conspect_prompt` и `workflow_state`.
**Проверка:** `bundle exec rspec spec/lib/learning/conspect_prompt_builder_spec.rb` — всё зелёное.

### 5. Прогнать связанные спеки workflow-цепочки
**Файлы:** `spec/lib/learning/brief_builder_spec.rb` (проверка), `spec/lib/learning/conspect_prompt_builder_spec.rb` (проверка)
**Что делаем:** Убедиться, что шаги `brief_ready -> prompt_ready` работают последовательно и не конфликтуют со state machine диалога.
**Проверка:** `bundle exec rspec spec/lib/learning/brief_builder_spec.rb spec/lib/learning/conspect_prompt_builder_spec.rb` — всё зелёное.

## Зависимости между шагами

- Шаг 2 требует шага 1, потому что builder должен опираться на зафиксированный output-контракт template
- Шаг 3 требует шага 2, потому что RBS должен описывать уже реализованный API
- Шаг 4 требует шага 2 и проверяет все success/failure ветки builder
- Шаг 5 выполняется последним как проверка последовательности между задачами 007 и 008
