# M-P Chat API Routes

## 🚀 Base URL
```
http://localhost:3000
```

## 📊 Health Check
```
GET /api/health
```
**Response:**
```json
{
  "status": "ok",
  "message": "m-p-chat backend is running",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 🔐 Authentication

### Register
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "password": "password123"
}
```
**Response (201):**
```json
{
  "message": "User registered successfully",
  "access_token": "base64_encoded_token",
  "user": {
    "id": "1640995200000",
    "username": "newuser",
    "email": "newuser@example.com"
  }
}
```

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```
**Response (200):**
```json
{
  "message": "Login successful",
  "access_token": "base64_encoded_token",
  "user": {
    "id": "1",
    "username": "testuser",
    "email": "testuser@example.com"
  }
}
```

## 👥 Users

### Get All Users
```
GET /api/users
Authorization: Bearer {access_token}
```
**Response (200):**
```json
[
  {
    "id": "1",
    "username": "testuser",
    "email": "testuser@example.com",
    "isOnline": true,
    "lastSeen": "2024-01-01T12:00:00.000Z"
  },
  {
    "id": "2",
    "username": "alice",
    "email": "alice@example.com",
    "isOnline": false,
    "lastSeen": "2024-01-01T11:00:00.000Z"
  }
]
```

## 💬 Messages & Chats

### Get All Chats
```
GET /api/messages/chats
Authorization: Bearer {access_token}
```
**Response (200):**
```json
[
  {
    "id": "1",
    "participant": {
      "id": "2",
      "username": "alice",
      "email": "alice@example.com",
      "isOnline": false,
      "lastSeen": "2024-01-01T11:00:00.000Z"
    },
    "lastMessage": {
      "id": "1",
      "content": "Hey, how are you?",
      "type": "text",
      "senderId": "2",
      "receiverId": "1",
      "createdAt": "2024-01-01T11:30:00.000Z",
      "isRead": false
    },
    "unreadCount": 1,
    "updatedAt": "2024-01-01T11:30:00.000Z"
  }
]
```

### Get Messages with User
```
GET /api/messages/{userId}
Authorization: Bearer {access_token}
```
**Response (200):**
```json
[
  {
    "id": "1",
    "content": "Hey, how are you?",
    "type": "text",
    "senderId": "2",
    "receiverId": "1",
    "createdAt": "2024-01-01T11:30:00.000Z",
    "isRead": false
  },
  {
    "id": "2",
    "content": "I'm good, thanks! How about you?",
    "type": "text",
    "senderId": "1",
    "receiverId": "2",
    "createdAt": "2024-01-01T11:45:00.000Z",
    "isRead": true
  }
]
```

### Create Message
```
POST /api/messages
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "receiverId": "2",
  "content": "Hello!",
  "type": "text"
}
```
**Response (201):**
```json
{
  "message": "Message created successfully"
}
```

## 🔌 Socket.IO Events

### Connection
```javascript
const socket = io('http://localhost:3000');
```

### Send Message
```javascript
socket.emit('sendMessage', {
  receiverId: '2',
  content: 'Hello!',
  type: 'text'
});
```

### Receive Message
```javascript
socket.on('newMessage', (message) => {
  console.log('New message:', message);
});
```

### User Online/Offline
```javascript
socket.on('userStatus', (data) => {
  console.log('User status changed:', data);
});
```

## 🧪 Testing

Use the built-in API test:
```bash
cd flutter_app
build.bat
# Choose option 6
```

Or test individual endpoints:
```bash
# Health check
curl http://localhost:3000/api/health

# Get users
curl http://localhost:3000/api/users

# Get chats
curl http://localhost:3000/api/messages/chats
```

## 📝 Notes

- All timestamps are in ISO 8601 format
- Authentication tokens are base64 encoded (mock implementation)
- Currently using mock data - replace with database integration
- Socket.IO supports CORS for all origins (development only)