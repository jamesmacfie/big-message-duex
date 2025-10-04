class InviteMailer < ApplicationMailer
  def invitation_email(invite)
    @invite = invite
    @inviter = invite.invited_by
    @signup_url = signup_url(invite_token: invite.token)

    mail to: invite.email,
         subject: "#{@inviter.name} invited you to join Big Message"
  end
end
