class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :person

  validates :emoji, presence: true, length: { maximum: 10 }
  validates :person_id, uniqueness: { scope: [:message_id, :emoji] }
  validate :emoji_format

  private

  def emoji_format
    return if emoji.blank?

    # Check if the string contains at least one emoji character
    # This regex matches most common emoji patterns
    unless emoji.match?(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F1E0}-\u{1F1FF}]/)
      errors.add(:emoji, "must be a valid emoji")
    end
  end
end
