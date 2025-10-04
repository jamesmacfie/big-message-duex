class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_one_attached :avatar
  has_many :members, dependent: :destroy
  has_many :channels, through: :members
  has_many :created_channels, class_name: "Channel", foreign_key: :created_by_id
  has_many :messages, dependent: :destroy
  has_many :sent_invites, class_name: "Invite", foreign_key: :invited_by_id, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_channels, through: :favorites, source: :channel
  has_many :mentions, dependent: :destroy
  has_many :mentioned_in_messages, through: :mentions, source: :message

  # Validations
  validates :name, presence: true
  validates :is_agent, inclusion: { in: [ true, false ] }
  validates :theme, inclusion: { in: %w[light dark] }, allow_nil: true
  validate :user_or_agent

  # Scopes
  scope :agents, -> { where(is_agent: true) }
  scope :humans, -> { where(is_agent: false) }

  # Methods
  def accessible_channels
    channels.active
  end

  def recent_mentions(limit: 10)
    # Get recent messages where this person was mentioned
    mentioned_in_messages
      .joins(:channel)
      .where(channels: { archived_at: nil })
      .order(created_at: :desc)
      .limit(limit)
  end

  def unread_mentions_count
    # Count mentions since the last time the person viewed each channel
    mentions
      .joins(:message)
      .joins("INNER JOIN members ON members.person_id = #{id} AND members.channel_id = messages.channel_id")
      .where("messages.created_at > COALESCE(members.last_viewed_at, '1970-01-01')")
      .count
  end

  private

  def user_or_agent
    if is_agent && user_id.present?
      errors.add(:user, "AI agents cannot be associated with a user")
    elsif !is_agent && user_id.nil?
      errors.add(:user, "Regular people must be associated with a user")
    end
  end
end
