# WordFlow Server Specification

## 1. Overview

**Server Purpose**: Backend service for WordFlow iOS game supporting daily puzzles, analytics, user-generated content, and real-time multiplayer functionality.

**Target Scale**: Small scale initial deployment (10-100 concurrent users)
**Hosting**: Digital Ocean VPS
**Architecture**: Node.js REST API + WebSocket server with PostgreSQL database

## 2. Technology Stack

### 2.1 Core Technologies

-   **Runtime**: Node.js 18+ with TypeScript
-   **Framework**: Express.js for REST API
-   **WebSocket**: Socket.io for real-time multiplayer
-   **Database**: PostgreSQL 15+ with Prisma ORM
-   **Authentication**: Apple Game Center integration
-   **Process Management**: PM2 for production deployment
-   **Reverse Proxy**: Nginx for SSL termination and load balancing

### 2.2 Supporting Libraries

```json
{
	"express": "^4.18.2",
	"socket.io": "^4.7.2",
	"prisma": "^5.0.0",
	"@prisma/client": "^5.0.0",
	"express-rate-limit": "^6.8.1",
	"helmet": "^7.0.0",
	"cors": "^2.8.5",
	"compression": "^1.7.4",
	"winston": "^3.10.0",
	"joi": "^17.9.2",
	"bcrypt": "^5.1.0",
	"jsonwebtoken": "^9.0.1",
	"node-cron": "^3.0.2",
	"express-handlebars": "^7.1.2",
	"systeminformation": "^5.21.7",
	"node-disk-info": "^1.3.0"
}
```

## 3. Architecture Overview

### 3.1 Server Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   iOS Client    │    │   iOS Client    │    │   iOS Client    │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ HTTPS/WSS            │ HTTPS/WSS            │ HTTPS/WSS
          │                      │                      │
    ┌─────▼──────────────────────▼──────────────────────▼─────┐
    │                 Nginx (SSL/Load Balancer)               │
    └─────┬──────────────────────┬──────────────────────┬─────┘
          │                      │                      │
    ┌─────▼─────┐         ┌──────▼──────┐        ┌─────▼─────┐
    │ REST API  │         │ WebSocket   │        │   Admin   │
    │ (Express) │         │ (Socket.io) │        │    UI     │
    └─────┬─────┘         └──────┬──────┘        └─────┬─────┘
          │                      │                     │
          └──────────────────────┼─────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   PostgreSQL Database   │
                    └─────────────────────────┘
```

### 3.2 Database Schema

#### 3.2.1 Core Tables

```sql
-- Users (Game Center integration)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_center_id VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP DEFAULT NOW()
);

-- Puzzles
CREATE TABLE puzzles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    creator_id UUID REFERENCES users(id),
    grid_data JSONB NOT NULL, -- Grid layout and letters
    words_data JSONB NOT NULL, -- Valid words with paths and metadata
    size_width INTEGER NOT NULL CHECK (size_width BETWEEN 3 AND 6),
    size_height INTEGER NOT NULL CHECK (size_height BETWEEN 3 AND 6),
    difficulty_score DECIMAL(5,2),
    minimum_word_length INTEGER DEFAULT 4,
    time_limit INTEGER, -- seconds, optional
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    submission_contact TEXT, -- optional contact info from creator
    is_daily_puzzle BOOLEAN DEFAULT FALSE,
    daily_puzzle_date DATE UNIQUE, -- when used as daily puzzle
    created_at TIMESTAMP DEFAULT NOW(),
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id)
);

-- Game Sessions (single player)
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    puzzle_id UUID REFERENCES puzzles(id) NOT NULL,
    game_mode VARCHAR(20) NOT NULL, -- beginner, normal, hardcore
    status VARCHAR(20) DEFAULT 'active', -- active, completed, abandoned
    score INTEGER DEFAULT 0,
    words_found JSONB DEFAULT '[]',
    completion_percentage DECIMAL(5,2) DEFAULT 0,
    start_time TIMESTAMP DEFAULT NOW(),
    end_time TIMESTAMP,
    total_time_seconds INTEGER,
    hints_used JSONB DEFAULT '{}' -- track which hints were used when
);

-- Multiplayer Rooms
CREATE TABLE multiplayer_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_code VARCHAR(6) UNIQUE NOT NULL,
    host_user_id UUID REFERENCES users(id) NOT NULL,
    puzzle_id UUID REFERENCES puzzles(id) NOT NULL,
    game_mode VARCHAR(20) NOT NULL, -- cooperative, competitive
    difficulty VARCHAR(20) NOT NULL, -- beginner, normal, hardcore
    max_players INTEGER DEFAULT 2,
    time_limit INTEGER, -- seconds, optional
    status VARCHAR(20) DEFAULT 'waiting', -- waiting, active, completed
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    started_at TIMESTAMP,
    ended_at TIMESTAMP
);

-- Multiplayer Participants
CREATE TABLE multiplayer_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID REFERENCES multiplayer_rooms(id) NOT NULL,
    user_id UUID REFERENCES users(id) NOT NULL,
    joined_at TIMESTAMP DEFAULT NOW(),
    left_at TIMESTAMP,
    is_connected BOOLEAN DEFAULT TRUE,
    score INTEGER DEFAULT 0,
    words_found JSONB DEFAULT '[]',
    UNIQUE(room_id, user_id)
);

-- Analytics Events
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    user_id UUID REFERENCES users(id), -- nullable for anonymous events
    puzzle_id UUID REFERENCES puzzles(id),
    session_id UUID, -- references game_sessions or multiplayer_rooms
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Daily Puzzle History
CREATE TABLE daily_puzzle_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    puzzle_id UUID REFERENCES puzzles(id) NOT NULL,
    date DATE UNIQUE NOT NULL,
    total_attempts INTEGER DEFAULT 0,
    total_completions INTEGER DEFAULT 0,
    average_completion_time DECIMAL(10,2),
    most_common_first_word VARCHAR(100),
    most_common_last_word VARCHAR(100)
);
```

#### 3.2.2 Indexes

```sql
-- Performance indexes
CREATE INDEX idx_users_game_center_id ON users(game_center_id);
CREATE INDEX idx_puzzles_status ON puzzles(status);
CREATE INDEX idx_puzzles_daily ON puzzles(is_daily_puzzle, daily_puzzle_date);
CREATE INDEX idx_game_sessions_user_puzzle ON game_sessions(user_id, puzzle_id);
CREATE INDEX idx_multiplayer_rooms_code ON multiplayer_rooms(room_code);
CREATE INDEX idx_multiplayer_rooms_status ON multiplayer_rooms(status);
CREATE INDEX idx_analytics_events_type_date ON analytics_events(event_type, created_at);
```

## 4. API Endpoints

### 4.1 Authentication

**Note**: Game Center integration will be implemented closer to launch when Apple Developer account is obtained. Initial development will use temporary user system.

```typescript
// Temporary authentication for development
POST /api/auth/temporary
Body: {
  displayName: string
}
Response: {
  token: string,
  user: UserObject,
  expiresIn: number
}

// Game Center authentication (future implementation)
POST /api/auth/game-center
Body: {
  gamePlayerId: string,
  publicKeyUrl: string,
  signature: string,
  salt: string,
  timestamp: number,
  displayName: string
}
Response: {
  token: string,
  user: UserObject,
  expiresIn: number
}
```

### 4.2 Puzzles

```typescript
// Get daily puzzle
GET /api/puzzles/daily
Response: PuzzleObject

// Get puzzle by ID
GET /api/puzzles/:id
Response: PuzzleObject

// Submit new puzzle
POST /api/puzzles/submit
Headers: { Authorization: "Bearer <token>" }
Body: {
  title: string,
  gridData: GridObject,
  wordsData: WordObject[],
  timeLimit?: number,
  contact?: string
}
Response: { id: string, status: "pending" }

// Get puzzle statistics
GET /api/puzzles/:id/statistics
Response: {
  totalAttempts: number,
  completionRate: number,
  averageTime: number,
  mostCommonFirstWord: string,
  mostCommonLastWord: string
}
```

### 4.3 Game Sessions

```typescript
// Start game session
POST /api/sessions/start
Headers: { Authorization: "Bearer <token>" }
Body: {
  puzzleId: string,
  gameMode: "beginner" | "normal" | "hardcore"
}
Response: { sessionId: string }

// Update game progress
PUT /api/sessions/:id/progress
Headers: { Authorization: "Bearer <token>" }
Body: {
  wordsFound: string[],
  score: number,
  completionPercentage: number
}
Response: { success: boolean }

// Complete game session
POST /api/sessions/:id/complete
Headers: { Authorization: "Bearer <token>" }
Body: {
  finalScore: number,
  wordsFound: string[],
  totalTimeSeconds: number,
  hintsUsed: object
}
Response: { success: boolean }
```

### 4.4 Multiplayer Rooms

```typescript
// Create room
POST /api/rooms/create
Headers: { Authorization: "Bearer <token>" }
Body: {
  puzzleId: string,
  gameMode: "cooperative" | "competitive",
  difficulty: "beginner" | "normal" | "hardcore",
  maxPlayers?: number,
  timeLimit?: number,
  settings?: object
}
Response: {
  roomId: string,
  roomCode: string,
  hostId: string
}

// Join room
POST /api/rooms/:code/join
Headers: { Authorization: "Bearer <token>" }
Response: {
  roomId: string,
  puzzle: PuzzleObject,
  participants: ParticipantObject[]
}

// Leave room
DELETE /api/rooms/:id/leave
Headers: { Authorization: "Bearer <token>" }
Response: { success: boolean }

// Get room state
GET /api/rooms/:id
Headers: { Authorization: "Bearer <token>" }
Response: {
  room: RoomObject,
  participants: ParticipantObject[],
  gameState?: GameStateObject
}
```

### 4.5 Analytics

```typescript
// Submit analytics event
POST /api/analytics/event
Headers: { Authorization: "Bearer <token>" } // optional for anonymous
Body: {
  eventType: string,
  puzzleId?: string,
  sessionId?: string,
  eventData: object
}
Response: { success: boolean }
```

### 4.6 Admin Interface & Monitoring

#### 4.6.1 Admin Web Interface

```typescript
// Admin login page
GET /admin/login
Response: HTML login form

// Admin dashboard
GET /admin/dashboard
Headers: { Authorization: "Bearer <admin-token>" }
Response: HTML dashboard with system overview

// Puzzle review interface
GET /admin/puzzles/pending
Headers: { Authorization: "Bearer <admin-token>" }
Response: HTML page with pending puzzle list and review tools

// Individual puzzle review
GET /admin/puzzles/:id/review
Headers: { Authorization: "Bearer <admin-token>" }
Response: HTML puzzle detail page with approve/reject controls

// System monitoring page
GET /admin/monitoring
Headers: { Authorization: "Bearer <admin-token>" }
Response: HTML page with server stats and performance metrics
```

#### 4.6.2 System Monitoring API

```typescript
// Get server health
GET /api/admin/health
Headers: { Authorization: "Bearer <admin-token>" }
Response: {
  status: "healthy" | "warning" | "critical",
  uptime: number,
  memory: {
    used: number,
    total: number,
    percentage: number
  },
  cpu: {
    usage: number,
    cores: number
  },
  disk: {
    used: number,
    total: number,
    percentage: number
  },
  database: {
    connected: boolean,
    activeConnections: number,
    totalQueries: number
  },
  activeRooms: number,
  connectedUsers: number
}

// Get application metrics
GET /api/admin/metrics
Headers: { Authorization: "Bearer <admin-token>" }
Response: {
  dailyActiveUsers: number,
  totalPuzzlesCompleted: number,
  averageSessionTime: number,
  pendingPuzzleSubmissions: number,
  errorRate: number,
  responseTime: number
}
```

### 4.7 Admin API (Protected Routes)

```typescript
// Get pending puzzle submissions
GET /api/admin/puzzles/pending
Headers: { Authorization: "Bearer <admin-token>" }
Response: PuzzleObject[]

// Approve/reject puzzle
PUT /api/admin/puzzles/:id/review
Headers: { Authorization: "Bearer <admin-token>" }
Body: {
  action: "approve" | "reject",
  notes?: string
}
Response: { success: boolean }

// Set daily puzzle
POST /api/admin/daily-puzzle
Headers: { Authorization: "Bearer <admin-token>" }
Body: {
  puzzleId: string,
  date: string // YYYY-MM-DD
}
Response: { success: boolean }
```

## 5. WebSocket Events

### 5.1 Connection Management

```typescript
// Client connects to room
socket.emit('join-room', {
  roomId: string,
  token: string
});

socket.on('room-joined', {
  roomState: RoomObject,
  participants: ParticipantObject[]
});

socket.on('player-joined', {
  participant: ParticipantObject
});

socket.on('player-left', {
  participantId: string
});
```

### 5.2 Game Events

```typescript
// Word tracing
socket.emit('trace-start', {
  startPosition: { x: number, y: number }
});

socket.emit('trace-update', {
  path: { x: number, y: number }[]
});

socket.emit('trace-end', {
  word: string,
  path: { x: number, y: number }[]
});

// Word discovery
socket.on('word-found', {
  word: string,
  foundBy: string,
  score: number,
  path: { x: number, y: number }[]
});

socket.on('word-invalid', {
  word: string,
  reason: string
});

// Game state updates
socket.on('game-state-update', {
  gameState: GameStateObject
});

socket.on('game-completed', {
  winner?: string, // for competitive mode
  finalScores: { [playerId: string]: number },
  completionTime: number
});
```

### 5.3 Communication

```typescript
// Chat messages
socket.emit('chat-message', {
	message: string,
});

socket.on('chat-message', {
	from: string,
	message: string,
	timestamp: number,
});

// Emoji reactions
socket.emit('emoji-reaction', {
	emoji: string,
});

socket.on('emoji-reaction', {
	from: string,
	emoji: string,
});
```

## 6. Security & Rate Limiting

### 6.1 Rate Limiting Rules

```typescript
const rateLimits = {
	// General API
	'/api/*': {
		windowMs: 15 * 60 * 1000, // 15 minutes
		max: 100, // requests per window
	},

	// Room creation (prevent spam)
	'/api/rooms/create': {
		windowMs: 5 * 60 * 1000, // 5 minutes
		max: 5, // rooms per window
	},

	// Puzzle submission
	'/api/puzzles/submit': {
		windowMs: 60 * 60 * 1000, // 1 hour
		max: 3, // submissions per hour
	},

	// Analytics (higher limit for gameplay)
	'/api/analytics/*': {
		windowMs: 1 * 60 * 1000, // 1 minute
		max: 30, // events per minute
	},
};
```

### 6.2 Game Center Verification

```typescript
// Verify Game Center authentication
async function verifyGameCenterAuth(
	authData: GameCenterAuthData
): Promise<boolean> {
	// 1. Download Apple's public key from publicKeyUrl
	// 2. Verify signature using Apple's public key
	// 3. Check timestamp is recent (within 24 hours)
	// 4. Verify salt and gamePlayerId match
	return isValid;
}
```

### 6.3 Input Validation

```typescript
// Puzzle submission validation
const puzzleSubmissionSchema = Joi.object({
	title: Joi.string().min(3).max(200).required(),
	gridData: Joi.object({
		grid: Joi.array()
			.items(
				Joi.array()
					.items(Joi.string().length(1).uppercase().allow(null))
					.min(3)
					.max(6)
			)
			.min(3)
			.max(6)
			.required(),
		width: Joi.number().min(3).max(6).required(),
		height: Joi.number().min(3).max(6).required(),
	}).required(),
	wordsData: Joi.array()
		.items(
			Joi.object({
				word: Joi.string().min(3).max(20).uppercase().required(),
				path: Joi.array()
					.items(
						Joi.object({
							x: Joi.number().min(0).max(5).required(),
							y: Joi.number().min(0).max(5).required(),
						})
					)
					.min(3)
					.required(),
				required: Joi.boolean().default(true),
				difficulty: Joi.string()
					.valid('common', 'uncommon', 'rare')
					.default('common'),
			})
		)
		.min(1)
		.required(),
	timeLimit: Joi.number().min(60).max(3600).optional(),
	contact: Joi.string().email().optional(),
});
```

## 7. Performance & Monitoring

### 7.1 Database Performance

```sql
-- Connection pooling
database: {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  pool: {
    min: 2,
    max: 10,
    acquire: 30000,
    idle: 10000
  }
}
```

### 7.2 WebSocket Room Management

```typescript
class RoomManager {
	private rooms = new Map<string, Room>();

	// Clean up inactive rooms every 5 minutes
	private cleanupInterval = setInterval(() => {
		this.cleanupInactiveRooms();
	}, 5 * 60 * 1000);

	private cleanupInactiveRooms() {
		const now = Date.now();
		for (const [roomId, room] of this.rooms) {
			if (now - room.lastActivity > 30 * 60 * 1000) {
				// 30 minutes
				room.close();
				this.rooms.delete(roomId);
			}
		}
	}
}
```

### 7.3 Logging & Monitoring

```typescript
// Winston logger configuration
const logger = winston.createLogger({
	level: 'info',
	format: winston.format.combine(
		winston.format.timestamp(),
		winston.format.errors({ stack: true }),
		winston.format.json()
	),
	defaultMeta: { service: 'wordflow-server' },
	transports: [
		new winston.transports.File({ filename: 'error.log', level: 'error' }),
		new winston.transports.File({ filename: 'combined.log' }),
		new winston.transports.Console({
			format: winston.format.simple(),
		}),
	],
});

// System monitoring middleware
import si from 'systeminformation';

class SystemMonitor {
	private metrics = {
		startTime: Date.now(),
		requestCount: 0,
		errorCount: 0,
		activeConnections: 0,
	};

	async getSystemHealth() {
		const [cpu, memory, disk] = await Promise.all([
			si.currentLoad(),
			si.mem(),
			si.fsSize(),
		]);

		return {
			uptime: Date.now() - this.metrics.startTime,
			cpu: {
				usage: cpu.currentLoad,
				cores: cpu.cpus.length,
			},
			memory: {
				used: memory.used,
				total: memory.total,
				percentage: (memory.used / memory.total) * 100,
			},
			disk: {
				used: disk[0]?.used || 0,
				total: disk[0]?.size || 0,
				percentage: disk[0]?.use || 0,
			},
			requests: this.metrics.requestCount,
			errors: this.metrics.errorCount,
			activeConnections: this.metrics.activeConnections,
		};
	}
}
```

## 8. Deployment Configuration

### 8.1 Environment Variables

```bash
# Database (Self-managed PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=wordflow
DB_USER=wordflow_user
DB_PASSWORD=secure_password

# Server
PORT=3000
NODE_ENV=production
JWT_SECRET=your_jwt_secret_here
ADMIN_JWT_SECRET=your_admin_jwt_secret_here
ADMIN_USERNAME=admin
ADMIN_PASSWORD=secure_admin_password

# SSL (Let's Encrypt certificates)
SSL_CERT_PATH=/etc/letsencrypt/live/your-domain.com/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/your-domain.com/privkey.pem

# CORS
ALLOWED_ORIGINS=https://your-domain.com,https://www.your-domain.com

# Rate Limiting (Redis optional for distributed rate limiting)
REDIS_URL=redis://localhost:6379

# Game Center (for future implementation)
GAME_CENTER_BUNDLE_ID=com.yourname.wordflow

# Monitoring
ENABLE_MONITORING=true
MONITORING_INTERVAL=60000 # 1 minute
```

### 8.2 PostgreSQL Setup (Self-Managed)

```bash
# Install PostgreSQL on Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# Create database and user
sudo -u postgres psql
CREATE DATABASE wordflow;
CREATE USER wordflow_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE wordflow TO wordflow_user;
\q

# Configure PostgreSQL
sudo nano /etc/postgresql/15/main/postgresql.conf
# Uncomment and set:
# listen_addresses = 'localhost'
# max_connections = 100

sudo nano /etc/postgresql/15/main/pg_hba.conf
# Add line for local app connection:
# local   wordflow    wordflow_user                   md5

# Restart PostgreSQL
sudo systemctl restart postgresql
sudo systemctl enable postgresql

# Test connection
psql -h localhost -U wordflow_user -d wordflow
```

### 8.3 SSL Setup with Let's Encrypt

```bash
# Install Certbot
sudo apt update
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Stop nginx temporarily for certificate generation
sudo systemctl stop nginx

# Generate certificates
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Set up auto-renewal
sudo systemctl enable snap.certbot.renew.timer
sudo systemctl start snap.certbot.renew.timer

# Test renewal
sudo certbot renew --dry-run
```

### 8.4 Nginx Configuration (Updated for Let's Encrypt)

```nginx
# HTTP redirect to HTTPS
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # Let's Encrypt SSL certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;
    add_header X-XSS-Protection "1; mode=block" always;

    # API routes
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # WebSocket routes
    location /socket.io/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }

    # Admin interface
    location /admin/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Basic auth for additional security (optional)
        # auth_basic "Admin Area";
        # auth_basic_user_file /etc/nginx/.htpasswd;
    }

    # Static files (if serving any)
    location /static/ {
        root /var/www/wordflow;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 8.5 PM2 Configuration

```json
{
	"apps": [
		{
			"name": "wordflow-server",
			"script": "dist/index.js",
			"instances": "max",
			"exec_mode": "cluster",
			"env": {
				"NODE_ENV": "production",
				"PORT": 3000
			},
			"error_file": "./logs/err.log",
			"out_file": "./logs/out.log",
			"log_file": "./logs/combined.log",
			"time": true,
			"watch": false,
			"max_memory_restart": "1G"
		}
	]
}
```

## 9. Development Setup

### 9.1 Local Development

```bash
# Install dependencies
npm install

# Database setup (self-managed PostgreSQL)
# Install PostgreSQL locally
brew install postgresql  # macOS
# or
sudo apt install postgresql postgresql-contrib  # Ubuntu

# Start PostgreSQL service
brew services start postgresql  # macOS
# or
sudo systemctl start postgresql  # Ubuntu

# Create development database
createdb wordflow_dev
psql wordflow_dev
CREATE USER wordflow_dev WITH PASSWORD 'dev_password';
GRANT ALL PRIVILEGES ON DATABASE wordflow_dev TO wordflow_dev;

# Alternative: Use Docker for development database
docker run --name wordflow-postgres-dev \
  -e POSTGRES_PASSWORD=dev_password \
  -e POSTGRES_USER=wordflow_dev \
  -e POSTGRES_DB=wordflow_dev \
  -p 5432:5432 \
  -d postgres:15

# Copy environment file
cp .env.example .env.development

# Run migrations
npx prisma migrate dev

# Seed database with sample data
npx prisma db seed

# Start development server with monitoring
npm run dev
```

### 9.2 Admin Interface Development

```bash
# The admin interface includes:
# - Handlebars templates in /views/admin/
# - Static assets in /public/admin/
# - Real-time system monitoring dashboard
# - Puzzle review and approval interface

# Admin routes are served at:
# http://localhost:3000/admin/login
# http://localhost:3000/admin/dashboard
# http://localhost:3000/admin/puzzles/pending
# http://localhost:3000/admin/monitoring
```

### 9.3 Database Migrations

```bash
# Create new migration
npx prisma migrate dev --name add_multiplayer_tables

# Deploy to production
npx prisma migrate deploy

# Reset development database
npx prisma migrate reset
```

### 9.4 Testing Strategy

```typescript
// Jest configuration for API testing
describe('Puzzle API', () => {
	test('should create puzzle submission', async () => {
		const response = await request(app)
			.post('/api/puzzles/submit')
			.set('Authorization', `Bearer ${validToken}`)
			.send(validPuzzleData);

		expect(response.status).toBe(201);
		expect(response.body.id).toBeDefined();
	});
});

// WebSocket testing with socket.io-client
describe('Multiplayer WebSocket', () => {
	test('should handle room joining', (done) => {
		const client = io('http://localhost:3000');
		client.emit('join-room', { roomId: 'test-room', token: validToken });
		client.on('room-joined', (data) => {
			expect(data.roomState).toBeDefined();
			client.disconnect();
			done();
		});
	});
});

// Admin interface testing
describe('Admin Interface', () => {
	test('should require authentication for admin pages', async () => {
		const response = await request(app).get('/admin/dashboard');
		expect(response.status).toBe(302); // Redirect to login
	});

	test('should display monitoring data', async () => {
		const response = await request(app)
			.get('/admin/monitoring')
			.set('Cookie', adminSessionCookie);
		expect(response.status).toBe(200);
		expect(response.text).toContain('System Health');
	});
});

// System monitoring tests
describe('System Monitoring', () => {
	test('should return health metrics', async () => {
		const response = await request(app)
			.get('/api/admin/health')
			.set('Authorization', `Bearer ${adminToken}`);

		expect(response.status).toBe(200);
		expect(response.body.status).toBeDefined();
		expect(response.body.uptime).toBeGreaterThan(0);
	});
});
```

## 10. Cron Jobs & Background Tasks

### 10.1 Daily Puzzle Assignment

```typescript
// Runs daily at 00:01 UTC
cron.schedule('1 0 * * *', async () => {
	try {
		const tomorrow = new Date();
		tomorrow.setDate(tomorrow.getDate() + 1);

		// Check if tomorrow already has a daily puzzle
		const existingPuzzle = await prisma.puzzles.findFirst({
			where: {
				is_daily_puzzle: true,
				daily_puzzle_date: tomorrow.toISOString().split('T')[0],
			},
		});

		if (!existingPuzzle) {
			// Select a random approved puzzle
			const availablePuzzles = await prisma.puzzles.findMany({
				where: {
					status: 'approved',
					is_daily_puzzle: false,
				},
			});

			if (availablePuzzles.length > 0) {
				const randomPuzzle =
					availablePuzzles[
						Math.floor(Math.random() * availablePuzzles.length)
					];

				await prisma.puzzles.update({
					where: { id: randomPuzzle.id },
					data: {
						is_daily_puzzle: true,
						daily_puzzle_date: tomorrow.toISOString().split('T')[0],
					},
				});

				logger.info(
					`Daily puzzle set for ${
						tomorrow.toISOString().split('T')[0]
					}: ${randomPuzzle.title}`
				);
			}
		}
	} catch (error) {
		logger.error('Failed to set daily puzzle:', error);
	}
});
```

### 10.2 Analytics Aggregation

```typescript
// Runs every hour to aggregate analytics
cron.schedule('0 * * * *', async () => {
	try {
		// Update daily puzzle statistics
		const today = new Date().toISOString().split('T')[0];

		// Aggregate completion data for today's daily puzzle
		const stats = await prisma.analytics_events.aggregate({
			where: {
				event_type: 'puzzle_completed',
				created_at: {
					gte: new Date(`${today}T00:00:00Z`),
					lt: new Date(`${today}T23:59:59Z`),
				},
			},
			_count: true,
			_avg: {
				// Assuming completion time is stored in event_data
			},
		});

		// Update or create daily statistics
		await prisma.daily_puzzle_history.upsert({
			where: { date: today },
			update: {
				total_completions: stats._count,
				// ... other aggregated data
			},
			create: {
				date: today,
				puzzle_id: 'daily-puzzle-id',
				total_completions: stats._count,
				// ... other aggregated data
			},
		});

		logger.info(`Analytics aggregated for ${today}`);
	} catch (error) {
		logger.error('Failed to aggregate analytics:', error);
	}
});
```

## 11. Error Handling & Graceful Shutdown

### 11.1 Global Error Handler

```typescript
// Global error handler middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
	logger.error('Unhandled error:', {
		error: err.message,
		stack: err.stack,
		url: req.url,
		method: req.method,
		ip: req.ip,
	});

	if (res.headersSent) {
		return next(err);
	}

	const statusCode = err.name === 'ValidationError' ? 400 : 500;
	res.status(statusCode).json({
		error:
			process.env.NODE_ENV === 'production'
				? 'Internal server error'
				: err.message,
	});
});
```

### 11.2 Graceful Shutdown

```typescript
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

async function gracefulShutdown(signal: string) {
	logger.info(`Received ${signal}, starting graceful shutdown`);

	// Stop accepting new connections
	server.close(() => {
		logger.info('HTTP server closed');
	});

	// Close WebSocket connections
	io.close(() => {
		logger.info('WebSocket server closed');
	});

	// Close database connections
	await prisma.$disconnect();
	logger.info('Database connections closed');

	process.exit(0);
}
```

## 12. Admin Interface Implementation

### 12.1 File Structure

```
/views/admin/
├── layouts/
│   └── main.hbs           # Main admin layout
├── login.hbs              # Admin login page
├── dashboard.hbs          # Admin dashboard
├── puzzles/
│   ├── pending.hbs        # Pending puzzles list
│   └── review.hbs         # Individual puzzle review
└── monitoring.hbs         # System monitoring page

/public/admin/
├── css/
│   └── admin.css          # Admin interface styles
├── js/
│   ├── dashboard.js       # Dashboard functionality
│   ├── monitoring.js      # Real-time monitoring charts
│   └── puzzle-review.js   # Puzzle review interface
└── img/
    └── logo.png           # Admin interface logo
```

### 12.2 Admin Dashboard Features

```typescript
// Dashboard displays:
interface AdminDashboard {
	systemHealth: {
		status: 'healthy' | 'warning' | 'critical';
		uptime: string;
		lastRestart: Date;
	};
	recentActivity: {
		newUsers: number;
		gamesCompleted: number;
		puzzlesSubmitted: number;
		activeRooms: number;
	};
	pendingTasks: {
		puzzleReviews: number;
		errorReports: number;
	};
	quickStats: {
		totalUsers: number;
		totalPuzzles: number;
		dailyActiveUsers: number;
	};
}
```

### 12.3 Real-time Monitoring

```javascript
// Client-side monitoring updates
class AdminMonitoring {
	constructor() {
		this.socket = io('/admin-monitoring');
		this.setupCharts();
		this.startRealTimeUpdates();
	}

	setupCharts() {
		// CPU usage chart
		this.cpuChart = new Chart(document.getElementById('cpu-chart'), {
			type: 'line',
			data: { labels: [], datasets: [{ data: [] }] },
		});

		// Memory usage chart
		this.memoryChart = new Chart(document.getElementById('memory-chart'), {
			type: 'line',
			data: { labels: [], datasets: [{ data: [] }] },
		});
	}

	startRealTimeUpdates() {
		this.socket.on('system-stats', (stats) => {
			this.updateCharts(stats);
			this.updateMetrics(stats);
		});
	}
}
```
