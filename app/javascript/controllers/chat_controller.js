import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["messages", "input", "dialogsList", "dialogItem", "noDialogs", "dialogHeader", "currentTitle"]

  connect() {
    this.currentDialogId = null
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

    // Block input in new dialogs until dialog_created arrives to prevent
    // a second submit (before dialog_id is known) from creating a second dialog
    if (this.currentDialogId === null) {
      this.inputTarget.disabled = true
    } else {
      this.inputTarget.focus()
    }

    this.channel.send({ message, dialog_id: this.currentDialogId })
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submit(event)
    }
  }

  newDialog() {
    this.currentDialogId = null
    this.messagesTarget.innerHTML = ""
    this.dialogHeaderTarget.style.display = "none"
    this.currentTitleTarget.textContent = ""
    this.inputTarget.disabled = false
    this.inputTarget.focus()
  }

  deleteDialog(event) {
    event.stopPropagation()
    const dialogId = event.currentTarget.dataset.dialogId
    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content

    fetch(`/dialogs/${dialogId}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": csrfToken }
    })
      .then(response => {
        if (!response.ok) throw new Error("Failed to delete dialog")
        this.#removeDialogFromList(parseInt(dialogId))
        if (this.currentDialogId === parseInt(dialogId)) {
          this.newDialog()
        }
      })
      .catch(() => this.#showFlash("Failed to delete dialog"))
  }

  openDialogFromEl(event) {
    if (event.target.closest(".chat-dialog-delete-btn") || event.target.closest(".chat-dialog-rename-input")) return
    const item = event.currentTarget
    const dialogId = parseInt(item.dataset.dialogId)
    const title = item.querySelector(".chat-dialog-title").textContent.trim()
    this.#openDialog(dialogId, title)
  }

  startRename(event) {
    const titleEl = event.currentTarget
    const dialogItem = titleEl.closest("[data-dialog-id]")
    const dialogId = parseInt(dialogItem.dataset.dialogId)
    const currentTitle = titleEl.textContent.trim()

    const input = document.createElement("input")
    input.type = "text"
    input.className = "chat-dialog-rename-input"
    input.value = currentTitle

    titleEl.replaceWith(input)
    input.focus()
    input.select()

    let saving = false
    const save = () => {
      if (saving) return
      saving = true
      const newTitle = input.value.trim()
      if (!newTitle) {
        saving = false
        input.replaceWith(titleEl)
        return
      }
      if (newTitle === currentTitle) {
        saving = false
        input.replaceWith(titleEl)
        return
      }
      this.#saveRename(dialogId, newTitle, input, titleEl)
    }

    input.addEventListener("blur", save)
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") { e.preventDefault(); save() }
      if (e.key === "Escape") { saving = true; input.replaceWith(titleEl) }
    })
  }

  #saveRename(dialogId, newTitle, inputEl, originalTitleEl) {
    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content

    fetch(`/dialogs/${dialogId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
      body: JSON.stringify({ dialog: { title: newTitle } })
    })
      .then(response => {
        if (!response.ok) return response.json().then(data => { throw new Error(data.error || "Failed to rename dialog") })
        return response.json()
      })
      .then(data => {
        originalTitleEl.textContent = data.title
        inputEl.replaceWith(originalTitleEl)
        if (this.currentDialogId === dialogId) {
          this.currentTitleTarget.textContent = data.title
        }
      })
      .catch(err => {
        inputEl.replaceWith(originalTitleEl)
        this.#showFlash(err.message || "Failed to rename dialog")
      })
  }

  #received(data) {
    if (data.type === "response") {
      // Ignore responses from other dialogs (user switched while LLM was thinking)
      if (data.dialog_id !== this.currentDialogId) return
      this.#appendMessage("assistant", data.content)
    } else if (data.type === "error") {
      this.#showFlash(data.message || data.content || "Error")
    } else if (data.type === "dialog_created") {
      this.currentDialogId = data.dialog_id
      this.inputTarget.disabled = false
      this.inputTarget.focus()
      this.#refreshDialogsList()
    } else if (data.type === "history") {
      // Ignore history for dialogs that are no longer active
      if (data.dialog_id !== this.currentDialogId) return
      this.messagesTarget.innerHTML = ""
      data.messages.forEach(m => this.#appendMessage(m.role, m.content))
      this.inputTarget.disabled = false
    }
  }

  #refreshDialogsList() {
    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content

    fetch("/dialogs", { headers: { "X-CSRF-Token": csrfToken } })
      .then(response => {
        if (!response.ok) throw new Error("Failed to load dialogs")
        return response.json()
      })
      .then(dialogs => this.#renderDialogsList(dialogs))
      .catch(() => this.#showFlash("Failed to load dialogs"))
  }

  #renderDialogsList(dialogs) {
    const list = this.dialogsListTarget

    if (dialogs.length === 0) {
      list.innerHTML = '<div class="chat-no-dialogs" data-chat-target="noDialogs">No saved dialogs</div>'
      return
    }

    list.innerHTML = dialogs.map(d => `
      <div class="chat-dialog-item" data-dialog-id="${d.id}" data-chat-target="dialogItem">
        <span class="chat-dialog-title" data-action="dblclick->chat#startRename">${this.#escapeHtml(d.title)}</span>
        <button class="chat-dialog-delete-btn" data-action="click->chat#deleteDialog" data-dialog-id="${d.id}">✕</button>
      </div>
    `).join("")

    list.querySelectorAll("[data-dialog-id]").forEach(item => {
      item.addEventListener("click", (e) => {
        if (e.target.closest(".chat-dialog-delete-btn") || e.target.closest(".chat-dialog-rename-input")) return
        this.#openDialog(parseInt(item.dataset.dialogId), item.querySelector(".chat-dialog-title").textContent.trim())
      })
    })
  }

  #openDialog(dialogId, title) {
    this.inputTarget.disabled = true
    this.currentDialogId = dialogId
    this.dialogHeaderTarget.style.display = ""
    this.currentTitleTarget.textContent = title
    this.channel.perform("open_dialog", { dialog_id: dialogId })
  }

  #removeDialogFromList(dialogId) {
    const item = this.dialogsListTarget.querySelector(`[data-dialog-id="${dialogId}"]`)
    if (item) item.remove()
    if (!this.dialogsListTarget.querySelector("[data-dialog-id]")) {
      this.dialogsListTarget.innerHTML = '<div class="chat-no-dialogs">No saved dialogs</div>'
    }
  }

  #appendMessage(role, content) {
    const div = document.createElement("div")
    div.className = `message message--${role}`

    const label = document.createElement("span")
    label.className = "message__label"
    label.textContent = role === "user" ? "You" : "AI"

    const text = document.createElement("p")
    text.className = "message__text"
    text.textContent = content

    div.appendChild(label)
    div.appendChild(text)
    this.messagesTarget.appendChild(div)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  #showFlash(message) {
    const flash = document.createElement("div")
    flash.className = "flash flash--error"
    flash.textContent = message
    document.body.appendChild(flash)
    setTimeout(() => flash.remove(), 4000)
  }

  #escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
