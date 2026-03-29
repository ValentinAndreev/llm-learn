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

    chat = RubyLLM.chat(model: "gemini-3-flash-preview")
    response = chat.ask(message)
    ActionCable.server.broadcast("chat_#{uuid}", { type: "response", content: response.content })
  rescue => e
    ActionCable.server.broadcast("chat_#{uuid}", { type: "error", content: e.message })
  end
end
