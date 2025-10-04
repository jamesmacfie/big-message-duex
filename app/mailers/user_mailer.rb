class UserMailer < ApplicationMailer
  def confirmation_email(user)
    @user = user
    @confirmation_url = confirmation_url(user.email_confirmation_token)

    mail to: user.email,
         subject: "Please confirm your email address"
  end
end
