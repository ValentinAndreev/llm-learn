# Runner для markdown prompt templates — план реализации

## Обзор подхода

Выносим работу с markdown templates в `lib/learning`: сначала делаем загрузчик и валидатор template-файла, затем отдельный runner для подстановки переменных и вызова RubyLLM, после чего закрываем failure-сценарии unit-спеками и RBS.

## Шаги

### 1. Реализовать загрузку и валидацию prompt template
**Файлы:** `lib/learning/prompt_template.rb` (новый)
**Что делаем:** Добавить класс, который разрешает путь только внутри `learning/prompts/`, читает markdown-файл, парсит YAML front matter, проверяет обязательные ключи и извлекает placeholders из тела template.
**Проверка:** Из `lib/learning/prompt_template.rb` можно загрузить существующий template; при невалидном front matter класс возвращает явную ошибку.

### 2. Реализовать подстановку переменных и вызов RubyLLM
**Файлы:** `lib/learning/prompt_runner.rb` (новый)
**Что делаем:** Добавить синхронный runner, который принимает template и variables, валидирует `required_variables`, рендерит итоговый prompt, затем вызывает текущую интеграцию через `RubyLLM.chat(model: ...)`, передаёт рендеренный prompt как одно пользовательское сообщение и получает первый текстовый ответ модели; далее runner возвращает success/failure с кодами `template_not_found`, `invalid_template`, `missing_variables`, `empty_response`, `llm_error`.
**Проверка:** Runner возвращает явный success на валидном template и явный failure на каждом из failure-кейсов из спеки.

### 3. Добавить RBS для loader и runner
**Файлы:** `sig/learning/prompt_template.rbs` (новый), `sig/learning/prompt_runner.rbs` (новый)
**Что делаем:** Описать публичный API loader и runner, включая типы входных variables и структуру success/failure результата.
**Проверка:** `bundle exec steep check` не выдаёт ошибок по новым файлам.

### 4. Покрыть loader unit-спеками
**Файлы:** `spec/lib/learning/prompt_template_spec.rb` (новый)
**Что делаем:** Добавить спеки на загрузку существующего template, невалидный front matter, пустое тело и выход за пределы `learning/prompts/`.
**Проверка:** `bundle exec rspec spec/lib/learning/prompt_template_spec.rb` — всё зелёное.

### 5. Покрыть runner unit-спеками
**Файлы:** `spec/lib/learning/prompt_runner_spec.rb` (новый)
**Что делаем:** Добавить спеки на success path, отсутствие template, невалидный template, отсутствие обязательных переменных, пустой ответ модели и исключение RubyLLM.
**Проверка:** `bundle exec rspec spec/lib/learning/prompt_runner_spec.rb` — всё зелёное.

### 6. Прогнать существующие тесты и проверить совместимость
**Файлы:** новые файлы из шагов 1–5 (проверка), `config/initializers/ruby_llm.rb` (проверка без изменений)
**Что делаем:** Убедиться, что новый runner использует текущую интеграцию RubyLLM без изменений в initializers и не ломает существующие тесты проекта.
**Проверка:** `bundle exec rspec` и `bundle exec steep check` завершаются без ошибок.

## Зависимости между шагами

- Шаг 2 требует шага 1, потому что runner опирается на валидный объект template
- Шаг 3 требует шагов 1–2, потому что RBS должен описывать уже зафиксированный публичный API
- Шаг 4 требует шага 1, а шаг 5 требует шагов 1–2
- Шаг 6 выполняется последним после появления runtime-кода, RBS и unit-спеков
