class Favorite < ApplicationRecord
  belongs_to :person
  belongs_to :channel

  validates :person_id, uniqueness: { scope: :channel_id }
end
