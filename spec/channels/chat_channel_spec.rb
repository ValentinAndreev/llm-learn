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
      expect(streams).to include("chat_test-uuid-123")
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
      allow(chat_double).to receive(:ask).and_return(response_double)
    end

    it "broadcasts LLM response to the connection stream" do
      subscribe
      expect {
        subscription.receive({ "message" => "Привет" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "response", "content" => "Привет! Я AI.")
      )
    end

    it "sends the user message to LLM" do
      subscribe
      expect(chat_double).to receive(:ask).with("Привет")
      subscription.receive({ "message" => "Привет" })
    end

    it "ignores empty messages" do
      subscribe
      expect(RubyLLM).not_to receive(:chat)
      subscription.receive({ "message" => "   " })
    end

    it "broadcasts error when LLM raises" do
      allow(chat_double).to receive(:ask).and_raise(StandardError, "API error")
      subscribe
      expect {
        subscription.receive({ "message" => "test" })
      }.to have_broadcasted_to("chat_test-uuid-123").with(
        hash_including("type" => "error", "content" => "API error")
      )
    end
  end
end
