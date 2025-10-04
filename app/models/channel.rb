class Channel < ApplicationRecord
  belongs_to :created_by, class_name: "Person"
  has_many :members, dependent: :destroy
  has_many :people, through: :members
  has_many :messages, dependent: :destroy

  # Validations
  validates :name, presence: true, if: :channel?
  validates :name, uniqueness: { scope: :channel_type, conditions: -> { where(channel_type: "channel") } }, if: :channel?
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

  # DM-specific methods
  def dm?
    channel_type == "dm"
  end

  def channel?
    channel_type == "channel"
  end

  def dm_name_for(person)
    return name if channel?

    other_people = people.where.not(id: person.id)
    if other_people.count == 0
      person.name # DM with yourself
    elsif other_people.count == 1
      other_people.first.name
    else
      # Group DM
      names = other_people.pluck(:name).sort
      if names.count > 3
        "#{names.first(3).join(', ')} and #{names.count - 3} others"
      else
        names.join(", ")
      end
    end
  end

  # Class method to find or create a DM between people
  def self.find_or_create_dm_between(person_ids)
    person_ids = person_ids.sort

    # Find existing DM with exact same participants
    dm = Channel.dms.active.joins(:members)
                     .group("channels.id")
                     .having("COUNT(members.id) = ? AND array_agg(members.person_id ORDER BY members.person_id) = ARRAY[?]::bigint[]",
                             person_ids.count, person_ids)
                     .first

    return dm if dm

    # Create new DM
    dm = Channel.create!(
      channel_type: "dm",
      is_private: true,
      created_by_id: person_ids.first
    )

    person_ids.each do |person_id|
      dm.add_member(Person.find(person_id), role: "member")
    end

    dm
  end
end
