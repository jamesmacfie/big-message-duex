# Big Message V2

A modern, real-time Slack-like messaging application with AI-powered agents.

## Features

- 💬 **Real-time Messaging** - Instant message delivery via WebSocket
- 🏢 **Channels** - Public and private channels with admin management
- 💌 **Direct Messages** - Chat with individuals or groups
- 🧵 **Threads** - Organize conversations with threaded replies
- 🤖 **AI Agents** - Chat with GPT-powered AI assistants
- 😄 **Emoji Reactions** - React to messages with emojis
- 📎 **File Attachments** - Share images, videos, and documents
- 🔍 **Search** - Fuzzy search across channels and messages
- ⭐ **Favorites** - Quick access to important channels
- 📬 **Unread Tracking** - Never miss a message
- ⌨️ **Typing Indicators** - See when others are typing
- @️⃣ **Mentions** - Tag people in conversations
- 🎨 **Themes** - Light and dark mode support

## Tech Stack

- **Backend**: Ruby on Rails 7.2
- **Database**: PostgreSQL
- **Cache**: Redis
- **Real-time**: Action Cable
- **Frontend**: Tailwind CSS
- **AI**: OpenAI GPT-5
- **External APIs**: Giphy

## Prerequisites

- Ruby 3.4.5
- Rails 7.2
- Docker & Docker Compose
- Node.js (for asset compilation)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd big-message-2
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup Environment Variables

```bash
cp .env.sample .env
```

Edit `.env` and add your API keys:
- `OPENAI_API_KEY` - Get from [OpenAI](https://platform.openai.com)
- `GIPHY_API_KEY` - Get from [Giphy Developers](https://developers.giphy.com)

### 4. Start Docker Services

```bash
docker-compose up -d
```

This starts PostgreSQL and Redis.

### 5. Setup Database

```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed command creates prebuilt AI agents.

### 6. Start Rails Server

```bash
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000)

## Development

### Running Tests

```bash
rails test
# or
rspec
```

### Code Quality

```bash
rubocop
```

### Database Console

```bash
rails dbconsole
```

### Rails Console

```bash
rails console
```

## Documentation

Comprehensive documentation is available:

- **[CLAUDE.md](./CLAUDE.md)** - Project overview and quick reference
- **[REQUIREMENTS.md](./REQUIREMENTS.md)** - Detailed feature requirements
- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Complete database schema
- **[IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)** - Development roadmap
- **[ACCEPTANCE_CRITERIA.md](./ACCEPTANCE_CRITERIA.md)** - Feature completion checklist

## Architecture

### Data Model

- **Users** - Authentication and account management
- **People** - User profiles and AI agents
- **Channels** - Communication spaces (channels and DMs)
- **Members** - Channel membership with metadata
- **Messages** - Chat messages with threading support
- **Reactions** - Emoji reactions to messages
- **Attachments** - File uploads
- **Mentions** - @mentions in messages
- **Favorites** - User's favorited channels

### Real-time Architecture

Action Cable handles WebSocket connections:
- Message broadcasting
- Typing indicators
- Presence updates
- AI agent responses (pub/sub)

Redis serves as the pub/sub backend.

## API Integration

### OpenAI

AI agents use GPT-5 for intelligent responses in DMs. Configure with:

```
OPENAI_API_KEY=your_key_here
```

### Giphy

The `/gif` slash command searches Giphy. Configure with:

```
GIPHY_API_KEY=your_key_here
```

## Contributing

1. Follow the implementation plan phases
2. Write tests for new features
3. Ensure all tests pass
4. Follow Ruby/Rails style guides
5. Commit after each complete feature

## License

[Add your license here]

## Support

For issues and questions, please create an issue in the repository.
