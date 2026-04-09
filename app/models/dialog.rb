class Dialog < ApplicationRecord
  WORKFLOW_STATES = %w[
    collecting_info
    intake_complete
    brief_ready
    prompt_ready
    conspect_generated
    conspect_reviewed
    conspect_needs_revision
  ].freeze

  TOPIC_SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :workflow_state, presence: true, inclusion: { in: WORKFLOW_STATES }
  validates :topic_slug, format: { with: TOPIC_SLUG_FORMAT }, allow_nil: true

  before_validation :normalize_goal

  scope :by_last_message, -> {
    left_joins(:messages)
      .group(:id)
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST, dialogs.created_at DESC"))
  }

  private

  def normalize_goal
    self.goal = goal&.strip&.presence
  end
end
