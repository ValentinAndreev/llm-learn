# Runner для markdown prompt templates

**Brief:** `memory_bank/features/005_add_markdown_prompt_runner/brief.md`

## Цель

Сделать единый механизм запуска LLM-сценариев по markdown templates, чтобы новый сценарий не требовал копирования кода вызова модели.

## Scope

- Входит (3 компонента: loader template, renderer переменных, runner вызова LLM):
  - Загрузка template из `learning/prompts/`
  - Подстановка переменных в template
  - Синхронный вызов LLM через текущую интеграцию с RubyLLM
  - Явный контракт success/failure для вызывающего кода
- НЕ входит:
  - Асинхронные jobs
  - Usage/cost logging
  - Multi-provider routing

## Требования

1. Feature должна предоставлять синхронный API для запуска markdown template с набором входных переменных.
2. Template может быть загружен только из каталога `learning/prompts/`.
3. Если template не найден, feature должна вернуть failure с кодом `template_not_found` и не вызывать LLM.
4. Если template не содержит валидный YAML front matter или имеет пустое тело, feature должна вернуть failure с кодом `invalid_template` и не вызывать LLM.
5. Перед вызовом LLM feature должна проверить, что все обязательные переменные из `required_variables` переданы вызывающим кодом.
6. Если обязательные переменные не переданы, feature должна вернуть failure с кодом `missing_variables` и не вызывать LLM.
7. При успешной загрузке и подстановке переменных feature должна сформировать итоговый prompt и вызвать текущую интеграцию с RubyLLM.
8. При успешном вызове вызывающий код должен получить доступ к итоговому prompt и тексту ответа модели.
9. Если модель вернула пустой текстовый ответ, feature должна вернуть failure с кодом `empty_response`.
10. Если RubyLLM выбросил исключение, feature должна вернуть failure с кодом `llm_error`.

## Инварианты

- Feature не изменяет template-файлы на диске
- LLM не вызывается при невалидном template или неполном наборе переменных
- Любой failure возвращается вызывающему коду явно, а не маскируется как success
- Сценарий выполняется синхронно

## Acceptance Criteria

- [ ] Можно запустить template из `learning/prompts/` с набором переменных
- [ ] При отсутствии template возвращается `template_not_found`, и LLM не вызывается
- [ ] При невалидном template возвращается `invalid_template`, и LLM не вызывается
- [ ] При отсутствии обязательных переменных возвращается `missing_variables`, и LLM не вызывается
- [ ] При успешном вызове вызывающий код получает итоговый prompt и текст ответа модели
- [ ] При пустом ответе модели возвращается `empty_response`
- [ ] При исключении RubyLLM возвращается `llm_error`
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Использовать текущую интеграцию с RubyLLM
- Не добавлять background jobs
- Не добавлять новые гемы
- Если добавляется новый публичный API, обновить RBS
