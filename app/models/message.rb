class Message < ApplicationRecord
  belongs_to :person
  belongs_to :channel, touch: true
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :mentioned_people, through: :mentions, source: :person
  has_many :attachments, dependent: :destroy

  validates :person, presence: true
  validates :channel, presence: true
  validates :content, presence: true

  after_create :process_mentions
  after_update :process_mentions, if: :saved_change_to_content?
  after_commit :enqueue_ai_agent_response, on: :create, if: :should_trigger_agent_response?

  scope :ordered, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :top_level, -> { where(parent_message_id: nil) }
  scope :replies_only, -> { where.not(parent_message_id: nil) }

  def edited?
    edited_at.present?
  end

  def mark_as_edited!
    update!(edited_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  # Thread-related methods
  def thread?
    parent_message_id.present?
  end

  def has_replies?
    replies.exists?
  end

  def reply_count
    replies.count
  end

  def latest_reply
    replies.order(created_at: :desc).first
  end

  def latest_reply_snippet(length: 50)
    return nil unless latest_reply
    content = latest_reply.content.to_s.gsub(/\s+/, ' ').strip
    content.length > length ? "#{content[0...length]}..." : content
  end

  def replier_people(limit: 5)
    replies.includes(:person).order(created_at: :desc).limit(limit).map(&:person).uniq
  end

  def mentions?(person)
    mentioned_people.exists?(id: person.id)
  end

  def has_attachments?
    attachments.any?
  end

  private

  def process_mentions
    MentionParser.new(self).process
  end

  def should_trigger_agent_response?
    # Trigger for:
    # 1. Top-level messages in DM channels (will create a thread)
    # 2. Thread replies in DM channels (will continue the thread)
    # Only when message is from a human (not an agent)
    channel.dm? && !person.is_agent?
  end

  def enqueue_ai_agent_response
    AiAgentResponderJob.perform_later(id)
  end
end
