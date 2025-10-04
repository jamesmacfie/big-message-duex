# Big Message - Acceptance Criteria

## Overview

This document provides a comprehensive checklist of acceptance criteria for all features in Big Message. Use this as a reference to verify feature completion during development.

---

## 1. Authentication & Authorization

### User Signup
- [ ] User can access signup page at `/signup`
- [ ] Form validates email format
- [ ] Form validates password length (minimum 8 characters)
- [ ] Form validates password confirmation match
- [ ] Duplicate email shows error message
- [ ] Successful signup sends confirmation email
- [ ] User is redirected to "check your email" page
- [ ] Confirmation email contains valid link with token

### Email Confirmation
- [ ] Clicking confirmation link activates account
- [ ] Activated users can log in
- [ ] Non-activated users cannot log in
- [ ] Error shown if token is invalid
- [ ] Resend confirmation option available

### User Login
- [ ] User can access login page at `/login`
- [ ] Valid credentials log user in
- [ ] Invalid credentials show error message
- [ ] Unconfirmed email shows appropriate error
- [ ] Successful login redirects to main app
- [ ] Session persists across page refreshes
- [ ] "Remember me" option works (if implemented)

### User Logout
- [ ] Logout button visible when logged in
- [ ] Clicking logout ends session
- [ ] User redirected to login page
- [ ] Logged out user cannot access protected pages

### Password Reset
- [ ] User can access "forgot password" page
- [ ] Form accepts email address
- [ ] Reset email sent to valid email
- [ ] Reset email contains valid link with token
- [ ] Reset link loads password reset form
- [ ] New password can be set successfully
- [ ] Old password no longer works
- [ ] New password works for login

### Authorization
- [ ] Logged out users redirected to login from all protected pages
- [ ] Users can only access channels they're members of
- [ ] Private channels hidden from non-members
- [ ] Only channel admins can edit channel settings
- [ ] Only message authors can edit their messages
- [ ] Only message authors can delete their messages

---

## 2. People & Profiles

### Person Creation
- [ ] Person automatically created on user signup
- [ ] Person associated with user (1:1)
- [ ] Default name set from email
- [ ] Person appears in people lists

### Profile Settings
- [ ] Settings page accessible from user menu
- [ ] Current name displayed in form
- [ ] Name can be updated
- [ ] Description/bio can be set
- [ ] Avatar can be uploaded
- [ ] Avatar displays as preview
- [ ] Supported image formats accepted (jpg, png, gif)
- [ ] Large files rejected with error
- [ ] Theme preference can be selected
- [ ] Save button updates profile
- [ ] Success message shown after save
- [ ] Changes reflected immediately in UI

### Profile Display
- [ ] Person name shows in message author
- [ ] Avatar shows next to messages
- [ ] Hovering over name shows profile tooltip
- [ ] Default avatar shown if none uploaded

---

## 3. Channels

### Channel Creation
- [ ] "Create Channel" button visible in sidebar
- [ ] Clicking opens modal
- [ ] Modal has name input field
- [ ] Modal has description textarea
- [ ] Modal has privacy toggle
- [ ] Name is required (validation)
- [ ] Duplicate names show error
- [ ] Successful creation closes modal
- [ ] New channel appears in sidebar
- [ ] Creator is added as admin member
- [ ] User navigated to new channel

### Channel Display
- [ ] Channel name shown in header
- [ ] Channel description shown in header
- [ ] Private channel shows lock icon
- [ ] Archived channel shows archived badge
- [ ] Channel members count displayed
- [ ] Clicking channel in sidebar opens channel view

### Channel List Sidebar
- [ ] All user's channels listed
- [ ] Channels sorted alphabetically
- [ ] Active channel highlighted
- [ ] Private channels show lock icon
- [ ] Unread channels show badge count
- [ ] Unread channels appear bold
- [ ] Empty state shown if no channels

### Channel Editing
- [ ] Edit option visible to admins only
- [ ] Clicking edit opens modal
- [ ] Modal pre-filled with current values
- [ ] Name can be updated
- [ ] Description can be updated
- [ ] Save button updates channel
- [ ] Changes reflected immediately
- [ ] Non-admins cannot access edit

### Channel Archiving
- [ ] Archive option visible to admins only
- [ ] Confirmation dialog shown
- [ ] Archived channel removed from active list
- [ ] Archived channel shows "archived" badge
- [ ] Cannot send messages in archived channel
- [ ] Can view history of archived channel

### Channel Membership
- [ ] Invite button visible in channel
- [ ] Can search for people to invite
- [ ] Invited person added to channel
- [ ] Invited person sees channel in sidebar
- [ ] Members list shows all members
- [ ] Admin badge shown for admins
- [ ] Can remove members (admin only)
- [ ] Cannot remove last admin

### Admin Management
- [ ] Promote member to admin (admin only)
- [ ] Demote admin to member (admin only)
- [ ] Cannot demote last admin
- [ ] Admin changes reflected immediately

### Channel Browsing
- [ ] Browse channels button in sidebar
- [ ] Shows all channels user is member of
- [ ] Excludes private channels not a member of
- [ ] Displays channel name and description
- [ ] Shows member count
- [ ] Can filter/search channels
- [ ] Clicking channel navigates to it

---

## 4. Direct Messages (DMs)

### DM Creation
- [ ] "New DM" button visible in sidebar
- [ ] Clicking opens person selector
- [ ] Can search for people
- [ ] Can select multiple people (group DM)
- [ ] Cannot select AI agents from regular person list
- [ ] Starting DM creates or finds existing DM
- [ ] User navigated to DM

### DM Display
- [ ] DM shows participant names in header
- [ ] Names are comma-separated
- [ ] DM shows participant avatars
- [ ] Excludes current user from name list
- [ ] Shows "(You)" if only participant

### DM List Sidebar
- [ ] DMs listed in separate section
- [ ] Sorted by most recent activity
- [ ] Shows participant names
- [ ] Shows participant avatars
- [ ] Unread DMs show badge count
- [ ] Active DM highlighted

### AI Agent DMs
- [ ] Can start DM with AI agent
- [ ] Agent listed in special section
- [ ] Agent avatar and name displayed
- [ ] Agent marked as "Bot" or "AI"

---

## 5. Messages

### Sending Messages
- [ ] Message input visible at bottom of channel
- [ ] Enter key sends message
- [ ] Shift+Enter adds new line
- [ ] Sent message appears in channel
- [ ] Message shows immediately (optimistic UI)
- [ ] Empty messages not allowed
- [ ] Message count updates
- [ ] Input cleared after send

### Message Display
- [ ] Messages sorted chronologically
- [ ] Author name shown
- [ ] Author avatar shown
- [ ] Timestamp shown
- [ ] Relative time displayed ("2 minutes ago")
- [ ] Full timestamp on hover
- [ ] Own messages have different style
- [ ] Messages grouped by author and time

### Markdown Rendering
- [ ] Bold text renders correctly (`**bold**`)
- [ ] Italic text renders correctly (`*italic*`)
- [ ] Code inline renders correctly (`` `code` ``)
- [ ] Code blocks render correctly
- [ ] Links are clickable
- [ ] Lists render correctly
- [ ] Blockquotes render correctly
- [ ] Headings render correctly
- [ ] Markdown preview available (optional)

### Message Actions Menu
- [ ] Hover over message shows action menu
- [ ] Menu shows emoji reaction button
- [ ] Menu shows reply button
- [ ] Menu shows edit button (author only)
- [ ] Menu shows delete button (author only)
- [ ] Menu disappears on mouse leave

### Message Editing
- [ ] Clicking edit shows inline editor
- [ ] Editor pre-filled with current content
- [ ] Can modify text
- [ ] Save updates message
- [ ] Cancel discards changes
- [ ] Edited message shows "edited" badge
- [ ] Edit timestamp displayed
- [ ] Non-authors cannot edit

### Message Deletion
- [ ] Clicking delete shows confirmation
- [ ] Confirming removes message
- [ ] Deleted message shows placeholder
- [ ] Placeholder says "Message deleted"
- [ ] Author name still visible (optional)
- [ ] Non-authors cannot delete

---

## 6. Real-time Updates

### Message Broadcasting
- [ ] New messages appear without refresh
- [ ] Messages from other users appear instantly
- [ ] Messages appear within 1 second
- [ ] Works across multiple browser tabs
- [ ] Works across multiple users

### Auto-scroll Behavior
- [ ] New messages auto-scroll if at bottom
- [ ] No auto-scroll if scrolled up
- [ ] "New messages" indicator shown when scrolled up
- [ ] Clicking indicator scrolls to bottom
- [ ] Auto-scroll smooth and not jarring

### Connection Status
- [ ] Connection indicator shown
- [ ] Shows "connected" when active
- [ ] Shows "disconnected" when connection lost
- [ ] Attempts reconnection automatically
- [ ] Messages queued when disconnected (optional)

---

## 7. Threads

### Thread Creation
- [ ] "Reply" button visible in message menu
- [ ] Clicking reply opens thread panel
- [ ] Thread panel slides in from right
- [ ] Parent message shown at top of panel
- [ ] Reply input at bottom of panel
- [ ] Can send replies
- [ ] Replies appear in thread panel

### Thread Display
- [ ] All replies shown chronologically
- [ ] Reply authors and timestamps shown
- [ ] Replies use same UI as regular messages
- [ ] Scroll within thread panel
- [ ] Thread panel closable

### Thread Indicators
- [ ] Reply count shown under parent message
- [ ] Shows "1 reply" or "X replies"
- [ ] Shows snippet of latest reply
- [ ] Shows avatars of repliers
- [ ] Clicking indicator opens thread panel
- [ ] Unread reply indicator (optional)

### Thread Real-time
- [ ] New replies appear instantly in panel
- [ ] Reply count updates in real-time
- [ ] Latest reply snippet updates
- [ ] Works when panel not open

---

## 8. Emoji Reactions

### Adding Reactions
- [ ] Emoji button in message menu
- [ ] Clicking shows emoji picker
- [ ] Selecting emoji adds reaction
- [ ] Reaction appears under message
- [ ] Can add multiple different emojis
- [ ] Cannot add same emoji twice (toggles)

### Reaction Display
- [ ] Reactions shown below message
- [ ] Only shown if message has reactions
- [ ] Grouped by emoji type
- [ ] Shows count for each emoji
- [ ] Current user's reactions highlighted
- [ ] Hover shows who reacted

### Removing Reactions
- [ ] Clicking same emoji removes reaction
- [ ] Reaction disappears immediately
- [ ] Count decrements
- [ ] Reaction group removed if count reaches 0

### Reaction Real-time
- [ ] New reactions appear instantly
- [ ] Removed reactions disappear instantly
- [ ] Counts update in real-time
- [ ] Works across multiple users

---

## 9. Favorites

### Favoriting Channels
- [ ] Star icon in channel menu
- [ ] Clicking star adds to favorites
- [ ] Star filled when favorited
- [ ] Clicking again removes favorite
- [ ] Works for both channels and DMs

### Favorites List
- [ ] Favorites section in sidebar
- [ ] Shows all favorited channels/DMs
- [ ] Sorted alphabetically
- [ ] Active favorite highlighted
- [ ] Empty state if no favorites

### Favorite Persistence
- [ ] Favorites persist across sessions
- [ ] Favorites sync across tabs
- [ ] Removing favorite updates sidebar immediately

---

## 10. Unread Tracking

### Unread Counts
- [ ] Badge shows unread count on channels
- [ ] Badge shows unread count on DMs
- [ ] Count only includes top-level messages
- [ ] Count excludes thread replies
- [ ] Count updates in real-time
- [ ] Count cleared when viewing channel

### Unread Indicators
- [ ] Channel name bold if unread
- [ ] Badge shows number (e.g., "5")
- [ ] Badge hidden if count is 0
- [ ] Different color for mentions (optional)

### Marking as Read
- [ ] Scrolling to bottom marks as read
- [ ] Count clears immediately
- [ ] Bold text returns to normal
- [ ] Timestamp updated on server

---

## 11. Typing Indicators

### Typing Detection
- [ ] Typing in message input triggers indicator
- [ ] Indicator sent to other channel members
- [ ] Throttled to avoid excessive updates
- [ ] Cleared when message sent
- [ ] Cleared after timeout (5 seconds)

### Typing Display
- [ ] Shows "X is typing..." below message list
- [ ] Shows multiple people: "X and Y are typing..."
- [ ] Does not show own typing indicator
- [ ] Animates (e.g., dots animation)
- [ ] Updates in real-time

### AI Agent Typing
- [ ] Shows "Agent is thinking..." for AI
- [ ] Different style/icon for agents
- [ ] Shown during AI processing
- [ ] Cleared when AI responds

---

## 12. Mentions

### Mention Input
- [ ] Typing @ shows autocomplete
- [ ] Lists people in current channel
- [ ] Filters as user types
- [ ] Arrow keys navigate suggestions
- [ ] Enter selects person
- [ ] Escape closes autocomplete

### Mention Display
- [ ] Mentions highlighted in message
- [ ] Mentions are clickable
- [ ] Clicking mention shows profile
- [ ] Own mentions use different color
- [ ] Mentions render in markdown

### Mention Notifications
- [ ] User receives notification when mentioned
- [ ] Notification shows who mentioned them
- [ ] Notification shows message preview
- [ ] Clicking notification navigates to message
- [ ] Unread mention indicator shown
- [ ] Can mark mention as read

---

## 13. Attachments

### File Upload
- [ ] Upload button visible in message input
- [ ] Clicking opens file picker
- [ ] Can select multiple files
- [ ] Shows upload progress
- [ ] Files attached to message
- [ ] Supported formats accepted
- [ ] Unsupported formats rejected
- [ ] Size limit enforced (e.g., 10MB)

### Image Attachments
- [ ] Images display inline
- [ ] Thumbnails generated
- [ ] Clicking opens full size
- [ ] Full size shown in modal/overlay
- [ ] Multiple images in grid layout

### Video Attachments
- [ ] Videos display inline player
- [ ] Play/pause controls visible
- [ ] Volume control available
- [ ] Can view full screen

### Document Attachments
- [ ] Documents show download link
- [ ] Shows file name and size
- [ ] Shows appropriate icon (PDF, DOC, etc.)
- [ ] Clicking downloads file

### Attachment Management
- [ ] Can remove attachment before sending
- [ ] Can download attachment
- [ ] Attachment metadata stored
- [ ] Virus scanning (if implemented)

---

## 14. Slash Commands

### Command Detection
- [ ] Messages starting with `/` detected as commands
- [ ] Command parsed correctly
- [ ] Invalid commands show error
- [ ] Command help available (`/help`)

### /gif Command
- [ ] `/gif search term` searches Giphy
- [ ] Returns relevant GIF
- [ ] GIF posted as message attachment
- [ ] Shows preview before sending (optional)
- [ ] Handles no results gracefully
- [ ] Handles API errors
- [ ] Rate limiting respected

---

## 15. AI Agents

### Agent Creation
- [ ] "Create Agent" option available
- [ ] Form has name input
- [ ] Form has description input
- [ ] Form has system prompt textarea
- [ ] Form has avatar upload
- [ ] Agent created successfully
- [ ] Agent appears in agent list

### Agent Management
- [ ] List of user's agents shown
- [ ] Can edit agent settings
- [ ] Can update prompt
- [ ] Can update avatar
- [ ] Can delete/deactivate agent
- [ ] Changes saved successfully

### Agent Behavior
- [ ] Agent only responds in DMs
- [ ] Agent does not respond in channels
- [ ] Agent responds to every DM message
- [ ] Response uses OpenAI GPT-5
- [ ] Response relevant to conversation
- [ ] Conversation history included in context
- [ ] Shows typing indicator while processing
- [ ] Response appears as message from agent

### Prebuilt Agents
- [ ] Helpful Assistant available
- [ ] Code Reviewer available
- [ ] Creative Writer available
- [ ] Data Analyst available
- [ ] Product Manager available
- [ ] Each agent has appropriate prompt
- [ ] Each agent has distinct avatar
- [ ] Agents work correctly in DMs

### Error Handling
- [ ] OpenAI API errors handled gracefully
- [ ] Timeout handled (max 30 seconds)
- [ ] Error message shown to user
- [ ] Agent typing indicator cleared on error
- [ ] Can retry on error

---

## 16. Search

### Search Input
- [ ] Search bar visible at top of sidebar
- [ ] Placeholder text shown
- [ ] Focus on search bar works
- [ ] Can type search query
- [ ] Results shown as user types

### Search Results
- [ ] Results grouped by type (channels, DMs, messages)
- [ ] Shows top N results per type
- [ ] Highlights matching text
- [ ] Shows context snippet for messages
- [ ] Ranked by relevance
- [ ] Results update as user types
- [ ] Debounced to avoid excessive queries

### Search Navigation
- [ ] Arrow keys navigate results
- [ ] Enter opens selected result
- [ ] Click opens result
- [ ] Clicking result navigates to channel/message
- [ ] Search highlights message (if message result)
- [ ] Escape closes search results

### Search Scope
- [ ] Only searches accessible channels
- [ ] Excludes private channels user is not in
- [ ] Excludes deleted messages
- [ ] Includes threads (optional)
- [ ] Case-insensitive search
- [ ] Fuzzy matching (optional)

---

## 17. Invites

### Sending Invites
- [ ] Invite option in menu
- [ ] Form has email input
- [ ] Email validation
- [ ] Invite email sent
- [ ] Email contains invite link
- [ ] Link includes unique token
- [ ] Previous invites archived

### Invite Acceptance
- [ ] Clicking link loads signup
- [ ] Email pre-filled from invite
- [ ] Completing signup accepts invite
- [ ] User auto-logged in
- [ ] Invite marked as accepted
- [ ] Cannot use same invite twice

### Invite Management
- [ ] Can view sent invites
- [ ] Shows invite status (pending/accepted)
- [ ] Shows sent date
- [ ] Can resend invite
- [ ] Can revoke invite (optional)

---

## 18. UI/UX

### Layout
- [ ] Left sidebar always visible
- [ ] Main content area responsive
- [ ] Thread panel slides over on mobile
- [ ] Top navigation always visible
- [ ] Footer visible (if applicable)

### Responsive Design
- [ ] Works on mobile (320px+)
- [ ] Works on tablet (768px+)
- [ ] Works on desktop (1024px+)
- [ ] Sidebar collapsible on mobile
- [ ] Touch-friendly buttons
- [ ] Readable text sizes

### Theme Support
- [ ] Light theme available
- [ ] Dark theme available
- [ ] Theme toggle in settings
- [ ] Theme persists across sessions
- [ ] Smooth theme transition
- [ ] All components support both themes

### Loading States
- [ ] Spinner shown during API calls
- [ ] Skeleton screens for lists
- [ ] Progress bars for uploads
- [ ] Buttons disabled during actions
- [ ] Loading overlay for modals

### Error States
- [ ] Form validation errors shown
- [ ] API errors shown as toast/alert
- [ ] Network errors handled
- [ ] Empty states for lists
- [ ] 404 page for missing resources
- [ ] 403 page for unauthorized access

### Accessibility
- [ ] All interactive elements keyboard navigable
- [ ] Tab order logical
- [ ] Focus indicators visible
- [ ] ARIA labels present
- [ ] Screen reader friendly
- [ ] Color contrast meets WCAG AA
- [ ] Alt text for images

---

## 19. Performance

### Load Times
- [ ] Initial page load < 3 seconds
- [ ] Channel switch < 500ms
- [ ] Message send < 1 second
- [ ] Search results < 500ms

### Message Pagination
- [ ] Initial load shows recent 50 messages
- [ ] Scrolling up loads older messages
- [ ] Lazy loading smooth
- [ ] No duplicate messages
- [ ] Maintains scroll position

### Optimization
- [ ] Images lazy loaded
- [ ] Thumbnails used where appropriate
- [ ] Database queries optimized
- [ ] N+1 queries eliminated
- [ ] Proper indexes on all queries
- [ ] Caching for frequently accessed data

---

## 20. Security

### Authentication Security
- [ ] Passwords hashed with bcrypt
- [ ] Minimum password length enforced
- [ ] Session tokens secure
- [ ] Session timeout configured
- [ ] CSRF protection enabled
- [ ] Rate limiting on auth endpoints

### Authorization Security
- [ ] All actions authorized on server
- [ ] Client-side checks supplementary only
- [ ] Channel access verified
- [ ] Private channel access restricted
- [ ] Admin actions verified
- [ ] Message edit/delete verified

### Data Security
- [ ] SQL injection prevented
- [ ] XSS prevented
- [ ] File upload validation
- [ ] File type validation
- [ ] File size limits
- [ ] No secrets in client-side code
- [ ] Environment variables for API keys
- [ ] HTTPS enforced (production)

---

## 21. Development Environment

### Setup
- [ ] `docker-compose up` starts services
- [ ] PostgreSQL accessible
- [ ] Redis accessible
- [ ] `.env.sample` exists with all vars
- [ ] `.env` created from sample
- [ ] `bundle install` succeeds
- [ ] `rails db:create` succeeds
- [ ] `rails db:migrate` succeeds
- [ ] `rails db:seed` succeeds

### Development Server
- [ ] `rails server` starts successfully
- [ ] Application accessible at localhost
- [ ] Action Cable connects
- [ ] Hot reloading works (if configured)
- [ ] No errors in console on startup

### External APIs
- [ ] OpenAI API configured
- [ ] Giphy API configured
- [ ] API keys loaded from env
- [ ] APIs accessible from app
- [ ] Error handling for API failures

---

## 22. Testing

### Test Coverage
- [ ] All models have tests
- [ ] All controllers have tests
- [ ] Integration tests cover key flows
- [ ] Channel (Action Cable) tests
- [ ] Test coverage > 80%

### Test Execution
- [ ] `rails test` (or `rspec`) runs all tests
- [ ] All tests pass
- [ ] Tests run in < 5 minutes
- [ ] CI/CD configured (optional)

---

## Completion Checklist

Use this high-level checklist to track overall feature completion:

- [ ] Authentication & Authorization complete
- [ ] People & Profiles complete
- [ ] Channels complete
- [ ] Direct Messages complete
- [ ] Messages complete
- [ ] Real-time Updates complete
- [ ] Threads complete
- [ ] Emoji Reactions complete
- [ ] Favorites complete
- [ ] Unread Tracking complete
- [ ] Typing Indicators complete
- [ ] Mentions complete
- [ ] Attachments complete
- [ ] Slash Commands complete
- [ ] AI Agents complete
- [ ] Search complete
- [ ] Invites complete
- [ ] UI/UX polished
- [ ] Performance optimized
- [ ] Security hardened
- [ ] Tests passing
- [ ] Documentation complete
- [ ] Ready for deployment

---

**Status**: Not Started
**Last Updated**: 2025-10-04

Refer to [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) for the development roadmap.
