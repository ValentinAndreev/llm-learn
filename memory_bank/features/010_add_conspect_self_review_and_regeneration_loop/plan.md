# Self-review conspect и цикл регенерации — план реализации

## Обзор подхода

Сначала фиксируем структурированный output для self-review template, затем расширяем файловый слой архивированием conspect и review. После этого отдельно реализуем автоматический self-review и ручную регенерацию на базе уже существующих `topic_slug`, `current_conspect_prompt` и файлов темы из задачи 009.

## Шаги

### 1. Уточнить output-контракт self-review template
**Файлы:** `learning/prompts/conspect/self_review.md` (изменить)
**Что делаем:** Зафиксировать в template обязательные разделы `Verdict`, `Issues`, `Suggestions` и ограничить `Verdict` значениями `pass` / `revise`.
**Проверка:** Из template однозначно следует требуемый формат review и допустимые значения `Verdict`.

### 2. Расширить файловый слой для review и архивов
**Файлы:** `lib/learning/topic_storage.rb` (изменить), `sig/learning/topic_storage.rbs` (изменить)
**Что делаем:** Добавить в файловый слой методы для записи `reviews/latest.md`, архивирования предыдущего review в `reviews/history/<timestamp>.md` и архивирования предыдущего `conspects/current.md` в `conspects/versions/<timestamp>.md`.
**Проверка:** Writer умеет отдельно архивировать текущий conspect и текущий review без потери уже записанных файлов.

### 3. Реализовать автоматический self-review
**Файлы:** `lib/learning/conspect_review.rb` (новый), `sig/learning/conspect_review.rbs` (новый)
**Что делаем:** Добавить класс, который запускает `learning/prompts/conspect/self_review.md` через prompt runner, валидирует `Verdict`, записывает `reviews/latest.md` через `TopicStorage` и обновляет `workflow_state` на `conspect_reviewed` или `conspect_needs_revision`.
**Проверка:** При `pass` и `revise` review записывается и `workflow_state` обновляется; при `invalid_review` `reviews/latest.md` не перезаписывается, а `workflow_state` остаётся `conspect_generated`.

### 4. Добавить orchestration для первой генерации + self-review
**Файлы:** `lib/learning/conspect_generation_flow.rb` (новый), `sig/learning/conspect_generation_flow.rbs` (новый)
**Что делаем:** Добавить orchestration-класс, который использует `FirstConspectGenerator` из задачи 009 и сразу после его успеха передаёт управление в `ConspectReview`, не расширяя прямой скоуп runtime-кода самой задачи 009.
**Проверка:** После успешной первой генерации автоматически появляется `reviews/latest.md` и корректно обновляется `workflow_state`.

### 5. Реализовать ручную регенерацию conspect
**Файлы:** `lib/learning/conspect_regenerator.rb` (новый), `sig/learning/conspect_regenerator.rbs` (новый)
**Что делаем:** Добавить класс, который разрешает ручную регенерацию только из `conspect_reviewed` и `conspect_needs_revision`, генерирует новый conspect по `current_conspect_prompt`, архивирует старый `conspects/current.md`, при необходимости архивирует `reviews/latest.md`, записывает новый current conspect и затем запускает `ConspectReview`.
**Проверка:** При ручной регенерации новый каталог темы не создаётся, а старые conspect/review архивируются до записи новых.

### 6. Покрыть self-review и регенерацию unit-спеками
**Файлы:** `spec/lib/learning/conspect_review_spec.rb` (новый), `spec/lib/learning/conspect_generation_flow_spec.rb` (новый), `spec/lib/learning/conspect_regenerator_spec.rb` (новый), `spec/lib/learning/topic_storage_spec.rb` (изменить)
**Что делаем:** Добавить спеки на `invalid_review`, `pass`, `revise`, интеграцию первой генерации с review, `invalid_state` для ручной регенерации, архивирование conspect/review и сохранение текущих файлов при failure.
**Проверка:** `bundle exec rspec spec/lib/learning/conspect_review_spec.rb spec/lib/learning/conspect_generation_flow_spec.rb spec/lib/learning/conspect_regenerator_spec.rb spec/lib/learning/topic_storage_spec.rb` — всё зелёное.

### 7. Прогнать связанный workflow-набор и типизацию
**Файлы:** новые и изменённые файлы из шагов 1–6 (проверка), `lib/learning/first_conspect_generator.rb` (проверка интеграции)
**Что делаем:** Проверить полную цепочку: первая генерация -> автоматический self-review -> ручная регенерация -> повторный self-review.
**Проверка:** `bundle exec rspec spec/lib/learning/first_conspect_generator_spec.rb spec/lib/learning/conspect_review_spec.rb spec/lib/learning/conspect_generation_flow_spec.rb spec/lib/learning/conspect_regenerator_spec.rb spec/lib/learning/topic_storage_spec.rb` и `bundle exec steep check` завершаются без ошибок.

## Зависимости между шагами

- Шаг 2 требует задачи 009, потому что расширяет уже существующий файловый слой темы
- Шаг 3 требует шагов 1–2, потому что self-review должен опираться на фиксированный output template и готовый writer
- Шаг 4 требует шага 3 и зависит от `FirstConspectGenerator` из задачи 009
- Шаг 5 требует шагов 2–3, потому что регенерация использует и архивирование, и повторный self-review
- Шаг 6 требует шагов 2–5
- Шаг 7 выполняется последним как полная проверка всей цепочки генерации и регенерации
