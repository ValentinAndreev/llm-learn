require "rails_helper"

RSpec.describe "Dialogs", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "selecting a dialog" do
    it "shows history and re-enables input after opening a dialog" do
      dialog = create(:dialog, title: "Test dialog")
      create(:message, dialog: dialog, role: "user", content: "Hello there")
      create(:message, dialog: dialog, role: "assistant", content: "Hi!")
      visit root_path

      find(".chat-dialog-item[data-dialog-id='#{dialog.id}']").click

      expect(page).to have_css(".message--user", text: "Hello there", wait: 5)
      expect(page).to have_css(".message--assistant", text: "Hi!")
      expect(find("[data-chat-target='input']")).not_to be_disabled
    end
  end

  describe "deleting a dialog from the list" do
    it "removes the dialog from the list" do
      dialog = create(:dialog, title: "Удаляемый диалог")
      visit root_path

      expect(page).to have_css(".chat-dialog-item[data-dialog-id='#{dialog.id}']")
      find(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-delete-btn").click

      expect(page).not_to have_css(".chat-dialog-item[data-dialog-id='#{dialog.id}']", wait: 5)
    end

    it "shows empty state when last dialog is deleted" do
      dialog = create(:dialog, title: "Единственный")
      visit root_path

      find(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-delete-btn").click

      expect(page).to have_text("No saved dialogs", wait: 5)
    end
  end

  describe "inline rename" do
    it "saves new title on Enter" do
      dialog = create(:dialog, title: "Старое название")
      visit root_path

      find(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title").double_click
      input = find(".chat-dialog-rename-input")
      input.set("Новое название")
      input.send_keys(:return)

      expect(page).to have_css(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title", text: "Новое название", wait: 5)
      expect(dialog.reload.title).to eq("Новое название")
    end

    it "cancels rename on Escape" do
      dialog = create(:dialog, title: "Оригинал")
      visit root_path

      find(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title").double_click
      find(".chat-dialog-rename-input").send_keys(:escape)

      expect(page).to have_css(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title", text: "Оригинал")
      expect(dialog.reload.title).to eq("Оригинал")
    end

    it "does not save empty title" do
      dialog = create(:dialog, title: "Оригинал")
      visit root_path

      find(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title").double_click
      # Use send_keys to clear without triggering blur prematurely:
      # set("") calls Selenium's clear() which fires blur → JS removes input → stale element
      find(".chat-dialog-rename-input").send_keys([ :control, "a" ], :delete, :tab)

      expect(page).to have_css(".chat-dialog-item[data-dialog-id='#{dialog.id}'] .chat-dialog-title", text: "Оригинал")
      expect(dialog.reload.title).to eq("Оригинал")
    end
  end
end
