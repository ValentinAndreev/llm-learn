# Контракт хранения учебных артефактов

**Brief:** `memory_bank/features/002_define_learning_storage_contract/brief.md`

## Цель

Зафиксировать единый контракт хранения prompt templates, conspect-файлов и файлов темы, чтобы следующие фичи опирались на один и тот же набор правил.

## Scope

- Входит (1 компонент: документация контракта хранения):
  - Корневая директория `learning/`
  - Файл `learning/process.md` с контрактом хранения и workflow
  - Явное разделение ответственности между БД и файловой структурой
  - Описание корневых директорий `learning/prompts/` и `learning/topics/`
  - Описание жизненного цикла создания каталога conspect-темы
  - Описание обязательных файлов и директорий первой версии conspect-темы
  - Описание review-артефактов conspect-темы, включая `reviews/latest.md` и `reviews/history/`
  - Описание формата `meta.yml` и правил `topic_slug`
- НЕ входит:
  - Код чтения и записи файлов темы
  - Генерация conspect и prompt templates
  - UI для навигации по файловой структуре

## Требования

1. Должна быть создана корневая директория `learning/`.
2. В `learning/` должен быть создан файл `process.md`, который задаёт файловый контракт и workflow работы внутри этой директории.
3. В `learning/process.md` должно быть явно указано, что `Dialog`, `Message` и workflow-поля диалога хранятся в БД, а prompt templates и артефакты темы хранятся в `learning/`.
4. В `learning/process.md` должны быть зафиксированы корневые директории `learning/prompts/` и `learning/topics/`.
5. В `learning/process.md` должно быть указано, что каталог `learning/topics/<topic_slug>/` создаётся только после первой успешной генерации conspect.
6. В `learning/process.md` должен быть перечислен обязательный набор артефактов первой версии conspect-темы: `meta.yml`, `brief.md`, `conspect_prompt.md`, `conspects/current.md`.
7. В `learning/process.md` должны быть перечислены обязательные служебные директории conspect-темы: `conspects/versions/`, `reviews/` и `reviews/history/`.
8. В `learning/process.md` должен быть зафиксирован формат `meta.yml` с обязательными ключами `topic_slug`, `source_dialog_id`, `created_at`, `updated_at`, `current_state`.
9. В `learning/process.md` должны быть зафиксированы правила `topic_slug`: только строчные латинские буквы, цифры и дефисы; slug уникален в пределах `learning/topics/`.
10. В `learning/process.md` должны быть приведены как минимум один пример корректной структуры conspect-темы и один пример некорректного состояния.

## Инварианты

- `Dialog` и `Message` остаются источником истины для диалогов и сообщений
- Каталог conspect-темы не существует до первой успешной генерации conspect
- У каждой conspect-темы есть ровно один каталог `learning/topics/<topic_slug>/`
- У каждого каталога conspect-темы всегда есть `meta.yml`

## Acceptance Criteria

- [ ] Создана директория `learning/`
- [ ] Создан файл `learning/process.md`
- [ ] В `learning/process.md` описано разделение данных между БД и файловой структурой
- [ ] В `learning/process.md` зафиксированы `learning/prompts/` и `learning/topics/`
- [ ] В `learning/process.md` зафиксирован момент создания каталога conspect-темы
- [ ] В `learning/process.md` перечислены обязательные файлы первой версии conspect-темы
- [ ] В `learning/process.md` перечислены обязательные служебные директории conspect-темы, включая `reviews/history/`
- [ ] В `learning/process.md` описан формат `meta.yml`
- [ ] В `learning/process.md` описаны правила `topic_slug`
- [ ] В `learning/process.md` есть пример корректной структуры conspect-темы
- [ ] В `learning/process.md` есть пример некорректного состояния
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Это docs-only фича: runtime-код не добавляется
- Не добавлять новые гемы
- Не менять текущую логику `Dialog`, `Message`, `ChatChannel`
