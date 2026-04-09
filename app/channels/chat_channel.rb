class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{uuid}"
  end

  def unsubscribed
    stop_all_streams
  end

  def receive(data)
    message = data["message"].to_s.strip
    return if message.empty?

    dialog_id = data["dialog_id"]
    new_dialog_id = nil

    dialog = ActiveRecord::Base.transaction do
      if dialog_id.nil?
        new_dialog = Dialog.create!(title: message.truncate(50, omission: ""))
        dialog_id = new_dialog.id
        new_dialog_id = new_dialog.id
        new_dialog.messages.create!(role: "user", content: message)
        new_dialog
      else
        existing_dialog = Dialog.find(dialog_id)
        existing_dialog.messages.create!(role: "user", content: message)
        existing_dialog
      end
    end

    ActionCable.server.broadcast("chat_#{uuid}", { type: "dialog_created", dialog_id: new_dialog_id }) if new_dialog_id

    history = dialog.messages.order(:created_at).to_a

    chat = RubyLLM.chat(model: "gemini-3-flash-preview")
    history.each { |m| chat.add_message(role: m.role.to_sym, content: m.content) }
    response = chat.complete

    dialog.messages.create!(role: "assistant", content: response.content)
    ActionCable.server.broadcast("chat_#{uuid}", { type: "response", content: response.content, dialog_id: dialog_id })
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    ActionCable.server.broadcast("chat_#{uuid}", { type: "error", message: "Failed to save message" })
  rescue => e
    ActionCable.server.broadcast("chat_#{uuid}", { type: "error", message: e.message })
  end

  def open_dialog(data)
    dialog_id = data["dialog_id"]
    dialog = Dialog.find(dialog_id)
    messages = dialog.messages.order(:created_at).map { |m| { role: m.role, content: m.content } }
    ActionCable.server.broadcast("chat_#{uuid}", { type: "history", messages: messages, dialog_id: dialog_id })
  rescue ActiveRecord::RecordNotFound
    ActionCable.server.broadcast("chat_#{uuid}", { type: "error", message: "Dialog not found" })
  end

  private

  def uuid
    connection.uuid
  end
end
