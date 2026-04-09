require "rails_helper"

RSpec.describe Dialog, type: :model do
  describe "validations" do
    it "is valid with a title" do
      expect(build(:dialog)).to be_valid
    end

    it "defaults workflow_state to collecting_info" do
      expect(create(:dialog).workflow_state).to eq("collecting_info")
    end

    it "is invalid without a title" do
      expect(build(:dialog, title: nil)).not_to be_valid
    end

    it "is invalid with an empty title" do
      expect(build(:dialog, title: "")).not_to be_valid
    end

    it "is invalid with a title longer than 255 characters" do
      expect(build(:dialog, title: "a" * 256)).not_to be_valid
    end

    it "is invalid with an unsupported workflow_state" do
      dialog = build(:dialog, workflow_state: "draft")

      expect(dialog).not_to be_valid
      expect(dialog.errors[:workflow_state]).to include("is not included in the list")
    end

    it "allows a nil topic_slug" do
      expect(build(:dialog, topic_slug: nil)).to be_valid
    end

    it "allows a valid topic_slug" do
      expect(build(:dialog, topic_slug: "linear-algebra-101")).to be_valid
    end

    it "rejects an invalid topic_slug" do
      dialog = build(:dialog, topic_slug: "Linear Algebra")

      expect(dialog).not_to be_valid
      expect(dialog.errors[:topic_slug]).to include("is invalid")
    end

    it "normalizes blank goal to nil" do
      dialog = create(:dialog, goal: "   ")

      expect(dialog.goal).to be_nil
    end

    it "strips surrounding whitespace from goal" do
      dialog = create(:dialog, goal: "  Изучить Ruby on Rails  ")

      expect(dialog.goal).to eq("Изучить Ruby on Rails")
    end
  end

  describe "associations" do
    it "has many messages" do
      dialog = create(:dialog)
      create(:message, dialog: dialog, role: "user")
      create(:message, dialog: dialog, role: "assistant")
      expect(dialog.messages.count).to eq(2)
    end

    it "destroys messages when destroyed" do
      dialog = create(:dialog)
      create_list(:message, 2, dialog: dialog)
      expect { dialog.destroy! }.to change(Message, :count).by(-2)
    end
  end

  describe ".by_last_message" do
    it "returns dialogs ordered by most recent message descending" do
      old_dialog = create(:dialog)
      new_dialog = create(:dialog)
      create(:message, dialog: old_dialog, content: "старое", created_at: 2.hours.ago)
      create(:message, dialog: new_dialog, content: "новое", created_at: 1.hour.ago)
      expect(Dialog.by_last_message.to_a).to eq([ new_dialog, old_dialog ])
    end

    it "includes dialogs without messages" do
      dialog = create(:dialog)
      expect(Dialog.by_last_message).to include(dialog)
    end
  end
end
