class Message < ApplicationRecord
  belongs_to :person
  belongs_to :channel, touch: true
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :mentioned_people, through: :mentions, source: :person

  validates :content, presence: true
  validates :person, presence: true
  validates :channel, presence: true

  after_create :process_mentions
  after_update :process_mentions, if: :saved_change_to_content?

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

  private

  def process_mentions
    MentionParser.new(self).process
  end
end
