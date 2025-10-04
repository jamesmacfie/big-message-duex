# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invite_mailer/invitation_email
  def invitation_email
    # Create a sample person for preview
    person = Person.new(
      name: "John Doe",
      is_agent: false
    )

    # Create a sample invite for preview
    invite = Invite.new(
      email: "newuser@example.com",
      token: "sample_token_abc123",
      invited_by: person
    )

    InviteMailer.invitation_email(invite)
  end
end
