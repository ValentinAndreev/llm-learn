# Workflow — Как мы работаем

## Базовый цикл фичи

```
Brief → Spec → Plan → Implement → Review
```

Каждый этап — отдельный артефакт, который проходит ревью перед переходом к следующему.
Промпты для каждого этапа: `.prompts/`

## Fail Fast On Missing Inputs

- Команда не должна продолжать работу, если отсутствует обязательный входной артефакт текущей стадии.
- Нельзя подменять отсутствующий вход чтением downstream-артефактов или догадками по соседним файлам.
- Вместо этого процесс сразу прерывается сообщением в формате:
  `BLOCKER: missing <artifact>. Cannot run <command>. Next step: <what to create or run first>.`


## Review Notes

- Результат каждого review сохраняется рядом с feature package в `memory_bank/features/<id>_<name>/reviews/<stage>.md`.
- Допустимые `<stage>`: `brief`, `spec`, `plan`, `impl`.
- `reviews/` создаётся только при первом review конкретной фичи.
- В `reviews/<stage>.md` хранится только последнее состояние review по этой стадии.
- Если после исправлений делается повторный review, перезаписывается тот же файл; отдельный history-слой не нужен, историю хранит git.

## Fix After Review

Если review содержит замечания, используем короткий цикл:

```
Review → Fix Review Notes → Re-review той же стадии
```

Правило простоты:
- `review ...` только пишет или обновляет `reviews/<stage>.md`
- `fix review: <id> <stage>` читает `reviews/<stage>.md`, правит соответствующий артефакт и обновляет `current-focus` так, чтобы следующий шаг был повторным review той же стадии; если `reviews/<stage>.md` отсутствует — процесс сразу прерывается с blocker-сообщением
- Done достигается только когда последнее `reviews/<stage>.md` для текущей стадии больше не содержит замечаний

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
Преусловие: существует апрувнутый `brief.md`. Если файла нет — blocker, без попытки писать spec по косвенному контексту.

- [ ] Brief не содержит решения — только проблему
- [ ] Стейкхолдер назван
- [ ] Нет двусмысленных формулировок
- [ ] Явно написано что НЕ в скоупе

Промпт: `.prompts/brief.md` (секция ревью), review notes: `reviews/brief.md`

### Spec → Plan
Преусловие: существует финальный `spec.md`. Если файла нет — blocker, без попытки строить plan по brief или current-focus.

- [ ] TAUS: Testable, Ambiguous-free, Uniform (все error states), Scoped (одна фича)
- [ ] Acceptance criteria конкретны и проверяемы
- [ ] Инварианты перечислены
- [ ] Ограничения реализации указаны

Промпт: `.prompts/spec.md` (секция ревью), review notes: `reviews/spec.md`

### Plan → Implement
Преусловие: существует финальный `plan.md`. Если файла нет — blocker, без попытки идти в реализацию по одной только spec.

- [ ] Каждый шаг атомарен и проверяем
- [ ] Порядок шагов учитывает зависимости
- [ ] Все acceptance criteria из spec покрыты шагами
- [ ] RBS-шаги для новых классов есть
- [ ] Grounding: упомянутые файлы существуют

Промпт: `.prompts/plan.md` (секция ревью), review notes: `reviews/plan.md`

### Implement → Done
Преусловие: существуют `spec.md` и `plan.md`. Если одного из файлов нет — blocker, без попытки делать review только по коду.

- [ ] Все тесты зелёные (`bundle exec rspec`)
- [ ] Типы проверены (`bundle exec steep check`)
- [ ] `bundle exec rubocop` — lint
- [ ] `bin/brakeman --no-pager` — Ruby security
- [ ] `bin/bundler-audit` — уязвимости в gems
- [ ] `bin/importmap audit` — уязвимости в JS deps
- [ ] Все acceptance criteria из spec закрыты

Промпт: `.prompts/review-code.md` (чеклист + code review), review notes: `reviews/impl.md`
Если review нашёл замечания — использовать `.prompts/fix-review.md`, затем повторить review той же стадии.

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
| Fix Review | `.prompts/fix-review.md` | Читает `reviews/<stage>.md`, правит stage-артефакт и ставит следующий шаг на повторный review |
