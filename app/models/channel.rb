class Channel < ApplicationRecord
  belongs_to :created_by, class_name: "Person"
  has_many :members, dependent: :destroy
  has_many :people, through: :members
  has_many :messages, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :channel_type, inclusion: { in: %w[channel dm] }

  # Scopes
  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :channels, -> { where(channel_type: "channel") }
  scope :dms, -> { where(channel_type: "dm") }
  scope :public_channels, -> { where(is_private: false, channel_type: "channel") }

  # Methods
  def archived?
    archived_at.present?
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def add_member(person, role: "member")
    members.create!(person: person, role: role)
  end

  def member?(person)
    members.exists?(person: person)
  end

  def admin?(person)
    members.exists?(person: person, role: "admin")
  end
end
