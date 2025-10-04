class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :person

  validates :emoji, presence: true
  validates :person_id, uniqueness: { scope: [:message_id, :emoji] }
end
