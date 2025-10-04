class Invite < ApplicationRecord
  belongs_to :invited_by, class_name: "Person"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create
  before_create :archive_existing_invites

  scope :pending, -> { where(accepted_at: nil, archived_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :active, -> { where(accepted_at: nil, archived_at: nil) }

  def accepted?
    accepted_at.present?
  end

  def archived?
    archived_at.present?
  end

  def valid_for_acceptance?
    !accepted? && !archived?
  end

  def accept!
    update!(accepted_at: Time.current)
  end

  def archive!
    update!(archived_at: Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def archive_existing_invites
    # Archive any existing pending invites for the same email
    self.class.pending.where(email: email).update_all(archived_at: Time.current)
  end
end
