# Memory Bank — Project Index

## Document Map

| Документ | Что содержит | Читать при |
|---|---|---|
| [process/current-focus.md](process/current-focus.md) | Активная задача, следующий шаг, контекст сессии | **Resume** (первым) |
| [workflow.md](workflow.md) | Цикл Brief→Spec→Plan→Impl, routing rules, stage gates | Любой flow |
| [project/overview.md](project/overview.md) | Product frame, scope, что НЕ строим, ключевые решения | Orient, Spec |
| [project/glossary.md](project/glossary.md) | Доменные термины и связи между сущностями | Orient, Spec, Review |
| [engineering/conventions.md](engineering/conventions.md) | Testing rules, coding style, autonomy boundaries, git | Spec, Plan, Implement |
| [ops/development.md](ops/development.md) | Локальная среда, команды, БД, Steep, credentials | Plan, Implement |
| [ops/ci.md](ops/ci.md) | GitHub Actions workflows, требования для CI | Review, Verify |
| [features/index.md](features/index.md) | Список фич со статусом и ссылками | Orient, Resume |
| [prd.md](prd.md) | Product Requirements Document | Orient, Spec |

## Reading Hierarchy by Flow

### Orient / Triage — вход в проект или восстановление контекста
1. Этот файл (index.md)
2. `project/overview.md` — рамка продукта
3. `project/glossary.md` — термины
4. `features/index.md` → нужный feature package

### Spec — написание спецификации
1. Апрувнутый brief (в feature package)
2. `project/glossary.md` — убедиться в терминах
3. `engineering/conventions.md` — ограничения и инварианты
4. `prd.md` — если неясен scope

### Plan / Implement — планирование и реализация
1. Финальная spec (в feature package)
2. `engineering/conventions.md` — testing rules, coding style
3. Релевантные существующие файлы кода (читать по месту)

### Review / Verify — ревью артефактов или кода
1. Spec + plan из feature package
2. Соответствующий `reviews/<stage>.md`, если это re-review после исправлений
3. `engineering/conventions.md`
4. Промпты: `.prompts/spec.md`, `.prompts/plan.md`, `.prompts/review-code.md`, `.prompts/fix-review.md`

### Resume / Continue — продолжение прерванной работы
1. `process/current-focus.md` — активная задача, текущий этап, следующий шаг, `Review notes`
2. Feature package активной фичи: brief + spec + plan
3. Если в `current-focus.md` указан `Review notes`, прочитай этот файл перед продолжением
4. `engineering/conventions.md` если нужны правила

## Priming Prompts

| Промпт | Назначение |
|---|---|
| `.prompts/orient.md` | Старт сессии / восстановление контекста |
| `.prompts/brief.md` | Создание и ревью Brief |
| `.prompts/spec.md` | Создание и ревью Spec |
| `.prompts/plan.md` | Создание и ревью Plan |
| `.prompts/review-code.md` | Done-чеклист + code review |
| `.prompts/fix-review.md` | Исправление замечаний из review notes |


## Fail-Fast Rule

Если обязательный входной артефакт команды отсутствует (`brief.md`, `spec.md`, `plan.md`, `reviews/<stage>.md`), агент сразу возвращает blocker-сообщение и не пытается восстановить контекст по downstream-артефактам.

## Быстрые команды

| Команда | Что делает |
|---|---|
| `resume` | продолжить с того места где остановились |
| `orient` | понять где проект и что дальше |
| `brief: <task>` | написать brief для новой фичи |
| `review brief: <id>` | проверить brief |
| `spec: <id>` | написать spec по готовому brief |
| `review spec: <id>` | проверить spec |
| `plan: <id>` | написать plan по готовой spec |
| `review plan: <id>` | проверить plan |
| `impl: <id>` | реализовать по готовому plan |
| `review: <id>` | code review готовой реализации и сохранить результат в `reviews/impl.md` |
| `fix review: <id> <stage>` | прочитать `reviews/<stage>.md`, исправить соответствующий артефакт и обновить `current-focus` на повторный review той же стадии |
