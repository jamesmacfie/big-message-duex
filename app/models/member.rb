class Member < ApplicationRecord
  belongs_to :person
  belongs_to :channel

  # Validations
  validates :role, inclusion: { in: %w[admin member] }
  validates :person_id, uniqueness: { scope: :channel_id }

  # Scopes
  scope :admins, -> { where(role: "admin") }
  scope :regular_members, -> { where(role: "member") }

  # Methods
  def admin?
    role == "admin"
  end

  def make_admin!
    update!(role: "admin")
  end

  def make_member!
    update!(role: "member")
  end

  def update_last_viewed!
    update!(last_viewed_at: Time.current)
  end

  def typing!
    update!(typing_at: Time.current)
  end

  def stop_typing!
    update!(typing_at: nil)
  end

  def typing?
    typing_at.present? && typing_at > 5.seconds.ago
  end

  def unread_count
    return 0 unless last_viewed_at

    channel.messages.where("created_at > ?", last_viewed_at).count
  end

  def has_unread?
    unread_count > 0
  end
end
