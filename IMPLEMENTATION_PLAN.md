# Big Message - Implementation Plan

## Overview

This document outlines the phased implementation approach for Big Message. Each phase builds upon the previous one and represents a committable unit of work. Features are ordered to ensure dependencies are met and the application remains functional after each phase.

## Development Principles

1. **Incremental Development**: Each phase adds working functionality
2. **Test as You Go**: Write tests for each feature before moving on
3. **Commit Often**: Commit after each complete feature or sub-phase
4. **Database First**: Create migrations and models before views
5. **Backend Then Frontend**: API/controllers before UI
6. **Real-time Last**: Add Action Cable integration after basic functionality works

---

## Phase 0: Project Setup

**Goal**: Bootstrap Rails application with development environment

### 0.1 Rails Application Setup
- [ ] Create new Rails 7.x application
- [ ] Configure PostgreSQL as database
- [ ] Set up Tailwind CSS
- [ ] Configure development environment
- [ ] Create `.gitignore`
- [ ] Create `.env.sample` with required variables

**Commit**: "Initial Rails application setup"

### 0.2 Docker Compose Configuration
- [ ] Create `docker-compose.yml`
- [ ] Add PostgreSQL service
- [ ] Add Redis service
- [ ] Configure volume mounts
- [ ] Test Docker setup

**Commit**: "Add Docker Compose for local development"

### 0.3 Basic Configuration
- [ ] Configure Action Cable with Redis
- [ ] Set up Active Storage
- [ ] Configure email settings (development/test)
- [ ] Add necessary gems (bcrypt, etc.)
- [ ] Set up RSpec or Minitest

**Commit**: "Configure Action Cable, Active Storage, and testing"

---

## Phase 1: Authentication Foundation

**Goal**: Users can sign up, log in, and manage accounts

### 1.1 User Model & Authentication
- [ ] Create `users` migration
- [ ] Create User model with validations
- [ ] Add password hashing (bcrypt)
- [ ] Create authentication helper methods
- [ ] Write model tests

**Commit**: "Add User model with authentication"

### 1.2 Email Confirmation
- [ ] Add confirmation token columns to users
- [ ] Create confirmation mailer
- [ ] Implement confirmation workflow
- [ ] Add confirmation routes and controller
- [ ] Write integration tests

**Commit**: "Implement email confirmation"

### 1.3 Signup & Login UI
- [ ] Create signup page with form
- [ ] Create login page with form
- [ ] Add session controller (create/destroy)
- [ ] Style with Tailwind
- [ ] Add flash messages
- [ ] Redirect after login/signup

**Commit**: "Add signup and login pages"

### 1.4 Password Reset
- [ ] Add reset token columns
- [ ] Create password reset mailer
- [ ] Add reset password form
- [ ] Add routes and controller actions
- [ ] Write integration tests

**Commit**: "Implement password reset flow"

---

## Phase 2: People & Profiles

**Goal**: Users have profiles (people) with customization

### 2.1 People Model
- [ ] Create `people` migration
- [ ] Create Person model with associations
- [ ] Link User → Person (1:1)
- [ ] Add validations
- [ ] Create person on user signup
- [ ] Write model tests

**Commit**: "Add Person model and user association"

### 2.2 Profile Settings
- [ ] Add Active Storage for avatars
- [ ] Create settings page
- [ ] Add form for name, description, avatar
- [ ] Add theme selection
- [ ] Update person controller
- [ ] Style settings page

**Commit**: "Add user profile settings page"

---

## Phase 3: Channels Foundation

**Goal**: Users can create and view channels

### 3.1 Channel & Member Models
- [ ] Create `channels` migration
- [ ] Create `members` migration
- [ ] Create Channel model
- [ ] Create Member model
- [ ] Add associations and validations
- [ ] Write model tests

**Commit**: "Add Channel and Member models"

### 3.2 Create Channel
- [ ] Add channels controller
- [ ] Create channel creation modal
- [ ] Add form for name, description, privacy
- [ ] Handle channel creation
- [ ] Add creator as admin member
- [ ] Style modal with Tailwind

**Commit**: "Implement channel creation"

### 3.3 Channel List Sidebar
- [ ] Create left sidebar component
- [ ] Query user's channels
- [ ] Display channel list
- [ ] Add click to navigate
- [ ] Style sidebar
- [ ] Add "Create Channel" button

**Commit**: "Add left sidebar with channel list"

### 3.4 Channel View
- [ ] Create channel show page
- [ ] Display channel name and description
- [ ] Show empty state (no messages yet)
- [ ] Add authorization (members only)
- [ ] Style channel view

**Commit**: "Add basic channel view page"

---

## Phase 4: Basic Messaging

**Goal**: Users can send and view messages in channels

### 4.1 Message Model
- [ ] Create `messages` migration
- [ ] Create Message model
- [ ] Add associations (channel, person)
- [ ] Add validations
- [ ] Write model tests

**Commit**: "Add Message model"

### 4.2 Send Messages
- [ ] Add messages controller
- [ ] Create message form at bottom of channel
- [ ] Handle message creation
- [ ] Display messages in channel
- [ ] Order by created_at
- [ ] Style message list and form

**Commit**: "Implement basic message sending"

### 4.3 Message Display
- [ ] Create message component
- [ ] Show author name and avatar
- [ ] Show timestamp
- [ ] Format timestamp nicely
- [ ] Style message bubbles
- [ ] Add scroll container

**Commit**: "Improve message display UI"

### 4.4 Markdown Support
- [ ] Add markdown gem (redcarpet or similar)
- [ ] Render message content as markdown
- [ ] Sanitize HTML output
- [ ] Style markdown elements
- [ ] Test edge cases

**Commit**: "Add markdown rendering for messages"

---

## Phase 5: Real-time Updates

**Goal**: Messages appear instantly via Action Cable

### 5.1 Channel Broadcasting
- [ ] Create MessagesChannel (Action Cable)
- [ ] Broadcast on message create
- [ ] Subscribe users to channel streams
- [ ] Test broadcasting

**Commit**: "Add Action Cable message broadcasting"

### 5.2 Real-time UI Updates
- [ ] Add JavaScript to subscribe to channel
- [ ] Append new messages to DOM
- [ ] Update message list in real-time
- [ ] Handle edge cases (user scrolled up)
- [ ] Test with multiple users

**Commit**: "Implement real-time message updates"

### 5.3 Auto-scroll Behavior
- [ ] Detect if user is at bottom
- [ ] Auto-scroll only if at bottom
- [ ] Show "New messages" indicator if scrolled up
- [ ] Click indicator to scroll to bottom

**Commit**: "Add smart auto-scroll behavior"

---

## Phase 6: Invites System

**Goal**: Users can invite others to join

### 6.1 Invite Model
- [ ] Create `invites` migration
- [ ] Create Invite model
- [ ] Add associations and validations
- [ ] Generate unique tokens
- [ ] Write model tests

**Commit**: "Add Invite model"

### 6.2 Send Invites
- [ ] Create invite form/modal
- [ ] Add invites controller
- [ ] Send invite email with link
- [ ] Archive old invites for same email
- [ ] Test invite creation

**Commit**: "Implement invite sending"

### 6.3 Accept Invites
- [ ] Add invite acceptance route
- [ ] Link to signup with token
- [ ] Mark invite as accepted
- [ ] Auto-login after signup via invite
- [ ] Handle expired tokens gracefully

**Commit**: "Implement invite acceptance flow"

---

## Phase 7: Channel Management

**Goal**: Manage channel members, admins, and settings

### 7.1 Channel Membership
- [ ] Add invite to channel UI
- [ ] Create member controller actions
- [ ] Add/remove members
- [ ] List channel members
- [ ] Authorization checks

**Commit**: "Add channel membership management"

### 7.2 Admin Roles
- [ ] Add admin promotion/demotion
- [ ] Restrict actions to admins
- [ ] Show admin badge in member list
- [ ] Prevent last admin from leaving
- [ ] Write authorization tests

**Commit**: "Implement channel admin roles"

### 7.3 Edit Channel
- [ ] Create edit channel modal
- [ ] Allow admins to edit name/description
- [ ] Update channel
- [ ] Show edit option in channel menu
- [ ] Authorization checks

**Commit**: "Add channel editing for admins"

### 7.4 Archive Channel
- [ ] Add archive action
- [ ] Set archived_at timestamp
- [ ] Hide archived channels from sidebar
- [ ] Show "Archived" indicator
- [ ] Prevent new messages in archived channels

**Commit**: "Implement channel archiving"

### 7.5 Channel Browsing
- [ ] Create channel browser page
- [ ] List all non-private channels user is member of
- [ ] Show channel info (name, description, members)
- [ ] Add join/leave buttons
- [ ] Filter and search

**Commit**: "Add channel browsing interface"

---

## Phase 8: Direct Messages

**Goal**: Users can DM each other

### 8.1 DM Channel Type
- [ ] Update Channel model for type
- [ ] Add scopes for channels vs DMs
- [ ] Compute DM names from participants
- [ ] Create DM helper methods

**Commit**: "Add DM support to Channel model"

### 8.2 Create DM
- [ ] Add "New DM" button in sidebar
- [ ] Create DM modal with person selector
- [ ] Find or create DM channel
- [ ] Navigate to DM
- [ ] Handle group DMs (multiple people)

**Commit**: "Implement DM creation"

### 8.3 DM List in Sidebar
- [ ] Query user's DMs
- [ ] Display in separate sidebar section
- [ ] Show participant names
- [ ] Different styling from channels
- [ ] Sort by recent activity

**Commit**: "Add DM list to sidebar"

---

## Phase 9: Threads

**Goal**: Users can reply to messages in threads

### 9.1 Thread Model Support
- [ ] Add parent_message_id to messages
- [ ] Add self-referential association
- [ ] Add scopes for top-level vs replies
- [ ] Write model tests

**Commit**: "Add thread support to Message model"

### 9.2 Reply in Thread
- [ ] Add "Reply" button to message menu
- [ ] Create thread panel component
- [ ] Show parent message at top
- [ ] List all replies
- [ ] Add reply form at bottom
- [ ] Style thread panel

**Commit**: "Implement thread panel and replies"

### 9.3 Thread Indicators
- [ ] Show reply count on parent message
- [ ] Show snippet of latest reply
- [ ] Click to open thread panel
- [ ] Close thread panel button
- [ ] Update counts in real-time

**Commit**: "Add thread indicators to messages"

### 9.4 Thread Real-time Updates
- [ ] Broadcast new replies
- [ ] Update thread panel live
- [ ] Update reply count live
- [ ] Handle thread panel not open

**Commit**: "Add real-time updates for threads"

---

## Phase 10: Message Interactions

**Goal**: Edit, delete, and react to messages

### 10.1 Edit Messages
- [ ] Add edit action to message menu
- [ ] Show edit form inline
- [ ] Update message content
- [ ] Show "edited" indicator
- [ ] Only allow author to edit
- [ ] Handle edit in real-time

**Commit**: "Implement message editing"

### 10.2 Delete Messages
- [ ] Add delete action to message menu
- [ ] Soft delete messages
- [ ] Show "deleted" placeholder
- [ ] Only allow author to delete
- [ ] Update UI in real-time

**Commit**: "Implement message deletion"

### 10.3 Emoji Reactions Model
- [ ] Create `reactions` migration
- [ ] Create Reaction model
- [ ] Add associations and validations
- [ ] Unique constraint per person/message/emoji
- [ ] Write model tests

**Commit**: "Add Reaction model"

### 10.4 Add Reactions
- [ ] Add emoji picker to message menu
- [ ] Create reaction on click
- [ ] Toggle reaction (remove if exists)
- [ ] Display reactions under message
- [ ] Group by emoji with counts
- [ ] Style reaction display

**Commit**: "Implement emoji reactions"

### 10.5 Reaction Real-time
- [ ] Broadcast reaction create/destroy
- [ ] Update reaction UI live
- [ ] Update counts dynamically
- [ ] Highlight user's reactions

**Commit**: "Add real-time reaction updates"

---

## Phase 11: Favorites & Unread Tracking

**Goal**: Track favorites and unread messages

### 11.1 Favorites Model
- [ ] Create `favorites` migration
- [ ] Create Favorite model
- [ ] Add associations and validations
- [ ] Write model tests

**Commit**: "Add Favorite model"

### 11.2 Favorite Channels
- [ ] Add favorite/unfavorite to channel menu
- [ ] Create favorites controller actions
- [ ] Show favorites section in sidebar
- [ ] Update UI in real-time
- [ ] Different icon for favorited

**Commit**: "Implement channel favorites"

### 11.3 Unread Tracking
- [ ] Add last_viewed_at to members
- [ ] Update on scroll to bottom
- [ ] Calculate unread count query
- [ ] Show count badge in sidebar
- [ ] Bold channel name if unread

**Commit**: "Add unread message tracking"

### 11.4 Unread Indicators
- [ ] Show unread badge on channels/DMs
- [ ] Clear on viewing channel
- [ ] Update counts in real-time
- [ ] Handle threads separately

**Commit**: "Implement unread indicators in UI"

---

## Phase 12: Typing Indicators

**Goal**: Show when others are typing

### 12.1 Typing Tracking
- [ ] Add typing_at to members
- [ ] Broadcast typing events
- [ ] Update on keypress (throttled)
- [ ] Clear after timeout or message sent

**Commit**: "Add typing indicator tracking"

### 12.2 Typing UI
- [ ] Subscribe to typing events
- [ ] Show "X is typing..." in channel
- [ ] Handle multiple people typing
- [ ] Style typing indicator
- [ ] Clear after timeout

**Commit**: "Implement typing indicators UI"

---

## Phase 13: Mentions

**Goal**: @mention people in messages

### 13.1 Mentions Model
- [ ] Create `mentions` migration
- [ ] Create Mention model
- [ ] Add associations and validations
- [ ] Write model tests

**Commit**: "Add Mention model"

### 13.2 Mention Detection
- [ ] Parse message content for @mentions
- [ ] Create mention records on message create
- [ ] Auto-complete people in channel
- [ ] Style mentions in message

**Commit**: "Implement mention detection and parsing"

### 13.3 Mention Notifications
- [ ] Query mentions for user
- [ ] Show mention indicator in UI
- [ ] Highlight mentioned messages
- [ ] Mark mentions as read

**Commit**: "Add mention notifications"

---

## Phase 14: Attachments

**Goal**: Upload and display file attachments

### 14.1 Attachments Model
- [ ] Create `attachments` migration
- [ ] Create Attachment model
- [ ] Configure Active Storage
- [ ] Add associations and validations
- [ ] Write model tests

**Commit**: "Add Attachment model with Active Storage"

### 14.2 File Upload
- [ ] Add file upload button to message form
- [ ] Handle multiple file uploads
- [ ] Validate file types and sizes
- [ ] Create attachments with message
- [ ] Show upload progress

**Commit**: "Implement file upload for messages"

### 14.3 Attachment Display
- [ ] Render images inline
- [ ] Show video player for videos
- [ ] Show download links for documents
- [ ] Generate thumbnails
- [ ] Style attachment cards

**Commit**: "Implement attachment rendering"

---

## Phase 15: Slash Commands

**Goal**: /gif command for Giphy search

### 15.1 Giphy Integration
- [ ] Add Giphy API gem
- [ ] Store API key in env
- [ ] Create Giphy service class
- [ ] Test API connection
- [ ] Handle API errors

**Commit**: "Add Giphy API integration"

### 15.2 Slash Command Parser
- [ ] Detect slash commands in messages
- [ ] Create command parser service
- [ ] Route to appropriate handler
- [ ] Return command results

**Commit**: "Add slash command parser"

### 15.3 /gif Command
- [ ] Implement /gif handler
- [ ] Search Giphy API
- [ ] Return GIF as attachment
- [ ] Handle no results
- [ ] Show preview in UI

**Commit**: "Implement /gif slash command"

---

## Phase 16: AI Agents

**Goal**: AI characters that respond in DMs

### 16.1 AI Agent People
- [ ] Add is_agent and agent_prompt to people
- [ ] Create agent factory
- [ ] Seed prebuilt agents
- [ ] List agents separately in UI
- [ ] Allow creating custom agents

**Commit**: "Add AI agent support to Person model"

### 16.2 Agent Settings
- [ ] Create agent creation form
- [ ] Edit agent prompt
- [ ] Set agent avatar and name
- [ ] Save agent configuration
- [ ] List user's agents

**Commit**: "Add AI agent creation and management"

### 16.3 OpenAI Integration
- [ ] Add OpenAI gem
- [ ] Configure API key from env
- [ ] Create OpenAI service class
- [ ] Build conversation context
- [ ] Handle API calls
- [ ] Test with GPT-4/GPT-5

**Commit**: "Add OpenAI API integration"

### 16.4 Agent Response Logic
- [ ] Listen for messages in DMs with agents
- [ ] Trigger agent response via pub/sub
- [ ] Build conversation history
- [ ] Call OpenAI API
- [ ] Post response as agent
- [ ] Handle errors gracefully

**Commit**: "Implement AI agent response logic"

### 16.5 Agent Typing Indicator
- [ ] Show agent typing when processing
- [ ] Set typing_at for agent
- [ ] Show "Agent is thinking..."
- [ ] Clear after response posted

**Commit**: "Add typing indicator for AI agents"

### 16.6 Prebuilt Agents
- [ ] Create seed data for agents
- [ ] Helpful Assistant
- [ ] Code Reviewer
- [ ] Creative Writer
- [ ] Data Analyst
- [ ] Product Manager
- [ ] Test agent responses

**Commit**: "Add prebuilt AI agents to seeds"

---

## Phase 17: Search

**Goal**: Search across channels and messages

### 17.1 Search Backend
- [ ] Add full-text search to messages
- [ ] Create search service
- [ ] Search channels by name
- [ ] Search DMs by participants
- [ ] Search messages by content
- [ ] Rank results by relevance
- [ ] Filter by user access

**Commit**: "Implement search backend"

### 17.2 Search UI
- [ ] Add search bar to top of sidebar
- [ ] Create search results dropdown
- [ ] Show results as user types
- [ ] Group by type (channels, DMs, messages)
- [ ] Click to navigate
- [ ] Keyboard navigation
- [ ] Style search UI

**Commit**: "Add search UI and autocomplete"

### 17.3 Search Optimization
- [ ] Add database indexes for search
- [ ] Cache frequent searches
- [ ] Optimize query performance
- [ ] Test with large dataset

**Commit**: "Optimize search performance"

---

## Phase 18: Polish & UX Improvements

**Goal**: Final touches and UX refinements

### 18.1 Loading States
- [ ] Add loading spinners
- [ ] Skeleton screens for lists
- [ ] Progress bars for uploads
- [ ] Disable buttons during actions

**Commit**: "Add loading states throughout app"

### 18.2 Error Handling
- [ ] Better error messages
- [ ] Toast notifications
- [ ] Retry logic for failed actions
- [ ] Graceful degradation

**Commit**: "Improve error handling and messages"

### 18.3 Responsive Design
- [ ] Mobile-friendly sidebar
- [ ] Responsive message layout
- [ ] Touch-friendly controls
- [ ] Test on various screen sizes

**Commit**: "Make UI responsive for mobile"

### 18.4 Accessibility
- [ ] Keyboard navigation
- [ ] ARIA labels
- [ ] Screen reader support
- [ ] Focus indicators
- [ ] Color contrast

**Commit**: "Improve accessibility"

### 18.5 Performance Optimization
- [ ] Lazy load messages
- [ ] Pagination for long lists
- [ ] Optimize database queries
- [ ] Add caching where appropriate
- [ ] Minimize JavaScript bundle

**Commit**: "Optimize application performance"

---

## Phase 19: Testing & Documentation

**Goal**: Comprehensive tests and docs

### 19.1 Test Coverage
- [ ] Model unit tests
- [ ] Controller tests
- [ ] Integration tests
- [ ] Channel (Action Cable) tests
- [ ] End-to-end tests
- [ ] Aim for >80% coverage

**Commit**: "Achieve comprehensive test coverage"

### 19.2 Code Documentation
- [ ] Add code comments
- [ ] Document complex methods
- [ ] API documentation
- [ ] Update README with setup instructions

**Commit**: "Add code documentation"

---

## Phase 20: Deployment Preparation

**Goal**: Ready for production deployment

### 20.1 Production Configuration
- [ ] Configure production database
- [ ] Set up Redis in production
- [ ] Configure email service (SendGrid, etc.)
- [ ] Set up cloud storage (S3)
- [ ] Environment variable management

**Commit**: "Configure production environment"

### 20.2 Security Hardening
- [ ] Review authentication security
- [ ] Add rate limiting
- [ ] Configure CORS
- [ ] Set security headers
- [ ] Review authorization logic
- [ ] Dependency security audit

**Commit**: "Security hardening for production"

### 20.3 Monitoring & Logging
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Configure logging
- [ ] Add performance monitoring
- [ ] Set up uptime monitoring

**Commit**: "Add monitoring and logging"

---

## Summary

This implementation plan provides a clear path from project setup to production-ready application. Each phase builds upon the previous one, ensuring the application remains functional throughout development.

**Total Estimated Phases**: 20
**Estimated Timeline**: 8-12 weeks for full implementation
**Key Milestones**:
- Phase 5: Basic real-time messaging working
- Phase 12: Full channel and DM functionality
- Phase 16: AI agents responding
- Phase 18: Production-ready application

Follow the acceptance criteria in [ACCEPTANCE_CRITERIA.md](./ACCEPTANCE_CRITERIA.md) to verify completion of each feature.
