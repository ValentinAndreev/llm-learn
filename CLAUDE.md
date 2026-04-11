Read **memory_bank/index.md** first — it contains the project map and reading hierarchy.

At the start of every session show this and nothing else until the user responds:

```
resume               продолжить работу
orient               понять где проект

brief: <идея>        написать brief
review brief: <id>   проверить brief

spec: <id>           написать spec
review spec: <id>    проверить spec

plan: <id>           написать plan
review plan: <id>    проверить plan

impl: <id>           реализовать
review: <id>         code review
```

## Stack
Ruby on Rails 8.1, Ruby 4.0.1, PostgreSQL, RSpec, RubyLLM

## Quick commands
- `bin/setup` — bootstrap
- `bin/rails s` — run server
- `bundle exec rspec` — run tests
- `bin/rails db:migrate` — migrate

## Hard constraints
- Don't touch existing migrations
- Don't implement auth
- No new gems without explicit request
