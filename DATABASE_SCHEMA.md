# Big Message - Database Schema

## Overview

This document describes the complete database schema for Big Message. The schema separates authentication (Users) from identity (People) to allow for flexibility and support AI agents.

## Entity Relationship Diagram

```
Users (1) -------- (1) People
  |
  |-- (many) Invites (sent)
  |-- (many) Favorites
  |-- (many) Members

People (many) -------- (many) Channels (through Members)
  |
  |-- (many) Messages (authored)
  |-- (many) Reactions

Channels
  |-- (many) Members
  |-- (many) Messages

Messages
  |-- (many) Reactions
  |-- (many) Attachments
  |-- (many) Mentions
  |-- (1) Parent Message (for threads)
  |-- (many) Replies (child messages)
```

## Tables

### users
Authentication and account management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| email | string | NOT NULL, unique, indexed | User's email address |
| password_digest | string | NOT NULL | Encrypted password (bcrypt) |
| email_confirmed_at | timestamp | nullable | When email was confirmed |
| email_confirmation_token | string | nullable, indexed | Token for email confirmation |
| email_confirmation_sent_at | timestamp | nullable | When confirmation email was sent |
| reset_password_token | string | nullable, indexed | Token for password reset |
| reset_password_sent_at | timestamp | nullable | When reset email was sent |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_users_on_email` (unique)
- `index_users_on_email_confirmation_token` (unique)
- `index_users_on_reset_password_token` (unique)

**Validations:**
- Email must be present, unique, valid format
- Password must be minimum 8 characters

---

### people
User profiles and AI agents.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| user_id | bigint | nullable, FK users(id), indexed | Associated user (null for AI agents) |
| name | string | NOT NULL | Display name |
| description | text | nullable | Bio or agent prompt |
| avatar_url | string | nullable | Avatar image URL |
| theme | string | nullable, default: 'light' | UI theme preference |
| is_agent | boolean | NOT NULL, default: false, indexed | Whether this is an AI agent |
| agent_prompt | text | nullable | System prompt for AI agents |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_people_on_user_id` (unique where user_id is not null)
- `index_people_on_is_agent`

**Validations:**
- Name must be present
- If is_agent is true, user_id must be null
- If is_agent is true, agent_prompt should be present

**Storage:**
- Avatar uses Active Storage (has_one_attached :avatar)

---

### invites
Invitation system for new users.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| email | string | NOT NULL, indexed | Invited email address |
| token | string | NOT NULL, unique, indexed | Unique invitation token |
| invited_by_id | bigint | NOT NULL, FK people(id) | Person who sent invite |
| status | string | NOT NULL, default: 'pending' | pending, accepted, archived |
| accepted_at | timestamp | nullable | When invite was accepted |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_invites_on_email`
- `index_invites_on_token` (unique)
- `index_invites_on_invited_by_id`
- `index_invites_on_status`

**Validations:**
- Email must be present, valid format
- Token must be present, unique
- Status must be one of: pending, accepted, archived

---

### channels
Communication channels and DMs.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| name | string | NOT NULL, indexed | Channel name or computed DM name |
| description | text | nullable | Channel description |
| channel_type | string | NOT NULL, default: 'channel' | 'channel' or 'dm' |
| is_private | boolean | NOT NULL, default: false | Private vs public channel |
| archived_at | timestamp | nullable, indexed | When channel was archived |
| created_by_id | bigint | NOT NULL, FK people(id) | Person who created channel |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_channels_on_name`
- `index_channels_on_channel_type`
- `index_channels_on_archived_at`
- `index_channels_on_created_by_id`

**Validations:**
- Name must be present
- Channel type must be 'channel' or 'dm'

**Scopes:**
- `active` - where archived_at is null
- `archived` - where archived_at is not null
- `channels` - where channel_type = 'channel'
- `dms` - where channel_type = 'dm'

---

### members
Join table for people and channels with metadata.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| person_id | bigint | NOT NULL, FK people(id), indexed | Member person |
| channel_id | bigint | NOT NULL, FK channels(id), indexed | Channel |
| role | string | NOT NULL, default: 'member' | 'admin' or 'member' |
| last_viewed_at | timestamp | nullable | Last time viewed channel (for unreads) |
| typing_at | timestamp | nullable | Last typing indicator timestamp |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_members_on_person_id`
- `index_members_on_channel_id`
- `index_members_on_person_id_and_channel_id` (unique)
- `index_members_on_role`

**Validations:**
- Person must exist
- Channel must exist
- Role must be 'admin' or 'member'
- Unique combination of person_id and channel_id

---

### messages
Messages in channels and DMs.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| channel_id | bigint | NOT NULL, FK channels(id), indexed | Channel message belongs to |
| person_id | bigint | NOT NULL, FK people(id), indexed | Author of message |
| parent_message_id | bigint | nullable, FK messages(id), indexed | Parent message (for threads) |
| content | text | NOT NULL | Message content (markdown) |
| edited_at | timestamp | nullable | When message was last edited |
| deleted_at | timestamp | nullable, indexed | Soft delete timestamp |
| created_at | timestamp | NOT NULL, indexed | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_messages_on_channel_id`
- `index_messages_on_person_id`
- `index_messages_on_parent_message_id`
- `index_messages_on_deleted_at`
- `index_messages_on_created_at`
- `index_messages_on_channel_id_and_created_at` (composite for pagination)

**Validations:**
- Channel must exist
- Person must exist
- Content must be present

**Scopes:**
- `active` - where deleted_at is null
- `top_level` - where parent_message_id is null
- `replies` - where parent_message_id is not null

**Full Text Search:**
- Add full-text search index on content for PostgreSQL

---

### reactions
Emoji reactions to messages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| message_id | bigint | NOT NULL, FK messages(id), indexed | Message being reacted to |
| person_id | bigint | NOT NULL, FK people(id), indexed | Person who reacted |
| emoji | string | NOT NULL | Emoji character/code |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_reactions_on_message_id`
- `index_reactions_on_person_id`
- `index_reactions_on_message_id_and_person_id_and_emoji` (unique)

**Validations:**
- Message must exist
- Person must exist
- Emoji must be present
- Unique combination of message_id, person_id, and emoji

---

### attachments
File attachments for messages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| message_id | bigint | NOT NULL, FK messages(id), indexed | Message attachment belongs to |
| filename | string | NOT NULL | Original filename |
| content_type | string | NOT NULL | MIME type |
| file_size | bigint | NOT NULL | Size in bytes |
| url | string | NOT NULL | Storage URL or Active Storage key |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_attachments_on_message_id`

**Validations:**
- Message must exist
- Filename must be present
- Content type must be present
- File size must be positive

**Storage:**
- Uses Active Storage (has_one_attached :file)

---

### mentions
@mentions in messages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| message_id | bigint | NOT NULL, FK messages(id), indexed | Message containing mention |
| person_id | bigint | NOT NULL, FK people(id), indexed | Person being mentioned |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_mentions_on_message_id`
- `index_mentions_on_person_id`
- `index_mentions_on_message_id_and_person_id` (unique)

**Validations:**
- Message must exist
- Person must exist
- Unique combination of message_id and person_id

---

### favorites
User's favorited channels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Primary key |
| user_id | bigint | NOT NULL, FK users(id), indexed | User who favorited |
| channel_id | bigint | NOT NULL, FK channels(id), indexed | Favorited channel |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- `index_favorites_on_user_id`
- `index_favorites_on_channel_id`
- `index_favorites_on_user_id_and_channel_id` (unique)

**Validations:**
- User must exist
- Channel must exist
- Unique combination of user_id and channel_id

---

## Active Storage Tables

Rails Active Storage will create these tables automatically:

### active_storage_blobs
Stores file metadata for uploaded files.

### active_storage_attachments
Links blobs to models (people.avatar, attachments.file).

### active_storage_variant_records
Stores image variant metadata.

---

## Key Relationships

### User → Person (1:1)
- One user has one person profile
- AI agents are people without users

### Person → Messages (1:many)
- A person authors many messages

### Person → Channels (many:many through Members)
- People can be members of many channels
- Channels have many member people

### Channel → Messages (1:many)
- A channel contains many messages

### Message → Message (self-referential for threads)
- A message can have a parent message
- A message can have many reply messages

### Message → Reactions (1:many)
- A message can have many reactions

### Message → Attachments (1:many)
- A message can have many attachments

### Message → Mentions (1:many)
- A message can mention many people

### User → Favorites (1:many)
- A user can favorite many channels

---

## Database Considerations

### Performance
- All foreign keys should have indexes
- Composite indexes for common query patterns
- Full-text search index on messages.content
- Partial indexes for deleted_at and archived_at

### Data Integrity
- Foreign key constraints enforced at DB level
- NOT NULL constraints where appropriate
- Unique constraints for business rules
- Check constraints for enums (if supported)

### Scalability
- Consider partitioning messages table by created_at
- Consider archiving old messages
- Use connection pooling
- Read replicas for heavy read operations

### Backup & Recovery
- Regular automated backups
- Point-in-time recovery enabled
- Test restore procedures

---

## Migration Strategy

Migrations will be created in phases:

### Phase 1: Core Auth & Users
- users
- people
- invites

### Phase 2: Channels
- channels
- members

### Phase 3: Messages
- messages
- attachments

### Phase 4: Interactions
- reactions
- mentions
- favorites

### Phase 5: Indexes & Optimizations
- Add all indexes
- Add full-text search
- Performance tuning

---

## Sample Queries

### Get all channels for a user
```sql
SELECT channels.*
FROM channels
INNER JOIN members ON members.channel_id = channels.id
INNER JOIN people ON people.id = members.person_id
WHERE people.user_id = ? AND channels.archived_at IS NULL
ORDER BY channels.name;
```

### Get unread message count for a channel
```sql
SELECT COUNT(*)
FROM messages
WHERE channel_id = ?
  AND parent_message_id IS NULL
  AND deleted_at IS NULL
  AND created_at > (
    SELECT last_viewed_at
    FROM members
    WHERE channel_id = ? AND person_id = ?
  );
```

### Get messages with reactions and reply counts
```sql
SELECT
  messages.*,
  COUNT(DISTINCT reactions.id) as reaction_count,
  COUNT(DISTINCT replies.id) as reply_count
FROM messages
LEFT JOIN reactions ON reactions.message_id = messages.id
LEFT JOIN messages replies ON replies.parent_message_id = messages.id
WHERE messages.channel_id = ?
  AND messages.parent_message_id IS NULL
  AND messages.deleted_at IS NULL
GROUP BY messages.id
ORDER BY messages.created_at DESC
LIMIT 50;
```

### Search messages
```sql
SELECT messages.*, channels.name as channel_name
FROM messages
INNER JOIN channels ON channels.id = messages.channel_id
INNER JOIN members ON members.channel_id = channels.id
WHERE members.person_id = ?
  AND messages.deleted_at IS NULL
  AND messages.content ILIKE '%' || ? || '%'
ORDER BY messages.created_at DESC
LIMIT 20;
```
