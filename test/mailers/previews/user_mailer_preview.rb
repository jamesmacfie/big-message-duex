# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/confirmation_email
  def confirmation_email
    user = User.new(
      email: "newuser@example.com",
      email_confirmation_token: "sample_token_abc123"
    )

    # Create a person for the user
    user.build_person(name: "John Doe", is_agent: false)

    UserMailer.confirmation_email(user)
  end
end
