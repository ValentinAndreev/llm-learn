# Features Index

## Реализованные

| ID | Название | Статус | Ключевые сущности |
|---|---|---|---|
| [001](001_save_dialogs/) | Сохранение диалогов | ✅ реализована | Dialog, Message, DialogsController |
| [002](002_define_learning_storage_contract/) | Контракт хранения учебных артефактов | ✅ реализована | learning/, process.md |
| [003](003_add_dialog_learning_workflow_fields/) | Workflow-поля диалога | ✅ реализована | Dialog#workflow_state, goal, topic_slug, current_conspect_prompt |

## Готовы к реализации (brief + spec + plan есть)

| ID | Название | Статус | Зависит от |
|---|---|---|---|
| [004](004_create_base_prompt_templates_v1/) | Базовые prompt templates v1 | 🔜 готова к реализации | 002 |
| [005](005_add_markdown_prompt_runner/) | Runner для markdown prompt templates | 🔜 готова к реализации | 004 |
| [006](006_add_dialog_intake_completeness_check/) | Проверка полноты intake-диалога | 🔜 готова к реализации | 003, 005 |
| [007](007_generate_dialog_brief/) | Генерация brief из диалога | 🔜 готова к реализации | 006 |
| [008](008_build_final_conspect_prompt/) | Сборка финального prompt на conspect | 🔜 готова к реализации | 007 |
| [009](009_generate_first_conspect_and_create_topic_directory/) | Первая генерация conspect и создание директории темы | 🔜 готова к реализации | 008 |
| [010](010_add_conspect_self_review_and_regeneration_loop/) | Self-review conspect и цикл регенерации | 🔜 готова к реализации | 009 |

## Feature Package Structure

Каждая фича содержит три файла:
```
features/<id>_<name>/
  brief.md   ← проблема и цель (без решения)
  spec.md    ← TAUS-спека: scope, требования, инварианты, acceptance criteria
  plan.md    ← пошаговый план реализации с файлами и проверками
```
