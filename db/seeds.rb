# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create test users
user1 = User.find_or_initialize_by(email: "user@example.com") do |u|
  u.password = "testtest123"
  u.password_confirmation = "testtest123"
end
user1.save!
user1.confirm_email! unless user1.confirmed?
puts "✅ Created user: #{user1.email}"

user2 = User.find_or_initialize_by(email: "user2@example.com") do |u|
  u.password = "testtest123"
  u.password_confirmation = "testtest123"
end
user2.save!
user2.confirm_email! unless user2.confirmed?
puts "✅ Created user: #{user2.email}"

# Update person names to be more friendly
user1.person.update!(name: "User One") if user1.person.name == "User"
user2.person.update!(name: "User Two") if user2.person.name == "User2"

# Create general channel
general = Channel.find_or_initialize_by(name: "general", channel_type: "channel") do |c|
  c.description = "General discussion for everyone"
  c.is_private = false
  c.created_by = user1.person
end
general.save!
puts "✅ Created channel: ##{general.name}"

# Add both users as members
unless general.member?(user1.person)
  general.add_member(user1.person, role: "admin")
  puts "  ➕ Added #{user1.person.name} as admin"
end

unless general.member?(user2.person)
  general.add_member(user2.person, role: "member")
  puts "  ➕ Added #{user2.person.name} as member"
end

puts "🎉 Seeding complete!"
puts ""
puts "You can now log in with:"
puts "  Email: user@example.com"
puts "  Password: testtest123"
puts ""
puts "  Email: user2@example.com"
puts "  Password: testtest123"
