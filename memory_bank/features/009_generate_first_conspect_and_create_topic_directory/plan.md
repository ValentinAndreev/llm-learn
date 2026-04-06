# Первая генерация conspect и создание директории темы — план реализации

## Обзор подхода

Сначала выносим файловую часть в отдельный слой под `lib/learning`, затем добавляем генератор первого conspect, который валидирует состояние диалога, вызывает LLM по `current_conspect_prompt`, создаёт `topic_slug`, записывает файлы темы и только после успешной записи обновляет `Dialog`.

## Шаги

### 1. Реализовать генерацию и проверку `topic_slug`
**Файлы:** `lib/learning/topic_slug.rb` (новый), `sig/learning/topic_slug.rbs` (новый)
**Что делаем:** Добавить helper, который строит slug из `goal` или `title`, приводит строку к формату `[a-z0-9-]` и разрешает коллизии через суффиксы `-2`, `-3` и дальше.
**Проверка:** Для занятых slug helper возвращает следующий уникальный вариант в пределах `learning/topics/`.

### 2. Реализовать файловый writer темы
**Файлы:** `lib/learning/topic_storage.rb` (новый), `sig/learning/topic_storage.rbs` (новый)
**Что делаем:** Добавить класс, который умеет создавать каталог `learning/topics/<topic_slug>/`, писать `meta.yml`, `brief.md`, `conspect_prompt.md`, `conspects/current.md`, а также создавать `conspects/versions/`, `reviews/` и `reviews/history/`; предусмотреть cleanup частично созданного каталога при ошибке.
**Проверка:** Writer создаёт все обязательные файлы и директории по контракту хранения, включая `reviews/history/`, и удаляет частично созданный каталог при искусственно вызванной ошибке записи.

### 3. Реализовать first conspect generator
**Файлы:** `lib/learning/first_conspect_generator.rb` (новый), `sig/learning/first_conspect_generator.rbs` (новый)
**Что делаем:** Добавить класс, который валидирует `workflow_state = prompt_ready`, наличие `current_conspect_prompt`, отсутствие `topic_slug`, вызывает RubyLLM для генерации текста conspect, запрашивает уникальный slug у `TopicSlug`, пишет тему через `TopicStorage` и только затем обновляет `Dialog#topic_slug` и `workflow_state`.
**Проверка:** На success диалог получает `topic_slug` и `conspect_generated`; при `invalid_state`, `missing_prompt` и `topic_already_exists` LLM не вызывается и каталог темы не создаётся, а при `empty_conspect` каталог темы не создаётся.

### 4. Добавить unit-спеки для slug и файлового слоя
**Файлы:** `spec/lib/learning/topic_slug_spec.rb` (новый), `spec/lib/learning/topic_storage_spec.rb` (новый)
**Что делаем:** Покрыть генерацию уникального slug, формат slug, запись всех обязательных файлов и директорий по контракту хранения, а также cleanup при ошибке записи на диск.
**Проверка:** `bundle exec rspec spec/lib/learning/topic_slug_spec.rb spec/lib/learning/topic_storage_spec.rb` — всё зелёное.

### 5. Добавить unit-спеки для first conspect generator
**Файлы:** `spec/lib/learning/first_conspect_generator_spec.rb` (новый)
**Что делаем:** Покрыть `invalid_state`, `missing_prompt`, `topic_already_exists`, `empty_conspect`, success path, а также атомарность обновления `Dialog` только после успешной записи на диск.
**Проверка:** `bundle exec rspec spec/lib/learning/first_conspect_generator_spec.rb` — всё зелёное.

### 6. Прогнать связанный набор тестов и типизацию
**Файлы:** новые файлы из шагов 1–5 (проверка), `sig/dialog.rbs` (проверка при необходимости)
**Что делаем:** Проверить, что новый файловый слой и генератор корректно встраиваются в существующий workflow-путь от `current_conspect_prompt` к `topic_slug`.
**Проверка:** `bundle exec rspec spec/lib/learning/topic_slug_spec.rb spec/lib/learning/topic_storage_spec.rb spec/lib/learning/first_conspect_generator_spec.rb` и `bundle exec steep check` завершаются без ошибок.

## Зависимости между шагами

- Шаг 2 требует шага 1, потому что файловый writer должен получать уже нормализованный и уникальный `topic_slug`
- Шаг 3 требует шагов 1–2, потому что генератор использует и slug helper, и файловый writer
- Шаг 4 требует шагов 1–2, а шаг 5 требует шага 3
- Шаг 6 выполняется последним как общая проверка файлового слоя, генератора и типизации
