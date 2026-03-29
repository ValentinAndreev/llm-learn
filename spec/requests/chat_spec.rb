require "rails_helper"

RSpec.describe "Chat", type: :request do
  describe "GET /" do
    it "returns HTTP 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "renders the chat container" do
      get root_path
      expect(response.body).to include('data-controller="chat"')
    end

    it "renders the messages target" do
      get root_path
      expect(response.body).to include('data-chat-target="messages"')
    end

    it "renders the input target" do
      get root_path
      expect(response.body).to include('data-chat-target="input"')
    end
  end
end
