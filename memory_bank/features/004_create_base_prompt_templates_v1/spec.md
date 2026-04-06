# Базовые prompt templates v1

**Brief:** `memory_bank/features/004_create_base_prompt_templates_v1/brief.md`

## Цель

Вынести базовые prompt templates в файловый слой, чтобы сценарии intake и генерации conspect редактировались отдельно от Ruby-кода.

## Scope

- Входит (2 компонента: файловая структура prompt templates, контракт их содержимого):
  - Создание каталогов `learning/prompts/intake/` и `learning/prompts/conspect/`
  - Создание базовых markdown templates для intake и conspect flow
  - Единый формат metadata и placeholders для всех templates
- НЕ входит:
  - Выполнение templates через LLM
  - UI для просмотра и редактирования templates
  - Версионирование templates

## Требования

1. Должны быть созданы каталоги `learning/prompts/intake/` и `learning/prompts/conspect/`.
2. Должны быть созданы файлы:
   - `learning/prompts/intake/system_role.md`
   - `learning/prompts/intake/ask_missing_context.md`
   - `learning/prompts/intake/check_completeness.md`
   - `learning/prompts/intake/build_brief.md`
   - `learning/prompts/conspect/build_prompt.md`
   - `learning/prompts/conspect/self_review.md`
3. Каждый template должен быть markdown-файлом с YAML front matter.
4. В YAML front matter каждого template должны быть обязательные ключи: `id`, `purpose`, `expected_output`, `required_variables`.
5. Тело каждого template должно быть непустым и должно содержать текст prompt.
6. Переменные в template должны записываться в формате `{{variable_name}}`.
7. Все переменные, использованные в теле template, должны быть перечислены в `required_variables`.
8. Значение `id` должно быть уникальным среди всех templates.

## Инварианты

- Все templates хранятся как обычные текстовые markdown-файлы
- У каждого template есть уникальный `id`
- Ни один template не имеет пустого тела
- Для новых LLM-сценариев этой фичи source of truth — файловые templates

## Acceptance Criteria

- [ ] Созданы каталоги `learning/prompts/intake/` и `learning/prompts/conspect/`
- [ ] Созданы все 6 базовых template-файлов
- [ ] У каждого template есть YAML front matter с ключами `id`, `purpose`, `expected_output`, `required_variables`
- [ ] Тело каждого template непустое
- [ ] Во всех template используется единый формат placeholders `{{variable_name}}`
- [ ] Все placeholders перечислены в `required_variables`
- [ ] Значения `id` не дублируются
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Не добавлять runtime-логику выполнения templates в этой фиче
- Не добавлять UI
- Не добавлять новые гемы
