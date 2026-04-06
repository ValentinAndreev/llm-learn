require "rails_helper"

RSpec.describe Message, type: :model do
  describe "validations" do
    it "is valid with role user and content" do
      expect(build(:message, role: "user")).to be_valid
    end

    it "is valid with role assistant" do
      expect(build(:message, role: "assistant")).to be_valid
    end

    it "is invalid without content" do
      expect(build(:message, content: nil)).not_to be_valid
    end

    it "is invalid with empty content" do
      expect(build(:message, content: "")).not_to be_valid
    end

    it "is invalid with an unknown role" do
      expect(build(:message, role: "system")).not_to be_valid
    end

    it "is invalid without a dialog" do
      expect(build(:message, dialog: nil)).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a dialog" do
      dialog = create(:dialog)
      message = create(:message, dialog: dialog)
      expect(message.dialog).to eq(dialog)
    end
  end
end
