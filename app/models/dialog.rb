class Dialog < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }

  scope :by_last_message, -> {
    left_joins(:messages)
      .group(:id)
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST, dialogs.created_at DESC"))
  }
end
