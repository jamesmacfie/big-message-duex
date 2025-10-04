# Big Message V2

A real-time Slack-like messaging application built with Rails, featuring channels, DMs, threads, AI agents, and comprehensive collaboration features.

## Project Overview

Big Message is a modern messaging platform that combines the familiarity of Slack with AI-powered agents. Users can create channels, send direct messages, organize conversations in threads, and interact with AI characters that can participate in conversations.

## Technology Stack

- **Backend**: Ruby on Rails 7.2.2.2
- **Ruby Version**: 3.4.5 (managed via Makefile)
- **Database**: PostgreSQL (via Docker)
- **Cache/Queue**: Redis (via Docker)
- **Real-time**: Action Cable with Redis adapter
- **Frontend**: Rails Views with Tailwind CSS
- **JavaScript**: Stimulus controllers + Turbo Streams
- **AI Integration**: OpenAI API (GPT-5)
- **External APIs**: Giphy API
- **Local Development**: Docker Compose for services
- **Testing**: Minitest with fixtures
- **Authentication**: Rails built-in authentication with email validation

## Core Features

### Communication
- **Channels**: Public and private channels with descriptions, favorites, and admin management
- **Direct Messages**: 1-on-1 or group conversations between users and AI agents
- **Threads**: Reply to any message in a dynamic side panel with reply indicators
- **Real-time Updates**: Instant message delivery via Action Cable and Redis pub/sub

### User Management
- **Authentication**: Email-based signup/login with validation
- **People**: Each user has one person profile (name, avatar, description)
- **Invites**: Non-expiring invite system with archival of superseded invites

### AI Integration
- **AI Agents**: Create AI-powered chat participants with custom prompts
- **DM Responses**: Agents respond intelligently in direct messages
- **Typing Indicators**: Shows when agents are "thinking"
- **Prebuilt Agents**: Several ready-to-use AI characters

### Rich Messaging
- **Emoji Reactions**: Add emoji responses to any message
- **Slash Commands**: `/gif` command for Giphy integration
- **@Mentions**: Tag users to get their attention
- **Markdown**: Full markdown support for message formatting
- **Attachments**: Upload and display various file types
- **Message Editing**: Authors can edit their own messages

### Organization
- **Favorites**: Star channels and DMs for quick access
- **Unread Tracking**: Badge counts based on viewing timestamps
- **Search**: Fuzzy search across channels, DMs, and messages
- **Left Sidebar**: Organized list of favorites, channels, and DMs

### Channel Management
- **Channel Creation/Editing**: Modal-based UI for channel configuration
- **Admin Roles**: Channel admins can manage settings and other admins
- **Private Channels**: Invite-only channels
- **Channel Browsing**: Discover channels you're a member of
- **Archive**: Channels can be archived (never deleted)

### UX Features
- **Auto-scroll**: Messages auto-scroll when at bottom
- **Typing Indicators**: See when others are typing
- **Unread Counts**: Track unread messages per channel
- **Settings**: User profile and preferences management
- **Slack-like UI**: Familiar interface using Tailwind CSS

## Documentation

### Planning & Requirements
- **[Requirements](./REQUIREMENTS.md)**: Detailed feature requirements and specifications
- **[Database Schema](./DATABASE_SCHEMA.md)**: Complete database design and relationships
- **[Implementation Plan](./IMPLEMENTATION_PLAN.md)**: Phased development approach
- **[Acceptance Criteria](./ACCEPTANCE_CRITERIA.md)**: Master list of testable criteria

## Quick Start

This project uses a **Makefile** for all common development tasks. You should always use `make` commands instead of running Rails commands directly, as the Makefile ensures the correct Ruby version (3.4.5) and PATH are configured.

> **⚠️ Important**: Always use `make` commands for development tasks. The Makefile automatically configures the Ruby 3.4.5 environment. Running `rails` or `bundle` directly may use the wrong Ruby version.

```bash
# Complete setup (first time only)
make setup

# Start the development server (Rails + Tailwind watcher)
make server

# Access the application at http://localhost:3000
```

### Initial Setup Steps

1. **Clone the repository**
2. **Ensure Ruby 3.4.5 is installed** (via ruby-install, rbenv, or similar)
3. **Copy environment file**: `cp .env.sample .env`
4. **Run setup**: `make setup` (installs deps, starts Docker, sets up DB)
5. **Start server**: `make server`

The `make setup` command will:
- Start PostgreSQL and Redis via Docker Compose
- Install all Ruby gem dependencies
- Create and migrate the database
- Seed the database with initial data

## Environment Variables

Copy `.env.sample` to `.env` and configure:

```
OPENAI_API_KEY=your_openai_api_key
GIPHY_API_KEY=your_giphy_api_key
REDIS_URL=redis://localhost:6379/1
DATABASE_URL=postgresql://localhost/big_message_development
```

## Make Commands Reference

The project uses a Makefile to standardize development tasks and ensure correct Ruby version usage. Run `make help` to see all available commands.

### Setup & Installation
```bash
make setup          # Complete project setup (installs deps, starts Docker, sets up database)
make install        # Install Ruby dependencies only
```

### Database Management
```bash
make db-create      # Create the database
make db-migrate     # Run pending migrations
make db-seed        # Seed the database with sample data
make db-setup       # Create, migrate, and seed (useful for first-time setup)
make db-reset       # Drop, create, migrate, and seed (fresh start)
```

### Docker Services
The app requires PostgreSQL and Redis running via Docker:
```bash
make docker-up      # Start PostgreSQL and Redis containers
make docker-down    # Stop all Docker containers
make docker-logs    # View logs from Docker services
```

### Development Server
```bash
make server         # Start Rails server + Tailwind CSS watcher (uses bin/dev + Procfile.dev)
make console        # Open Rails console for interactive debugging
```

### Testing
```bash
make test           # Run the full test suite (all models, controllers, integration tests)
```

For running specific tests:
```bash
# Run a specific test file
bin/rails test test/models/user_test.rb

# Run a specific test by line number
bin/rails test test/models/user_test.rb:12

# Run tests matching a pattern
bin/rails test test/controllers/*_test.rb
```

### Code Generation
```bash
# Generate a model with attributes
make generate-model NAME=Post attrs="title:string body:text published:boolean"

# Generate a controller with actions
make generate-controller NAME=Posts actions="index show new create"

# Generate a migration
make generate-migration NAME=AddSlugToPosts

# Run any Rails command
make rails cmd="routes"                    # Show all routes
make rails cmd="db:migrate:status"         # Check migration status
```

### Utilities
```bash
make clean          # Remove temporary and log files
```

## Testing Guide

This project uses Rails' built-in **Minitest** framework with fixtures for test data.

### Test Structure

```
test/
├── controllers/          # Controller tests (request specs)
├── models/               # Model unit tests
├── integration/          # Integration/feature tests
├── mailers/              # Mailer tests
│   └── previews/        # Email previews for development
├── channels/             # Action Cable channel tests
├── fixtures/             # Test data (YAML files)
└── test_helper.rb       # Test configuration
```

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
bin/rails test test/models/user_test.rb

# Run specific test by name
bin/rails test test/models/user_test.rb -n test_should_validate_email

# Run tests in a directory
bin/rails test test/models/

# Run tests with verbose output
bin/rails test -v
```

### Test Database

The test database is automatically managed:
- Created when you run tests for the first time
- Migrations are applied automatically
- Database is rolled back after each test
- Fixtures are loaded before each test

To manually reset the test database:
```bash
RAILS_ENV=test bin/rails db:reset
```

### Writing Tests

**Model Test Example:**
```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = User.new
    assert_not user.save, "Saved user without email"
  end

  test "should save valid user" do
    user = User.new(email: "test@example.com", password: "password123")
    assert user.save, "Failed to save valid user"
  end
end
```

**Controller Test Example:**
```ruby
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "new@example.com" } }
    end
    assert_redirected_to user_url(User.last)
  end
end
```

### Developer Testing Expectations

**Phase 19** of the implementation plan focuses on comprehensive testing, but developers should:

1. **Write tests as you develop** - Don't wait until Phase 19
2. **Test critical paths first**:
   - Authentication flows (signup, login, email confirmation)
   - Channel creation and membership
   - Message sending and real-time delivery
   - Invite system
3. **Use fixtures wisely** - Keep test data minimal but realistic
4. **Test edge cases**:
   - Invalid data
   - Unauthorized access
   - Missing associations
   - Concurrent updates
5. **Integration tests for user flows**:
   - Complete signup → login → create channel → send message flows
   - Invite acceptance flows
   - Real-time message delivery

### Test Coverage Goals (Phase 19)

When implementing Phase 19, aim for:
- **Models**: 80%+ coverage (validations, associations, methods)
- **Controllers**: 70%+ coverage (happy paths + auth failures)
- **Integration**: Key user journeys covered
- **Mailers**: All email templates tested

### Browser/System Tests

For end-to-end testing with JavaScript:
```bash
# System tests use Capybara + Selenium
bin/rails test:system

# Run specific system test
bin/rails test:system test/system/messages_test.rb
```

System tests launch a real browser and test the full stack including JavaScript, Turbo, and Stimulus controllers.

## Development Workflow

1. Each feature is built incrementally
2. Features build upon each other
3. **Write tests** alongside feature development
4. Commit after each complete feature
5. **Run tests** before committing: `make test`
6. Reference acceptance criteria for completion
7. Use `make` commands for all development tasks

## Architecture Decisions

### Real-time Communication
- Action Cable for WebSocket connections
- Redis pub/sub for message broadcasting
- Non-blocking AI agent processing via pub/sub

### Data Model
- Users (auth) are separate from People (profiles) for flexibility
- Members join table tracks channel/DM membership and metadata
- Unread tracking via timestamp comparison
- Soft delete pattern for channels (archive vs delete)

### AI Integration
- Async processing to prevent blocking
- Pub/sub pattern for agent responses
- Typing indicators during AI processing
- Only responds in DMs (not channels)

## Project Status

This project is currently in development. See [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) for current phase and progress.
