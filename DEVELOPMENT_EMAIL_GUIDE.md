# Development Email Guide

## Viewing Emails in Development

Big Message is configured with two ways to view emails during development:

### 1. Letter Opener (Automatic Browser Opening)

When you send an email in development mode, it will automatically open in your default browser.

**How it works:**
- When any email is sent (invitations, confirmations, password resets), it opens in a new browser tab
- Emails are saved to `tmp/letter_opener/`
- No SMTP server needed

**Example:**
```ruby
# When this runs in development:
InviteMailer.invitation_email(@invite).deliver_later

# A browser tab will open showing the email
```

### 2. Email Previews (Manual Viewing)

View emails without actually sending them by visiting the Rails mailer previews.

**URLs:**
- All mailer previews: http://localhost:3000/rails/mailers
- Invitation email: http://localhost:3000/rails/mailers/invite_mailer/invitation_email
- Confirmation email: http://localhost:3000/rails/mailers/user_mailer/confirmation_email

**How to add new previews:**
Edit `test/mailers/previews/invite_mailer_preview.rb` to add or modify email previews.

## Configuration

Development email configuration is in `config/environments/development.rb`:

```ruby
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.perform_deliveries = true
```

## Testing Email Flow

### Testing Invitation Email:

1. Start your Rails server: `rails server`
2. Log in as a user
3. Navigate to the invite page: http://localhost:3000/invites/new
4. Enter an email address and submit
5. The invitation email will automatically open in your browser

### Testing Confirmation Email:

1. Start your Rails server: `rails server`
2. Navigate to the signup page: http://localhost:3000/signup
3. Enter an email and password (without an invite token)
4. Submit the form
5. The confirmation email will automatically open in your browser

## Troubleshooting

**Emails not opening in browser:**
- Make sure the `letter_opener` gem is installed: `bundle install`
- Check that `config.action_mailer.delivery_method = :letter_opener` is set in development.rb
- Restart your Rails server

**Preview not working:**
- Make sure your Rails server is running
- Visit http://localhost:3000/rails/mailers to see all available previews

**Clearing old emails:**
```bash
rm -rf tmp/letter_opener
```
