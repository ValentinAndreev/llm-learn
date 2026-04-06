# Проверка полноты intake-диалога — план реализации

## Обзор подхода

Сначала уточняем контракт output для `check_completeness` prompt template, затем добавляем lib-класс проверки, который работает поверх `Dialog`, `Message` и prompt runner из задачи 005. После этого покрываем поведение unit-спеками и проверяем, что новые workflow-state переходы не ломают существующий код.

## Шаги

### 1. Уточнить output-контракт `check_completeness` template
**Файлы:** `learning/prompts/intake/check_completeness.md` (изменить)
**Что делаем:** Зафиксировать в template явный структурированный output для `complete`/`incomplete` и списка `missing_items`, чтобы runtime-код мог его однозначно парсить; short-circuit кейсы `missing_goal` и `no_user_messages` остаются в Ruby-коде и не перекладываются на template.
**Проверка:** Из содержимого template понятно, какой структурированный ответ обязана вернуть модель, а short-circuit кейсы не зависят от LLM.

### 2. Реализовать проверку полноты intake-диалога
**Файлы:** `lib/learning/intake_completeness_check.rb` (новый)
**Что делаем:** Добавить класс, который принимает `Dialog`, валидирует допустимое входное состояние `collecting_info`, short-circuit кейсы `missing_goal` и `no_user_messages`, запускает prompt runner на `learning/prompts/intake/check_completeness.md`, парсит результат и обновляет `workflow_state`.
**Проверка:** Класс возвращает `complete` или `incomplete`, не создаёт новых `Message` и меняет `workflow_state` только по правилам спеки.

### 3. Добавить RBS для проверки полноты
**Файлы:** `sig/learning/intake_completeness_check.rbs` (новый)
**Что делаем:** Описать входной аргумент `Dialog` и структуру success/failure результата для `IntakeCompletenessCheck`.
**Проверка:** `bundle exec steep check` не выдаёт ошибок по новому классу.

### 4. Покрыть `IntakeCompletenessCheck` unit-спеками
**Файлы:** `spec/lib/learning/intake_completeness_check_spec.rb` (новый)
**Что делаем:** Добавить спеки на `invalid_state`, `missing_goal`, `no_user_messages`, успешный `complete`, успешный `incomplete` и failure prompt runner без изменения `workflow_state`.
**Проверка:** `bundle exec rspec spec/lib/learning/intake_completeness_check_spec.rb` — всё зелёное.

### 5. Прогнать существующие спеки `Dialog` и chat flow
**Файлы:** `spec/models/dialog_spec.rb` (проверка), `spec/channels/chat_channel_spec.rb` (проверка)
**Что делаем:** Убедиться, что новое состояние `intake_complete` и новый lib-класс не ломают существующие сценарии диалога и ActionCable-канала.
**Проверка:** `bundle exec rspec spec/models/dialog_spec.rb spec/channels/chat_channel_spec.rb spec/lib/learning/intake_completeness_check_spec.rb` — всё зелёное.

## Зависимости между шагами

- Шаг 2 требует шага 1, потому что runtime-код должен опираться на зафиксированный output-контракт template
- Шаг 3 требует шага 2, потому что RBS должен описывать уже реализованный API
- Шаг 4 требует шага 2 и использует step-1 contract для парсинга результата
- Шаг 5 выполняется последним, потому что это интеграционная проверка поверх готового runtime-кода и unit-спеков
