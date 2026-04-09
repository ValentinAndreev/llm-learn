# Контракт хранения учебных артефактов

`learning/` — корневая файловая область для prompt templates и артефактов учебных тем. Этот документ фиксирует, какие данные живут в БД, какие переходят в файловую структуру и в каком виде должна выглядеть тема после первой успешной генерации conspect.

## Граница между БД и файловой структурой

### Что остаётся в БД

- `Dialog` и `Message` остаются источником истины для диалогов и сообщений.
- Workflow-поля `Dialog` остаются в БД: текущее состояние процесса, цель, `topic_slug`, промежуточные результаты вроде brief и актуального conspect prompt.
- Пока первая генерация conspect не завершилась успешно, тема существует только как состояние диалога в БД; каталога в `learning/topics/` для неё ещё нет.

### Что хранится в `learning/`

- В `learning/prompts/` лежат общие markdown templates, используемые шагами intake и conspect workflow.
- В `learning/topics/` лежат файловые артефакты конкретной темы: снимок brief, использованный conspect prompt, текущий conspect, его версии и review-артефакты.
- `.gitkeep` допустимы только как служебные файлы git и не считаются runtime-артефактами контракта.

## Корневая структура

Базовое дерево `learning/` выглядит так:

```text
learning/
  process.md
  prompts/
  topics/
```

- `learning/prompts/` содержит только shared prompt templates, их подкаталоги и служебный `.gitkeep`, пока каталог ещё пустой.
- `learning/topics/` содержит только каталоги вида `learning/topics/<topic_slug>/` и служебный `.gitkeep` на корневом уровне, пока в репозитории ещё нет ни одной темы.

## Жизненный цикл каталога темы

Каталог `learning/topics/<topic_slug>/` создаётся только после первой успешной генерации непустого conspect. До этого момента:

- у диалога может накапливаться контекст и workflow-поля в БД;
- prompt templates уже могут существовать в `learning/prompts/`;
- каталога темы на диске быть не должно.

После успешной первой генерации файловый слой обязан создать полный стартовый набор артефактов темы. Если запись на диск оборвалась ошибкой, частично созданный каталог темы считается невалидным и должен быть удалён целиком.

## Обязательная структура темы после первой успешной генерации

Каждая тема занимает ровно один каталог:

```text
learning/topics/<topic_slug>/
  meta.yml
  brief.md
  conspect_prompt.md
  conspects/
    current.md
    versions/
  reviews/
    history/
```

Обязательные артефакты первой успешной генерации:

- `meta.yml`
- `brief.md`
- `conspect_prompt.md`
- `conspects/current.md`

Обязательные служебные директории:

- `conspects/versions/`
- `reviews/`
- `reviews/history/`

Правила для review-артефактов:

- `reviews/latest.md` не обязателен в момент первой генерации темы.
- `reviews/latest.md` появляется только после первого успешного review.
- `reviews/history/` резервируется сразу, чтобы последующие review можно было архивировать без изменения контракта каталога.

## Формат `meta.yml`

У каждой темы всегда есть `meta.yml` со следующими обязательными ключами:

```yaml
topic_slug: linear-algebra-basics
source_dialog_id: 42
created_at: 2026-04-09T10:15:00Z
updated_at: 2026-04-09T10:15:00Z
current_state: conspect_generated
```

Семантика полей:

- `topic_slug` — slug темы; обязан совпадать с именем каталога в `learning/topics/`.
- `source_dialog_id` — идентификатор `Dialog`, из которого впервые была создана тема.
- `created_at` — момент первого успешного создания каталога темы в формате ISO 8601 UTC.
- `updated_at` — момент последнего успешного изменения файлов темы в формате ISO 8601 UTC.
- `current_state` — текущее файловое состояние темы; на первой успешной генерации это `conspect_generated`, далее значение должно обновляться вместе с успешными workflow-переходами темы.

Если будущая фича добавляет новые ключи в `meta.yml`, она обязана отдельно зафиксировать это в своей спецификации. Базовый контракт гарантирует наличие только перечисленных выше полей.

## Правила `topic_slug`

`topic_slug` должен удовлетворять всем правилам:

- содержит только строчные латинские буквы, цифры и дефисы;
- не содержит пробелов, подчёркиваний, слешей и других символов;
- не начинается и не заканчивается дефисом;
- не содержит подряд идущих дефисов;
- уникален в пределах `learning/topics/`.

Нормативный шаблон:

```text
\A[a-z0-9]+(?:-[a-z0-9]+)*\z
```

Примеры корректных slug:

- `linear-algebra-basics`
- `ruby-on-rails-101`
- `git`

Примеры некорректных slug:

- `Linear Algebra`
- `linear_algebra`
- `-linear-algebra`
- `linear--algebra`

## Роль артефактов темы

- `brief.md` — markdown-снимок brief, по которому была создана тема.
- `conspect_prompt.md` — prompt, который использовался для генерации текущего conspect.
- `conspects/current.md` — актуальная версия conspect.
- `conspects/versions/` — архив предыдущих версий conspect.
- `reviews/latest.md` — последний актуальный review темы, если review уже выполнялся.
- `reviews/history/` — архив предыдущих review.

## Пример корректного состояния

```text
learning/
  prompts/
    intake/
      build_brief.md
    conspect/
      build_prompt.md
      self_review.md
  topics/
    linear-algebra-basics/
      meta.yml
      brief.md
      conspect_prompt.md
      conspects/
        current.md
        versions/
      reviews/
        history/
```

Почему это корректно:

- каталог темы создан по валидному `topic_slug`;
- все обязательные файлы первой генерации на месте;
- все обязательные служебные директории на месте;
- review-слой уже подготовлен, даже если `reviews/latest.md` ещё не создан.

## Пример некорректного состояния

```text
learning/
  topics/
    Linear_Algebra/
      brief.md
      conspects/
        draft.md
      reviews/
```

Почему это некорректно:

- `Linear_Algebra` нарушает правила `topic_slug`;
- отсутствует `meta.yml`;
- отсутствует `conspect_prompt.md`;
- отсутствует обязательный файл `conspects/current.md`;
- отсутствуют `conspects/versions/` и `reviews/history/`;
- такой каталог нельзя считать валидной conspect-темой и его нельзя использовать как источник истины.
