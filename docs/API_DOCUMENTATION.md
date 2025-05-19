# Tatlı Sözlük API Documentation

This document describes the Firebase Firestore collections and structure used in the Tatlı Sözlük application.

## Database Structure

### Users Collection

**Collection**: `users`

| Field           | Type     | Description                           |
|-----------------|----------|---------------------------------------|
| `uid`           | String   | Unique user identifier                |
| `username`      | String   | User's display name                   |
| `email`         | String   | User's email address                  |
| `photoURL`      | String   | URL to user's profile image           |
| `bio`           | String   | User's biography                      |
| `createdAt`     | Timestamp| Account creation timestamp            |
| `followersCount`| Number   | Number of followers                   |
| `followingCount`| Number   | Number of users being followed        |
| `entryCount`    | Number   | Number of entries created             |

### Entries Collection

**Collection**: `entries`

| Field           | Type     | Description                           |
|-----------------|----------|---------------------------------------|
| `id`            | String   | Unique entry identifier               |
| `title`         | String   | Entry title/topic                     |
| `description`   | String   | Entry content                         |
| `authorId`      | String   | Author's user ID                      |
| `createdAt`     | Timestamp| Entry creation timestamp              |
| `updatedAt`     | Timestamp| Last update timestamp                 |
| `likeCount`     | Number   | Number of likes                       |
| `commentCount`  | Number   | Number of comments                    |
| `likedBy`       | Array    | Array of user IDs who liked the entry |
| `tags`          | Array    | Topic tags                            |

### Comments Collection

**Collection**: `entries/{entryId}/comments`

| Field           | Type     | Description                           |
|-----------------|----------|---------------------------------------|
| `id`            | String   | Unique comment identifier             |
| `entryId`       | String   | Parent entry ID                       |
| `authorId`      | String   | Author's user ID                      |
| `content`       | String   | Comment text                          |
| `createdAt`     | Timestamp| Comment creation timestamp            |
| `updatedAt`     | Timestamp| Last update timestamp                 |
| `likeCount`     | Number   | Number of likes                       |
| `likedBy`       | Array    | Array of user IDs who liked the comment |

### Follows Collection

**Collection**: `follows`

| Field           | Type     | Description                           |
|-----------------|----------|---------------------------------------|
| `id`            | String   | Unique follow relationship identifier |
| `followerId`    | String   | ID of user who is following           |
| `followingId`   | String   | ID of user being followed             |
| `createdAt`     | Timestamp| When the follow relationship was created |

### Messages Collection

**Collection**: `messages`

| Field           | Type     | Description                           |
|-----------------|----------|---------------------------------------|
| `id`            | String   | Unique message identifier             |
| `senderId`      | String   | ID of message sender                  |
| `receiverId`    | String   | ID of message recipient               |
| `content`       | String   | Message content                       |
| `createdAt`     | Timestamp| Message timestamp                     |
| `read`          | Boolean  | Whether message has been read         |

## Security Rules

Firestore security rules enforce the following permissions:

- Users can read public profile information
- Users can only write to their own profile
- Entries are publicly readable
- Only authenticated users can create entries
- Only entry authors can edit or delete their entries
- Comments are publicly readable
- Only authenticated users can create comments
- Only comment authors can edit or delete their comments

## API Methods

The application uses the following Firebase service classes:

- `UserService`: Manages user authentication and profiles
- `EntryService`: Handles CRUD operations for entries
- `CommentService`: Manages comments on entries
- `FollowService`: Handles user following relationships
- `MessageService`: Manages private messages between users 