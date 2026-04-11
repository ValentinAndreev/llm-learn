# Development Environment

## Требования

- Ruby 4.0.1 — версия зафиксирована в `.ruby-version` в корне проекта
- PostgreSQL — устанавливается отдельно, не через менеджер версий
- Node.js — не требуется (нет сборки JS)

> `.mise.toml` в репозитории отсутствует. Если используется локально — не является частью репо.

## Первоначальная настройка

```bash
bundle install
bin/rails db:prepare   # создаёт БД и прогоняет все миграции
```

Или через скрипт:
```bash
bin/setup
```

## Запуск

```bash
bin/rails s        # запустить сервер (bin/dev делает то же самое)
bin/dev            # алиас для bin/rails server
```

Приложение на: `http://localhost:3000`

## База данных

PostgreSQL. Конфигурация в `config/database.yml`.

```bash
bin/rails db:migrate          # применить новые миграции
bin/rails db:rollback         # откатить последнюю миграцию
bin/rails db:reset            # drop + create + migrate + seed
bin/rails console             # интерактивная консоль с моделями
```

## Тесты

```bash
bundle exec rspec                          # все тесты
bundle exec rspec spec/models              # модели
bundle exec rspec spec/channels            # каналы
bundle exec rspec spec/requests            # контроллеры (request specs)
bundle exec rspec spec/system              # системные (Capybara)
```

## Типизация (RBS + Steep)

```bash
bundle exec steep check       # проверить типы
```

Сигнатуры: `sig/` в корне проекта. Конфигурация: `Steepfile`.
Покрываемые директории: `app/models`, `app/controllers`, `app/channels`, `app/helpers`, `app/jobs`, `app/mailers`.

## Секреты и credentials

Rails credentials (`config/credentials.yml.enc`). Редактировать:
```bash
bin/rails credentials:edit
```

Мастер-ключ: `config/master.key` (не коммитится). LLM API ключи хранятся в credentials — подробности уточнять у владельца проекта.

## Docker (production)

`Dockerfile` в корне предназначен для production (Kamal). Для локальной разработки не используется.
