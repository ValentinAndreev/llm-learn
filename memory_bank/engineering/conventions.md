# Engineering Conventions

## Coding Style

**Архитектура**
- Стандартный Rails MVC. Service objects не используются до явного запроса.
- Бизнес-логика в моделях или в Channel, не в контроллерах.
- Новые гемы — только по явному запросу пользователя.
- Существующие миграции не трогать.

**Типизация (RBS + Steep)**
- Для каждого нового класса и публичного метода добавлять RBS-сигнатуру в `sig/`.
- Имя файла: `sig/<class_name_snake_case>.rbs` (пример: `sig/dialogs_controller.rbs`).
- Ориентир — существующие файлы в `sig/` (особенно `sig/chat_channel.rbs`).
- Проверка: `bundle exec steep check` без новых ошибок.

**Аутентификация**
- Не реализовывать. Диалоги без разграничения по пользователям.

## Testing Policy

**Инструменты:** RSpec + FactoryBot. Системные тесты — RSpec + Capybara.

**Что покрывать обязательно:**
- Модели: валидации, ассоциации, scopes, invariants
- Контроллеры: happy path + основные error paths (request specs)
- Channels: создание сущностей, передача истории в LLM, бродкаст ошибок
- JS/Stimulus: только критические сценарии в системных тестах (переключение диалогов, reset UI)

**Что НЕ нужно:**
- Тесты для очевидных Rails defaults (presence validation без логики)
- Дублирование тестов модели в request spec

**Инварианты, которые всегда должны быть покрыты тестами:**
- `Message` всегда принадлежит `Dialog` (dialog_id NOT NULL)
- `Dialog#workflow_state` — только допустимые значения
- `topic_slug` — только валидный формат или NULL
- Каскадное удаление `Message` при удалении `Dialog`

**Factories:** использовать FactoryBot. Фабрики в `spec/factories/`. Не дублировать данные — использовать `build` где возможно.

**Запуск:**
```bash
bundle exec rspec                    # все тесты
bundle exec rspec spec/models        # только модели
bundle exec rspec spec/channels      # только channels
bundle exec rspec spec/system        # только системные
```

## Autonomy Boundaries

**Агент делает самостоятельно:**
- Пишет и запускает тесты
- Создаёт новые модели, контроллеры, миграции (кроме изменения существующих)
- Добавляет RBS-сигнатуры
- Читает и анализирует существующий код
- Следует паттернам из существующего кода

**Агент спрашивает перед тем как:**
- Добавить новый gem
- Изменить существующую миграцию
- Изменить архитектурный паттерн (например, добавить service object)
- Реализовать аутентификацию
- Изменить существующие тесты (не добавить, а изменить логику)

## Git Workflow

**Формат коммита:** `<type>: <description>` в настоящем времени, строчными.

Типы: `feature`, `fix`, `refactor`, `test`, `docs`, `chore`

Примеры:
```
feature: add dialog learning workflow fields
fix: rescue ActiveRecord error in chat channel
test: cover dialog workflow state validations
docs: update memory bank index
```

**Правило:** каждый коммит атомарен — один логический шаг. Не смешивать миграцию и бизнес-логику в одном коммите.

**impl-задачи:** вся реализация фичи (включая обновление `memory_bank/process/current-focus.md`) оформляется одним squash-коммитом. Промежуточные коммиты в процессе работы допустимы, но перед финальным merge необходимо схлопнуть их в один через `git reset --soft <base>` и сделать один коммит с полным описанием.
