# Сохранение диалогов — план реализации

## Обзор подхода

Добавляем два слоя: модели (`Dialog`, `Message`) с миграциями, затем HTTP-контроллер для операций с диалогами (список, удаление, переименование). `ChatChannel` расширяется: сохраняет сообщения в БД, передаёт историю в LLM и бродкастит историю при открытии диалога. Stimulus-контроллер на фронте получает новые события и управляет dropdown и inline-редактированием.

## Шаги

### 1. Миграция: таблица `dialogs`
**Файлы:** `db/migrate/TIMESTAMP_create_dialogs.rb` (новый)
**Что делаем:** Создать таблицу с полями `title: string NOT NULL`, `timestamps`.
**Проверка:** `bin/rails db:migrate` завершается без ошибок, таблица видна в схеме.

### 2. Миграция: таблица `messages`
**Файлы:** `db/migrate/TIMESTAMP_create_messages.rb` (новый)
**Что делаем:** Создать таблицу с полями `dialog_id: references NOT NULL`, `role: string NOT NULL`, `content: text NOT NULL`, `timestamps`.
**Проверка:** `bin/rails db:migrate` завершается без ошибок.

### 3. Модель `Dialog`
**Файлы:** `app/models/dialog.rb` (новый)
**Что делаем:** `has_many :messages, dependent: :destroy`. Валидация: `title` — присутствие, длина не более 255. Scope `by_last_message` — сортировка по дате последнего сообщения убыванием.
**Проверка:** `Dialog.create!(title: "test")` в консоли создаёт запись.

### 4. Модель `Message`
**Файлы:** `app/models/message.rb` (новый)
**Что делаем:** `belongs_to :dialog`. Валидация: `role` — inclusion в `%w[user assistant]`, `content` — присутствие.
**Проверка:** `Message.create!(dialog:, role: "user", content: "hi")` создаёт запись.

### 5. RBS-сигнатуры для моделей и контроллеров
**Файлы:** `sig/dialog.rbs` (новый), `sig/message.rbs` (новый), `sig/dialogs_controller.rbs` (новый), `sig/chat_controller.rbs` (изменить)
**Что делаем:** По одному файлу на новый класс, по аналогии с `sig/chat_channel.rbs` и `sig/chat_controller.rbs`. Для `Dialog` — атрибуты, ассоциации, валидации, scope; для `Message` — атрибуты, ассоциации, валидации; для `DialogsController` — сигнатуры actions `index`, `destroy`, `update`; в `sig/chat_controller.rbs` добавить `@dialogs`.
**Проверка:** Убедиться, что `Steepfile` включает `sig/` директорию или явно перечисляет новые файлы в target. Затем `bundle exec steep check` не выдаёт ошибок по новым файлам.

### 6. Маршруты и контроллер `DialogsController`
**Файлы:** `config/routes.rb` (изменить), `app/controllers/dialogs_controller.rb` (новый)
**Что делаем:** Добавить `resources :dialogs, only: [:index, :destroy, :update]`. Контроллер: `index` — JSON-список диалогов `Dialog.by_last_message`, формат каждого элемента: `{ id: Integer, title: String, updated_at: String (ISO 8601) }`; `destroy` — удаление с `dependent: :destroy`; `update` — переименование, отклоняет пустой `title`.
**Проверка:** `GET /dialogs` возвращает JSON; `DELETE /dialogs/:id` удаляет запись; `PATCH /dialogs/:id` обновляет название.

### 7. Расширение `ChatChannel`: сохранение сообщений
**Файлы:** `app/channels/chat_channel.rb` (изменить)
**Что делаем:** В `receive` — если `dialog_id` не передан в `data`, создать новый `Dialog` с title = первые 50 символов сообщения. Сохранить `Message(role: "user")` до вызова LLM. После получения ответа сохранить `Message(role: "assistant")`. При ошибке БД — перехватить исключение и передать пользователю уведомление об ошибке стандартными средствами Rails. После создания нового диалога бродкастить `{ type: "dialog_created", dialog_id: Integer }`, чтобы фронт знал id.
**Проверка:** После отправки сообщения в консоли появляются записи `Dialog` и два `Message`; фронт получает `type: "dialog_created"` с корректным id.

### 8. Расширение `ChatChannel`: передача истории в LLM
**Файлы:** `app/channels/chat_channel.rb` (изменить)
**Что делаем:** Если `dialog_id` передан — загрузить `dialog.messages.order(:created_at)`. Передать историю в LLM через `RubyLLM.chat` — добавить предыдущие сообщения в контекст перед вызовом `ask`.
**Проверка:** В `spec/channels/chat_channel_spec.rb` — тест с переданным `dialog_id`: канал загружает предыдущие сообщения и передаёт их LLM-клиенту перед новым вопросом (проверить через мок `RubyLLM.chat`).

### 9. RBS-сигнатуры для `ChatChannel`
**Файлы:** `sig/chat_channel.rbs` (изменить)
**Что делаем:** Обновить сигнатуру `receive` с учётом новой логики.
**Проверка:** `bundle exec steep check` без новых ошибок.

### 10. `ChatController`: загрузка диалогов
**Файлы:** `app/controllers/chat_controller.rb` (изменить)
**Что делаем:** В `index` добавить `@dialogs = Dialog.by_last_message`.
**Проверка:** Переменная доступна в шаблоне — проверить через `binding.irb` или тест.

### 11. Бродкаст истории при открытии диалога
**Файлы:** `app/channels/chat_channel.rb` (изменить)
**Что делаем:** Добавить action `open_dialog(data)` в канале — принимает `dialog_id`, бродкастит все сообщения диалога с `type: "history"` и массивом `messages`. Управление loading-состоянием (блокировка/разблокировка input) — полностью на стороне клиента: Stimulus блокирует input сразу при вызове `open_dialog` и разблокирует при получении `type: "history"`. Сервер бродкастит только `type: "history"`.
**Проверка:** При вызове `open_dialog` на фронте канал отвечает `type: "history"` с сообщениями.

### 12. Вью: dropdown диалогов
**Файлы:** `app/views/chat/index.html.erb` (изменить)
**Что делаем:** Добавить блок над чатом с dropdown (список диалогов из `@dialogs`), кнопкой «Новый диалог» и кнопкой удаления рядом с каждым пунктом. При отсутствии диалогов — текст «Нет сохранённых диалогов». Название текущего диалога отображается как отдельный элемент с нужными `data`-атрибутами для Stimulus (inline-редактирование реализуется в шаге 15).
**Проверка:** Страница отображает список диалогов и пустое состояние («Нет сохранённых диалогов»).

### 13. Stimulus: переключение диалогов и новый диалог
**Файлы:** `app/javascript/controllers/chat_controller.js` (изменить)
**Что делаем:**
- Хранить `currentDialogId` в state контроллера.
- При выборе диалога из dropdown — сразу заблокировать input, затем отправить `open_dialog` через канал, выставить `currentDialogId`, передавать его в каждом сообщении.
- При получении `type: "history"` — отрисовать сообщения в UI, разблокировать input.
- При получении `type: "dialog_created"` — сохранить `dialog_id`, обновить dropdown через `fetch GET /dialogs` (с заголовком `X-CSRF-Token` из `meta[name=csrf-token]`).
- «Новый диалог» — сбрасывает `currentDialogId` в `null`, очищает чат-ленту, убирает заголовок, разблокирует input.
**Проверка:** Переключение между диалогами отображает историю; новый диалог очищает чат.

### 14. Stimulus: удаление диалога
**Файлы:** `app/javascript/controllers/chat_controller.js` (изменить)
**Что делаем:** Удаление — `DELETE /dialogs/:id` с заголовком `X-CSRF-Token` из `meta[name=csrf-token]`; при успехе убирает запись из dropdown; если удалён текущий — сбрасывает `currentDialogId` в `null`, очищает чат-ленту, убирает заголовок, разблокирует input.
**Проверка:** Диалог удаляется из dropdown; при удалении текущего UI сбрасывается.

### 15. Stimulus: inline-редактирование названия
**Файлы:** `app/javascript/controllers/chat_controller.js` (изменить)
**Что делаем:** Двойной клик на названии → заменить текст на `<input>`; Enter/blur → `PATCH /dialogs/:id` с заголовком `X-CSRF-Token` из `meta[name=csrf-token]`, обновить текст в dropdown; Escape → откат к исходному значению; пустое значение → откат без запроса.
**Проверка:** Все сценарии (сохранение, отмена, пустое значение) работают в браузере.

### 16. Тесты: модели
**Файлы:** `spec/models/dialog_spec.rb` (новый), `spec/models/message_spec.rb` (новый), `spec/factories/dialogs.rb` (новый), `spec/factories/messages.rb` (новый)
**Что делаем:** Покрыть валидации, ассоциации, cascade destroy, scope `by_last_message`.
**Проверка:** `bundle exec rspec spec/models` — всё зелёное.

### 17. Тесты: `DialogsController` и `ChatController`
**Файлы:** `spec/requests/dialogs_spec.rb` (новый), `spec/requests/chat_spec.rb` (новый или изменить)
**Что делаем:** Покрыть `index`, `destroy`, `update` для `DialogsController` — включая граничные случаи (пустой title, несуществующий id). Для `ChatController`: проверить, что `GET /` рендерит шаблон и передаёт `@dialogs`.
**Проверка:** `bundle exec rspec spec/requests/` — всё зелёное.

### 18. Тесты: `ChatChannel`
**Файлы:** `spec/channels/chat_channel_spec.rb` (изменить)
**Что делаем:** Дополнить тесты из шага 8 (не перезаписывать): добавить проверки создания `Dialog` и `Message` при первом сообщении, сохранение ответа LLM, передачу `dialog_id` в ответе, загрузку истории через `open_dialog`, бродкаст ошибки при сбое БД.
**Проверка:** `bundle exec rspec spec/channels` — всё зелёное, старые тесты не сломаны.

### 19. Тесты: Stimulus-контроллер (системные)
**Файлы:** `spec/system/dialogs_spec.rb` (новый)
**Что делаем:** Системные тесты (RSpec + Capybara) для критических JS-сценариев: переключение между диалогами (история отображается), сброс UI после удаления текущего диалога, inline-редактирование (сохранение, Escape, пустое значение).
**Проверка:** `bundle exec rspec spec/system` — всё зелёное.

## Зависимости между шагами

- Шаги 3–4 требуют шагов 1–2 (миграции должны быть выполнены)
- Шаг 7 требует шагов 3–4 (модели должны существовать)
- Шаг 8 требует шага 7
- Шаг 11 требует шагов 7–8 (канал должен уметь сохранять сообщения)
- Шаг 12 требует шага 10 (вью использует `@dialogs`)
- Шаг 13 требует шагов 6 и 11 (нужны маршруты и бродкаст истории)
- Шаги 13–15 требуют шага 12 (Stimulus работает с data-атрибутами и HTML-структурой из вью)
- Шаги 14–15 требуют шага 13
- Шаг 16 требует шагов 3–4 (модели должны существовать)
- Шаг 17 требует шагов 6 и 10 (контроллер и маршруты должны существовать)
- Шаг 18 требует шагов 7–11 (канал с полной логикой сохранения и бродкаста)
- Шаг 19 требует шагов 12–18 (системные тесты покрывают весь вертикальный срез)
- Шаги 16–18 можно писать параллельно друг с другом после завершения своих зависимостей
