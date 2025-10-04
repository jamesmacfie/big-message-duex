class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_one_attached :avatar

  # Validations
  validates :name, presence: true
  validates :is_agent, inclusion: { in: [ true, false ] }
  validates :theme, inclusion: { in: %w[light dark] }, allow_nil: true
  validate :user_or_agent

  # Scopes
  scope :agents, -> { where(is_agent: true) }
  scope :humans, -> { where(is_agent: false) }

  private

  def user_or_agent
    if is_agent && user_id.present?
      errors.add(:user, "AI agents cannot be associated with a user")
    elsif !is_agent && user_id.nil?
      errors.add(:user, "Regular people must be associated with a user")
    end
  end
end
