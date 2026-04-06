require "rails_helper"

RSpec.describe "Dialogs", type: :request do
  describe "GET /dialogs" do
    it "returns HTTP 200" do
      get dialogs_path
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON array of dialogs" do
      create(:dialog, title: "Тест")
      get dialogs_path
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "returns dialogs with id, title, updated_at fields" do
      dialog = create(:dialog, title: "Тест")
      get dialogs_path
      data = JSON.parse(response.body).first
      expect(data.keys).to include("id", "title", "updated_at")
      expect(data["title"]).to eq("Тест")
    end

    it "returns empty array when no dialogs" do
      get dialogs_path
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "DELETE /dialogs/:id" do
    it "deletes the dialog and returns 204" do
      dialog = create(:dialog)
      expect { delete dialog_path(dialog) }.to change(Dialog, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "cascades and deletes associated messages" do
      dialog = create(:dialog)
      create_list(:message, 2, dialog: dialog)
      delete dialog_path(dialog)
      expect(Message.count).to eq(0)
    end

    it "returns 404 for non-existent dialog" do
      delete dialog_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /dialogs/:id" do
    it "updates the title and returns the dialog" do
      dialog = create(:dialog, title: "Старое")
      patch dialog_path(dialog), params: { dialog: { title: "Новое" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("Новое")
    end

    it "returns 422 for empty title" do
      dialog = create(:dialog, title: "Тест")
      patch dialog_path(dialog), params: { dialog: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for blank title" do
      dialog = create(:dialog, title: "Тест")
      patch dialog_path(dialog), params: { dialog: { title: "   " } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for non-existent dialog" do
      patch dialog_path(id: 999999), params: { dialog: { title: "Тест" } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
