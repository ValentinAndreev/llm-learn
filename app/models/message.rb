class Message < ApplicationRecord
  belongs_to :dialog

  validates :role, inclusion: { in: %w[user assistant] }
  validates :content, presence: true
end
