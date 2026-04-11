# Current Focus

> Этот файл обновляется в конце каждой сессии и читается в начале следующей.
> Агент: прочитай этот файл первым при Resume/Continue сессии, затем `memory_bank/index.md`.

---

## Активная задача

**Фича:** [005 — Runner для markdown prompt templates](../features/005_add_markdown_prompt_runner/)
**Статус:** brief + spec + plan готовы, реализация не начата
**Следующий шаг:** реализация — читать `005_add_markdown_prompt_runner/plan.md`

## Следующие в очереди

1. [006 — Проверка полноты intake-диалога](../features/006_add_dialog_intake_completeness_check/) — зависит от 003, 005

## Контекст последней сессии

Что сделано:
- [x] Созданы каталоги `learning/prompts/intake/` и `learning/prompts/conspect/`
- [x] Добавлены 4 intake templates: system_role.md, ask_missing_context.md, check_completeness.md, build_brief.md
- [x] Добавлены 2 conspect templates: build_prompt.md, self_review.md
- [x] Все placeholders приведены к формату `{{variable_name}}`, required_variables выровнены
- [x] `learning/process.md` обновлён — отражает реальный набор templates
- [x] Добавлен `spec/lib/learning/prompt_catalog_spec.rb` — 7 примеров, все зелёные
- [x] Полный `bundle exec rspec` — 68 примеров, 0 failures
- [x] Смёрджено в main, worktree удалён

Что осталось:
- [ ] —

Открытые вопросы / решения нужные от человека:
- —

## Инструкция для агента: Resume

1. Прочитай этот файл
2. Прочитай brief + spec активной фичи
3. Уточни у пользователя если "следующий шаг" недостаточно ясен
4. Не читай весь memory bank — только то что относится к активной задаче

## Инструкция: обновление в конце сессии

После завершения работы обнови этот файл:
1. **Активная задача** — обнови статус или смени на следующую
2. **Следующий шаг** — что конкретно делать в начале следующей сессии
3. **Контекст** — что сделано, что осталось, какие открытые вопросы
4. Не пиши историю — только актуальное состояние. Старый контекст перезаписывай.
