# Big Message V2

A real-time Slack-like messaging application built with Rails, featuring channels, DMs, threads, AI agents, and comprehensive collaboration features.

## Project Overview

Big Message is a modern messaging platform that combines the familiarity of Slack with AI-powered agents. Users can create channels, send direct messages, organize conversations in threads, and interact with AI characters that can participate in conversations.

## Technology Stack

- **Backend**: Ruby on Rails 7.x
- **Database**: PostgreSQL
- **Cache/Queue**: Redis
- **Real-time**: Action Cable
- **Frontend**: Rails Views with Tailwind CSS
- **AI Integration**: OpenAI API (GPT-5)
- **External APIs**: Giphy API
- **Local Development**: Docker Compose
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

```bash
# Install dependencies
bundle install

# Setup database
docker-compose up -d
rails db:create db:migrate db:seed

# Start Rails server
rails server

# In another terminal, start Action Cable (if needed)
# Configured in config/cable.yml
```

## Environment Variables

Copy `.env.sample` to `.env` and configure:

```
OPENAI_API_KEY=your_openai_api_key
GIPHY_API_KEY=your_giphy_api_key
REDIS_URL=redis://localhost:6379/1
DATABASE_URL=postgresql://localhost/big_message_development
```

## Development Workflow

1. Each feature is built incrementally
2. Features build upon each other
3. Commit after each complete feature
4. Test thoroughly before moving to next feature
5. Reference acceptance criteria for completion

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
