class Message < ApplicationRecord
  belongs_to :person
  belongs_to :channel

  validates :content, presence: true
  validates :person, presence: true
  validates :channel, presence: true

  scope :ordered, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc) }

  def edited?
    edited_at.present?
  end

  def mark_as_edited!
    update!(edited_at: Time.current)
  end
end
