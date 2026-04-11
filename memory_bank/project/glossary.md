# Domain Glossary

## Сущности БД

**Dialog** — диалог пользователя с LLM. Хранится в Postgres. Содержит заголовок, workflow-поля и ссылку на тему.
- `title` — первые 50 символов первого сообщения
- `goal` — цель работы над темой (вводится пользователем в начале)
- `workflow_state` — текущая стадия обработки (см. Workflow States)
- `current_brief` — YAML-текст структурированного brief, NULL до `brief_ready` (шаг 007). Хранится только в БД, НЕ пишется в файловую систему до `conspect_generated`
- `current_conspect_prompt` — финальный промпт для генерации конспекта, NULL до `prompt_ready` (шаг 008)
- `topic_slug` — идентификатор темы, NULL до `conspect_generated` (шаг 009). Присваивается только после успешной первой генерации

**Message** — сообщение в диалоге. Всегда принадлежит Dialog.
- `role` — строго `"user"` или `"assistant"`
- `content` — текст сообщения

## Файловые сущности

**Topic** — учебная тема. Идентифицируется по `topic_slug`. Каталог `learning/topics/<topic_slug>/` создаётся только после первой успешной генерации конспекта.

**topic_slug** — уникальный идентификатор темы: строчные латинские буквы, цифры и дефисы (`\A[a-z0-9]+(?:-[a-z0-9]+)*\z`). Уникален в пределах `learning/topics/`.

**Conspect** — структурированный конспект по теме. Markdown-файл. Актуальная версия — `learning/topics/<slug>/conspects/current.md`. Предыдущие версии — в `versions/`.

**Prompt Template** — markdown-шаблон промпта для конкретного LLM-сценария. Хранится в `learning/prompts/`. Не является CRUD-сущностью.

**Brief** (доменный) — структурированный набор параметров темы (goal, topic_boundaries, difficulty_level, constraints, adjacent_topics, expected_outcome). Первично хранится в `Dialog#current_brief` как YAML (создаётся на шаге 007, `brief_ready`). Файловая копия `brief.md` создаётся позже, на шаге 009, внутри каталога темы. Не путать с feature Brief — артефактом процесса разработки.

**meta.yml** — служебный файл темы с обязательными ключами: `topic_slug`, `source_dialog_id`, `created_at`, `updated_at`, `current_state`.

## Процессы и стадии

**Intake** — процесс сбора информации о теме через диалог. Завершается переходом в `intake_complete`.

**Workflow States** — допустимые значения `Dialog#workflow_state` с указанием что меняется на каждом шаге:

```
collecting_info          ← начальное состояние; topic_slug=NULL, current_brief=NULL
intake_complete          ← intake завершён (шаг 006); topic_slug=NULL
brief_ready              ← current_brief заполнен YAML (шаг 007); topic_slug=NULL
prompt_ready             ← current_conspect_prompt заполнен (шаг 008); topic_slug=NULL
conspect_generated       ← topic_slug присвоен, learning/topics/<slug>/ создан (шаг 009)
conspect_reviewed        ← конспект принят (шаг 010)
conspect_needs_revision  ← конспект требует доработки (шаг 010)
```

**Ключевое:** `topic_slug` остаётся NULL вплоть до `conspect_generated`. До этого момента тема существует только как состояние диалога в БД.

## Технические компоненты

**ChatChannel** — ActionCable-канал. Обрабатывает отправку сообщений, сохранение в БД, вызов LLM, бродкаст ответа и истории диалога.

**RubyLLM** — клиент для взаимодействия с LLM API. Единый интерфейс для разных провайдеров.

**PromptRunner** — механизм запуска markdown prompt templates (фича 005). Устраняет дублирование кода вызова модели.

**Completeness Check** — шаг проверки полноты intake-диалога перед генерацией brief (фича 006).

## Связи между сущностями

```
Dialog ──has_many──> Message
Dialog ──(topic_slug)──> Topic (learning/topics/<slug>/)
Topic ──has──> Conspect (conspects/current.md)
Topic ──has──> Brief (brief.md)
Topic ──has──> ConspeсtPrompt (conspect_prompt.md)
```
