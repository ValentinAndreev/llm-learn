require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  describe "#subscribed" do
    it "subscribes successfully" do
      stub_connection uuid: "test-uuid-123"
      subscribe
      expect(subscription).to be_confirmed
    end

    it "streams from the connection-specific channel" do
      stub_connection uuid: "test-uuid-123"
      subscribe
      expect(subscription.streams).to include("chat_test-uuid-123")
    end
  end

  describe "#unsubscribed" do
    it "stops all streams" do
      stub_connection uuid: "test-uuid-123"
      subscribe
      expect { unsubscribe }.not_to raise_error
    end
  end

  describe "#receive" do
    let(:response_double) { double("response", content: "Привет! Я AI.") }
    let(:chat_double) { double("chat") }

    before do
      stub_connection uuid: "test-uuid-123"
      allow(RubyLLM).to receive(:chat).with(model: "gemini-3-flash-preview").and_return(chat_double)
      allow(chat_double).to receive(:add_message)
      allow(chat_double).to receive(:complete).and_return(response_double)
    end

    it "broadcasts LLM response to the connection stream" do
      subscribe
      expect {
        subscription.receive({ "message" => "Привет" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "response", "content" => "Привет! Я AI.", "dialog_id" => Integer)
      )
    end

    it "sends the user message to LLM" do
      subscribe
      expect(chat_double).to receive(:complete)
      subscription.receive({ "message" => "Привет" })
    end

    it "ignores empty messages" do
      subscribe
      expect(RubyLLM).not_to receive(:chat)
      subscription.receive({ "message" => "   " })
    end

    it "broadcasts error when LLM raises" do
      allow(chat_double).to receive(:complete).and_raise(StandardError, "API error")
      subscribe
      expect {
        subscription.receive({ "message" => "test" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "error")
      )
    end

    it "creates a new Dialog on first message (no dialog_id)" do
      subscribe
      expect {
        subscription.receive({ "message" => "Первое сообщение" })
      }.to change(Dialog, :count).by(1)
    end

    it "sets dialog title from first 50 chars of message" do
      subscribe
      long_message = "А" * 60
      subscription.receive({ "message" => long_message })
      expect(Dialog.last.title).to eq("А" * 50)
    end

    it "saves user message to DB" do
      subscribe
      expect {
        subscription.receive({ "message" => "Привет" })
      }.to change(Message, :count).by(2) # user + assistant
    end

    it "broadcasts dialog_created with dialog_id on new dialog" do
      subscribe
      expect {
        subscription.receive({ "message" => "Привет" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "dialog_created")
      )
    end

    it "does not create new Dialog when dialog_id is provided" do
      dialog = create(:dialog)
      create(:message, dialog: dialog, role: "user", content: "Ранее")
      subscribe
      expect {
        subscription.receive({ "message" => "Продолжение", "dialog_id" => dialog.id })
      }.not_to change(Dialog, :count)
    end

    it "passes history to LLM when dialog_id is provided" do
      dialog = create(:dialog)
      create(:message, dialog: dialog, role: "user", content: "Вопрос")
      create(:message, dialog: dialog, role: "assistant", content: "Ответ")
      subscribe
      expect(chat_double).to receive(:add_message).at_least(:once)
      subscription.receive({ "message" => "Продолжение", "dialog_id" => dialog.id })
    end

    it "broadcasts DB error as error message on save failure" do
      allow(Dialog).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Dialog.new))
      subscribe
      expect {
        subscription.receive({ "message" => "Привет" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "error", "message" => "Не удалось сохранить сообщение")
      )
    end
  end

  describe "#open_dialog" do
    before { stub_connection uuid: "test-uuid-123" }

    it "broadcasts history messages for the given dialog" do
      dialog = create(:dialog)
      create(:message, dialog: dialog, role: "user", content: "Привет")
      create(:message, dialog: dialog, role: "assistant", content: "Здравствуй")
      subscribe

      expect {
        subscription.open_dialog({ "dialog_id" => dialog.id })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "history", "dialog_id" => dialog.id)
      )
    end

    it "broadcasts error when dialog not found" do
      subscribe
      expect {
        subscription.open_dialog({ "dialog_id" => 999999 })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "error")
      )
    end
  end
end
