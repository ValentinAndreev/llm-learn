# Workflow — Как мы работаем

## Базовый цикл фичи

```
Brief → Spec → Plan → Implement → Review
```

Каждый этап — отдельный артефакт, который проходит ревью перед переходом к следующему.
Промпты для каждого этапа: `.prompts/`

## Routing: какой цикл нужен

| Ситуация | Цикл |
|---|---|
| Маленькое изменение, scope очевиден, один файл | Сразу реализация без артефактов |
| Новая фича, затрагивает несколько слоёв | Полный цикл: Brief → Spec → Plan → Impl |
| Баг-фикс | Reproduce → Fix → Regression test |
| Рефакторинг | Analyse → Plan → Impl (без Brief) |

Правило: используй минимальный цикл, который не теряет контроль над риском.

## Stage Gates

### Brief → Spec
- [ ] Brief не содержит решения — только проблему
- [ ] Стейкхолдер назван
- [ ] Нет двусмысленных формулировок
- [ ] Явно написано что НЕ в скоупе

Промпт: `.prompts/brief.md` (секция ревью)

### Spec → Plan
- [ ] TAUS: Testable, Ambiguous-free, Uniform (все error states), Scoped (одна фича)
- [ ] Acceptance criteria конкретны и проверяемы
- [ ] Инварианты перечислены
- [ ] Ограничения реализации указаны

Промпт: `.prompts/spec.md` (секция ревью)

### Plan → Implement
- [ ] Каждый шаг атомарен и проверяем
- [ ] Порядок шагов учитывает зависимости
- [ ] Все acceptance criteria из spec покрыты шагами
- [ ] RBS-шаги для новых классов есть
- [ ] Grounding: упомянутые файлы существуют

Промпт: `.prompts/plan.md` (секция ревью)

### Implement → Done
- [ ] Все тесты зелёные (`bundle exec rspec`)
- [ ] Типы проверены (`bundle exec steep check`)
- [ ] `bundle exec rubocop` — lint
- [ ] `bin/brakeman --no-pager` — Ruby security
- [ ] `bin/bundler-audit` — уязвимости в gems
- [ ] `bin/importmap audit` — уязвимости в JS deps
- [ ] Все acceptance criteria из spec закрыты

Промпт: `.prompts/review-code.md` (чеклист + code review)

## Градиент участия человека

```
Бизнес-решения  ←  человек  |  агент  →  Реализация
PRD, Brief scope    Spec, Plan           Code, Tests
```

Чем ближе к scope и бизнес-ограничениям — тем больше подтверждений нужно.
Чем ближе к коду — тем больше агент работает автономно (в рамках `engineering/conventions.md`).

## Использование промптов

| Этап | Промпт | Что делает |
|---|---|---|
| Старт / Resume | `.prompts/orient.md` | Восстанавливает контекст проекта |
| Brief | `.prompts/brief.md` | Шаблон + критерии ревью |
| Spec | `.prompts/spec.md` | Шаблон + TAUS ревью |
| Plan | `.prompts/plan.md` | Шаблон + ревью на полноту |
| Review / Done | `.prompts/review-code.md` | Done-чеклист + code review |
