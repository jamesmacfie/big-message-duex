# Big Message - Detailed Requirements

## 1. Authentication & User Management

### 1.1 Email Authentication
- Users sign up with email and password
- Email validation required before account activation
- Email confirmation link sent on signup
- Login with email and password only
- Password reset via email
- Session management
- One user per email address

### 1.2 People (Profiles)
- Each user has exactly one person profile
- Person attributes:
  - Name (display name)
  - Description/bio
  - Avatar (image upload)
  - Theme preference
- Profile editing via settings page
- All user actions are performed as their person

### 1.3 Invite System
- Users can invite others via email
- Invite contains unique token/link
- Invites never expire
- When a new invite is created for same email, previous invites are archived
- Track invite status: pending, accepted, archived
- Track who sent the invite and when

## 2. Channels

### 2.1 Channel Core Features
- Channel name (unique within workspace)
- Channel description (optional)
- Channel type: `channel` or `dm`
- Public or private visibility
- Created timestamp and creator
- Archived status (soft delete)
- Channels are never hard deleted

### 2.2 Channel Membership
- Members can join/be invited to channels
- Members have roles: admin or member
- Channel admins can:
  - Edit channel name and description
  - Archive the channel
  - Manage other admins (promote/demote)
  - Invite/remove members
- Track member metadata:
  - Last viewed timestamp (for unread counts)
  - Typing indicator timestamp
  - Favorite status

### 2.3 Channel Management UI
- Create channel modal:
  - Name input
  - Description input
  - Privacy toggle (public/private)
  - Initial member selection
- Edit channel modal (admins only):
  - Update name and description
  - Manage members
  - Manage admins
  - Archive channel option
- Channel menu (right-click or ellipsis):
  - Edit (if admin)
  - Archive (if admin)
  - Add to favorites
  - Remove from favorites
  - View members
  - Invite people

### 2.4 Channel Browsing
- Browse all channels user is a member of
- Cannot browse private channels unless member
- Show channel name, description, member count
- Join/leave functionality
- Filter/search channels

## 3. Direct Messages (DMs)

### 3.1 DM Features
- DMs are a type of channel with `type: 'dm'`
- Can include multiple people (group DMs)
- Can include AI agents
- DM name is comma-separated list of participant names
- No admin concept for DMs
- Cannot be archived by users

### 3.2 AI Agents in DMs
- AI agents can be added to DMs
- Agents respond to all messages in DM
- Show typing indicator when agent is processing
- Use OpenAI GPT-5 for responses
- Agent processing is async via pub/sub
- Agents only respond in DMs (not channels)

## 4. Messages

### 4.1 Message Core
- Author (person who sent it)
- Content (text, markdown)
- Channel/DM it belongs to
- Timestamp
- Parent message (if reply in thread)
- Edited status and timestamp
- Deleted status (soft delete)

### 4.2 Message Content
- Plain text with markdown formatting
- Support for:
  - Bold, italic, code
  - Links
  - Lists
  - Blockquotes
  - Code blocks
- Render markdown in UI

### 4.3 Message Actions
- Hover menu shows:
  - Add emoji reaction
  - Reply in thread
  - Edit (author only)
  - Delete (author only)
- Edit message:
  - Author only
  - Show "edited" indicator
  - Track edit timestamp
- Delete message:
  - Soft delete
  - Show "message deleted" placeholder

### 4.4 Slash Commands
- Messages starting with `/` are slash commands
- `/gif <search term>`:
  - Search Giphy API
  - Return GIF as message attachment
  - Use Giphy API key from env

## 5. Threads

### 5.1 Thread Features
- Any message can have replies
- Replies are shown in right-side panel (like Slack)
- Parent message shows reply count indicator
- Thread panel shows:
  - Original message at top
  - All replies chronologically
  - Reply input at bottom
- Thread panel is closable
- Multiple threads can't be open simultaneously

### 5.2 Thread Indicators
- Show reply count below parent message in channel
- Show snippet of latest reply
- Highlight if user has unread replies
- Click to open thread panel

## 6. Emoji Reactions

### 6.1 Reaction Features
- Add emoji reaction to any message
- Multiple users can use same emoji (shows count)
- User can only add each emoji once per message
- Remove reaction by clicking again
- Show reaction picker on message hover menu
- Standard emoji only (no custom emojis yet)

### 6.2 Reaction Display
- Only show if message has reactions
- Group same emoji together with count
- Show who reacted on hover
- Highlight if current user reacted

## 7. AI Agents

### 7.1 Agent Creation
- Any user can create an agent
- Agent attributes:
  - Name
  - Avatar
  - Description
  - System prompt (defines behavior)
  - is_agent flag
- Agents appear in people list
- Agents can be added to DMs

### 7.2 Agent Behavior
- Only responds in DMs
- Responds to every message in DM they're in
- Use OpenAI GPT-5 API
- Include conversation history in context
- Show typing indicator while processing
- Processing is async via Action Cable pub/sub
- Handle API errors gracefully

### 7.3 Prebuilt Agents
- Seed database with several agents:
  - Helpful Assistant (general help)
  - Code Reviewer (technical feedback)
  - Creative Writer (creative assistance)
  - Data Analyst (data insights)
  - Product Manager (product questions)

## 8. Real-time Features

### 8.1 Action Cable Integration
- WebSocket connection per user
- Subscribe to channels user is member of
- Broadcast new messages to all channel subscribers
- Broadcast typing indicators
- Broadcast presence updates
- Use Redis adapter for pub/sub

### 8.2 Message Broadcasting
- When message created, broadcast to channel
- All connected users receive immediately
- Update UI without page reload
- Maintain scroll position (unless at bottom)
- Auto-scroll if user at bottom of messages

### 8.3 Typing Indicators
- Track when user is typing
- Update member's typing timestamp
- Broadcast to other channel members
- Show "<person> is typing..." in channel
- Clear after timeout or message sent
- AI agents show "is thinking..." when processing

## 9. Favorites

### 9.1 Favorite Features
- Users can favorite channels and DMs
- Favorites appear in dedicated section in sidebar
- Favorite action in channel menu
- Unfavorite action in channel menu
- Persist favorite status per user per channel

## 10. Sidebar

### 10.1 Layout
- Left sidebar with sections:
  - Search bar at top
  - Favorites section
  - Channels section
  - Direct Messages section
- Each section collapsible
- Channels show name only
- DMs show comma-separated participant names

### 10.2 Unread Indicators
- Show unread count badge on channels/DMs with unreads
- Bold channel/DM name if has unreads
- Clear unreads when user views channel and scrolls to bottom

### 10.3 Channel Actions
- Click to open channel
- Right-click or menu for options
- Create new channel button
- Create new DM button
- Browse channels button

## 11. Unread Tracking

### 11.1 Tracking Mechanism
- Store last_viewed_at timestamp on member record
- When user scrolls to bottom, update last_viewed_at
- Unread count = messages created after last_viewed_at
- Only count top-level messages (not thread replies)
- Thread replies have separate unread logic

### 11.2 Auto-scroll Behavior
- If user scrolled to bottom, new messages auto-scroll
- If user scrolled up, no auto-scroll (show "new messages" indicator)
- Detect scroll position in channel view
- Update last_viewed_at when at bottom and messages appear

## 12. Mentions

### 12.1 Mention Features
- Use @ symbol followed by person name
- Auto-complete people in current channel
- Render as highlighted/linked in message
- Mentioned users receive notification/alert
- Track mentions per user
- Show mention indicator in UI

## 13. Attachments

### 13.1 Attachment Features
- Messages can have multiple attachments
- Support file uploads
- Attachment attributes:
  - Filename
  - File size
  - MIME type
  - Storage URL
- Render based on type:
  - Images: inline preview
  - Videos: video player
  - Documents: download link with icon
  - Other: generic download link

### 13.2 Attachment Handling
- Use Active Storage for file uploads
- Store in cloud storage (S3 compatible)
- Generate thumbnails for images
- Size limits on uploads
- Virus scanning (if needed)

## 14. Search

### 14.1 Search Features
- Search bar at top of sidebar
- Fuzzy search algorithm
- Search across:
  - Channel names
  - DM participant names
  - Message content
- Only search content user has access to
- Rank results by relevance
- Show results grouped by type

### 14.2 Search UI
- Search input with icon
- Dropdown results as user types
- Click result to navigate
- Show preview snippet
- Keyboard navigation

## 15. Settings

### 15.1 User Settings
- Settings page accessible from user menu
- Editable fields:
  - Display name
  - Avatar upload
  - Email (with re-verification)
  - Password change
  - Theme preference (light/dark)
  - Notification preferences
- Save button
- Cancel button

## 16. UI/UX Requirements

### 16.1 Design System
- Slack-like interface
- Tailwind CSS for styling
- Responsive design
- Consistent spacing and typography
- Color scheme for light/dark themes

### 16.2 Key UI Components
- Left sidebar (channels/DMs)
- Main channel view (messages)
- Right thread panel (threads)
- Top navigation (search, settings, user menu)
- Modals (create/edit channel, settings)
- Message composer (bottom of channel)
- Emoji picker
- File upload dropzone

### 16.3 Accessibility
- Keyboard navigation
- Screen reader support
- Focus indicators
- Color contrast compliance
- ARIA labels

## 17. Performance Requirements

### 17.1 Real-time Performance
- Messages delivered in <1 second
- Typing indicators update in real-time
- Smooth scrolling with many messages
- Efficient message pagination
- Lazy load older messages

### 17.2 Scalability
- Support 100+ channels per user
- Support 1000+ messages per channel
- Efficient database queries with indexes
- Cache frequently accessed data
- Background jobs for heavy operations

## 18. Security Requirements

### 18.1 Authentication Security
- Secure password hashing (bcrypt)
- Email verification required
- Session timeout
- CSRF protection
- Rate limiting on auth endpoints

### 18.2 Authorization
- Users only see channels they're members of
- Private channels hidden from non-members
- Channel admins enforced on server
- Message editing/deletion enforced
- API authentication required

### 18.3 Data Security
- SQL injection prevention
- XSS prevention
- Secure file upload validation
- Environment variables for secrets
- HTTPS in production

## 19. External API Integration

### 19.1 OpenAI API
- Use GPT-5 model
- API key from environment variable
- Handle rate limits
- Handle API errors
- Timeout handling
- Conversation context management

### 19.2 Giphy API
- API key from environment variable
- Search endpoint
- Return appropriate GIF
- Handle API errors
- Rate limiting

## 20. Development Environment

### 20.1 Docker Compose
- PostgreSQL container
- Redis container
- Environment variables
- Volume mounts for data persistence
- Easy setup for new developers

### 20.2 Environment Variables
- `.env.sample` with all required vars
- `.env` for local development (gitignored)
- Required variables:
  - `DATABASE_URL`
  - `REDIS_URL`
  - `OPENAI_API_KEY`
  - `GIPHY_API_KEY`
  - `SECRET_KEY_BASE`

## 21. Testing Requirements

### 21.1 Test Coverage
- Model tests (validations, associations)
- Controller tests (authorization, actions)
- Integration tests (user flows)
- Channel tests (real-time functionality)
- API tests (external integrations)

### 21.2 Test Data
- Factories for all models
- Seed data for development
- Test fixtures
- Prebuilt agents in seeds
