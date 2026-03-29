import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["messages", "input"]

  connect() {
    this.channel = consumer.subscriptions.create("ChatChannel", {
      received: (data) => this.#received(data)
    })
  }

  disconnect() {
    this.channel.unsubscribe()
  }

  submit(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    if (!message) return

    this.#appendMessage("user", message)
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.channel.send({ message })
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submit(event)
    }
  }

  #received(data) {
    if (data.type === "response") {
      this.#appendMessage("assistant", data.content)
    } else if (data.type === "error") {
      this.#appendMessage("error", data.content)
    }
  }

  #appendMessage(role, content) {
    const div = document.createElement("div")
    div.className = `message message--${role}`

    const label = document.createElement("span")
    label.className = "message__label"
    label.textContent = role === "user" ? "Вы" : role === "error" ? "Ошибка" : "AI"

    const text = document.createElement("p")
    text.className = "message__text"
    text.textContent = content

    div.appendChild(label)
    div.appendChild(text)
    this.messagesTarget.appendChild(div)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
