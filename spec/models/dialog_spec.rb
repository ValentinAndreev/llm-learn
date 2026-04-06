require "rails_helper"

RSpec.describe Dialog, type: :model do
  describe "validations" do
    it "is valid with a title" do
      expect(build(:dialog)).to be_valid
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
