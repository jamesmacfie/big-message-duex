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

# Create AI Agents
puts "\n🤖 Creating AI Agents..."

agents_data = [
  {
    name: "Helpful Assistant",
    description: "A friendly AI assistant ready to help with any questions",
    agent_prompt: "You are a helpful, friendly AI assistant. You provide clear, concise, and accurate answers to questions. You're patient, understanding, and always ready to help. Keep your responses conversational and engaging."
  },
  {
    name: "Code Reviewer",
    description: "AI assistant specialized in code review and software development",
    agent_prompt: "You are an expert code reviewer and software engineer. You provide constructive feedback on code, suggest improvements, identify potential bugs, and recommend best practices. You're familiar with multiple programming languages and frameworks."
  },
  {
    name: "Creative Writer",
    description: "AI assistant for creative writing and storytelling",
    agent_prompt: "You are a creative writing assistant. You help with brainstorming ideas, developing characters, crafting compelling narratives, and providing feedback on creative writing. You're imaginative, encouraging, and skilled in various writing styles and genres."
  },
  {
    name: "Data Analyst",
    description: "AI assistant for data analysis and insights",
    agent_prompt: "You are a data analyst AI. You help interpret data, suggest analytical approaches, explain statistical concepts, and provide insights from data. You're skilled in data visualization concepts, statistical methods, and can explain complex analyses in simple terms."
  },
  {
    name: "Product Manager",
    description: "AI assistant for product management and strategy",
    agent_prompt: "You are a product management AI assistant. You help with product strategy, feature prioritization, user story creation, roadmap planning, and stakeholder communication. You think strategically about user needs, business goals, and technical feasibility."
  }
]

agents_data.each do |agent_data|
  agent = Person.find_or_initialize_by(name: agent_data[:name], is_agent: true) do |p|
    p.description = agent_data[:description]
    p.agent_prompt = agent_data[:agent_prompt]
  end

  if agent.new_record?
    agent.save!
    puts "  ✅ Created AI agent: #{agent.name}"
  else
    # Update existing agent
    agent.update!(
      description: agent_data[:description],
      agent_prompt: agent_data[:agent_prompt]
    )
    puts "  ✅ Updated AI agent: #{agent.name}"
  end
end

puts "🎉 Seeding complete!"
puts ""
puts "You can now log in with:"
puts "  Email: user@example.com"
puts "  Password: testtest123"
puts ""
puts "  Email: user2@example.com"
puts "  Password: testtest123"
puts ""
puts "🤖 AI Agents are ready! Start a DM with any agent to chat."
