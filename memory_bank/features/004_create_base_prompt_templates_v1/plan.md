# Базовые prompt templates v1 — план реализации

## Обзор подхода

Сначала создаём файловую структуру prompt templates внутри `learning/prompts/`, затем пишем сами markdown-файлы с единым YAML front matter и в конце добавляем отдельную проверку, что каталог templates соответствует контракту.

## Шаги

### 1. Создать каталоги prompt templates
**Файлы:** `learning/prompts/intake/.gitkeep` (новый), `learning/prompts/conspect/.gitkeep` (новый)
**Что делаем:** Создать подкаталоги `learning/prompts/intake/` и `learning/prompts/conspect/`, чтобы дальнейшие template-файлы лежали в зафиксированной структуре.
**Проверка:** В проекте существуют `learning/prompts/intake/` и `learning/prompts/conspect/`.

### 2. Добавить intake prompt templates
**Файлы:** `learning/prompts/intake/system_role.md` (новый), `learning/prompts/intake/ask_missing_context.md` (новый), `learning/prompts/intake/check_completeness.md` (новый), `learning/prompts/intake/build_brief.md` (новый)
**Что делаем:** Создать четыре intake template-файла с YAML front matter (`id`, `purpose`, `expected_output`, `required_variables`) и непустым markdown-телом.
**Проверка:** Все четыре файла существуют и содержат YAML front matter с обязательными ключами.

### 3. Добавить conspect prompt templates
**Файлы:** `learning/prompts/conspect/build_prompt.md` (новый), `learning/prompts/conspect/self_review.md` (новый)
**Что делаем:** Создать два conspect template-файла в той же форме и с теми же обязательными ключами front matter.
**Проверка:** Оба файла существуют и содержат YAML front matter с обязательными ключами.

### 4. Привести placeholders и metadata к одному контракту
**Файлы:** все файлы из шагов 2–3 (изменить)
**Что делаем:** Пройтись по всем template-файлам и выровнять placeholders в формате `{{variable_name}}`, а также удостовериться, что все использованные переменные перечислены в `required_variables`.
**Проверка:** В каждом template используются только placeholders вида `{{variable_name}}`, и каждый из них перечислен в `required_variables`.

### 5. Синхронизировать `learning/process.md` с реальным набором templates
**Файлы:** `learning/process.md` (изменить)
**Что делаем:** Обновить файл процесса из задачи 002, чтобы в нём был указан фактический стартовый каталог prompt templates и перечислены базовые intake/conspect templates первой версии.
**Проверка:** `learning/process.md` отражает реальные template-файлы, созданные на шагах 2–3.

### 6. Добавить проверку файлового контракта templates
**Файлы:** `spec/lib/learning/prompt_catalog_spec.rb` (новый)
**Что делаем:** Добавить отдельный spec, который сканирует `learning/prompts/`, проверяет наличие шести файлов, обязательные ключи front matter и отсутствие пустых тел.
**Проверка:** `bundle exec rspec spec/lib/learning/prompt_catalog_spec.rb` — всё зелёное.

### 7. Прогнать существующие тесты проекта
**Файлы:** `spec/lib/learning/prompt_catalog_spec.rb` (проверка), существующие spec-файлы (проверка)
**Что делаем:** После добавления prompt templates и нового spec прогнать существующий набор тестов, чтобы убедиться, что файловая фича не затронула остальной код.
**Проверка:** `bundle exec rspec` завершается без ошибок.

## Зависимости между шагами

- Шаги 2–3 требуют шага 1, потому что template-файлы должны создаваться в уже существующих каталогах
- Шаг 4 требует шагов 2–3, потому что выравнивает уже созданные файлы
- Шаг 5 требует шага 4, потому что `learning/process.md` должен отражать фактический итоговый каталог templates
- Шаг 6 требует шагов 2–4, потому что spec проверяет уже согласованный контракт template-файлов
- Шаг 7 выполняется последним после появления всех файлов и проверок
