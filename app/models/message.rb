class Message < ApplicationRecord
  belongs_to :person
  belongs_to :channel
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy

  validates :content, presence: true
  validates :person, presence: true
  validates :channel, presence: true

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
end
