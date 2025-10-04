class Mention < ApplicationRecord
  belongs_to :message
  belongs_to :person

  validates :message_id, uniqueness: { scope: :person_id }
end
