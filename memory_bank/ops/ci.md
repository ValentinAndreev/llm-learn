# CI / GitHub Actions

Все workflows запускаются на `push` в `main` и на `pull_request`.

## Workflows

| Workflow | Файл | Что делает |
|---|---|---|
| **Test** | `test.yml` | RSpec (unit + request specs). Поднимает PostgreSQL как service. |
| **System Test** | `system_test.yml` | RSpec system specs (Capybara). Поднимает PostgreSQL как service. |
| **Lint** | `lint.yml` | RuboCop. Использует кэш в `tmp/rubocop`. |
| **Scan Ruby** | `scan_ruby.yml` | `bin/brakeman` (static analysis) + `bin/bundler-audit` (known CVEs in gems). |
| **Scan JS** | `scan_js.yml` | `bin/importmap audit` (JS deps via importmap). |

## Требования для прохождения CI

Перед коммитом убедиться что проходит локально:
```bash
bundle exec rspec                 # Test + System Test
bundle exec rubocop               # Lint
bundle exec brakeman --no-pager   # Scan Ruby (static)
bin/bundler-audit                 # Scan Ruby (CVEs in gems)
bin/importmap audit               # Scan JS
```

## Инфраструктура CI

- Runner: `ubuntu-latest`
- Ruby setup: `ruby/setup-ruby@v1` с `bundler-cache: true`
- PostgreSQL: `POSTGRES_USER=postgres`, `POSTGRES_PASSWORD=postgres`, порт 5432
