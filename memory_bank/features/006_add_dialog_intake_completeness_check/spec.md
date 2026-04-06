# Проверка полноты intake-диалога

**Brief:** `memory_bank/features/006_add_dialog_intake_completeness_check/brief.md`

## Цель

Дать системе явный шаг, который определяет, хватает ли содержимого диалога для перехода к сборке итогового prompt на conspect.

## Scope

- Входит (3 компонента: `Dialog`, `Message`, prompt runner):
  - Анализ `goal` и истории сообщений диалога
  - Использование template `learning/prompts/intake/check_completeness.md`
  - Обновление `workflow_state` по результату проверки
  - Явный результат проверки для вызывающего кода
- НЕ входит:
  - Сборка final prompt
  - Генерация brief
  - Запись файлов темы на диск

## Требования

1. Feature должна принимать конкретный `Dialog` как входной объект проверки.
2. Входом для проверки должны быть `Dialog#goal` и сообщения диалога в порядке `created_at ASC`.
3. Допустимое входное состояние для запуска feature: только `collecting_info`.
4. Если `workflow_state` диалога отличается от `collecting_info`, feature должна вернуть failure с кодом `invalid_state` и не вызывать LLM.
5. Если у диалога отсутствует `goal`, feature должна вернуть результат `incomplete` с причиной `missing_goal` и не вызывать LLM.
6. Если у диалога нет ни одного пользовательского сообщения, feature должна вернуть результат `incomplete` с причиной `no_user_messages` и не вызывать LLM.
7. Во всех остальных случаях feature должна запускать template `learning/prompts/intake/check_completeness.md` через prompt runner.
8. Результат проверки должен содержать статус `complete` или `incomplete`.
9. Если результат `incomplete`, он должен содержать непустой список недостающих данных.
10. Если результат `complete`, список недостающих данных должен быть пустым.
11. При результате `complete` значение `workflow_state` диалога должно обновляться на `intake_complete`.
12. При результате `incomplete` значение `workflow_state` диалога должно оставаться `collecting_info`.
13. Если prompt runner завершился ошибкой, `workflow_state` диалога не должен изменяться, а вызывающий код должен получить явный failure.

## Инварианты

- Проверка полноты не создаёт новых `Message`
- Проверка полноты не записывает файлы в `learning/topics/`
- У диалога после проверки всегда остаётся допустимый `workflow_state`
- Список недостающих данных пуст только при статусе `complete`

## Acceptance Criteria

- [ ] Для диалога вне состояния `collecting_info` feature возвращает `invalid_state` и не вызывает LLM
- [ ] Диалог без `goal` получает результат `incomplete` с причиной `missing_goal` без вызова LLM
- [ ] Диалог без пользовательских сообщений получает результат `incomplete` с причиной `no_user_messages` без вызова LLM
- [ ] Для диалога с достаточным контекстом вызывается template `learning/prompts/intake/check_completeness.md`
- [ ] Результат проверки содержит статус `complete` или `incomplete`
- [ ] При `incomplete` возвращается непустой список недостающих данных
- [ ] При `complete` список недостающих данных пуст
- [ ] При `complete` `workflow_state` обновляется на `intake_complete`
- [ ] При `incomplete` `workflow_state` остаётся `collecting_info`
- [ ] При ошибке prompt runner `workflow_state` не меняется
- [ ] Все существующие тесты проходят
- [ ] Инварианты не нарушены

## Ограничения

- Использовать prompt runner из задачи 005
- Не добавлять новые поля в `messages`
- Не добавлять UI и файловые артефакты
