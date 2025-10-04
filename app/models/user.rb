class User < ApplicationRecord
  has_secure_password
  has_one :person, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  # Callbacks
  after_create :create_person_profile

  # Normalize email to lowercase before saving
  before_validation :normalize_email

  # Email confirmation methods
  def confirmed?
    email_confirmed_at.present?
  end

  def generate_confirmation_token!
    self.email_confirmation_token = SecureRandom.urlsafe_base64
    self.email_confirmation_sent_at = Time.current
    save!
  end

  def confirm_email!
    update!(email_confirmed_at: Time.current, email_confirmation_token: nil)
  end

  # Password reset methods
  def generate_reset_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  def reset_token_expired?
    return true if reset_password_sent_at.nil?
    reset_password_sent_at < 2.hours.ago
  end

  def reset_password!(new_password)
    self.password = new_password
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save!
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  def create_person_profile
    create_person!(name: email.split("@").first.titleize, is_agent: false)
  end
end
