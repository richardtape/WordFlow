# WordFlow: Product Requirements Document

## 1. Product Overview

**Product Name**: WordFlow
**Platform**: iOS (Native Swift)
**Target Audience**: Word puzzle enthusiasts, families
**Core Value Proposition**: A unique word search game where players trace connected letters in any direction to form words

## 2. Core Game Mechanics

### 2.1 Grid System

-   **Grid Sizes**: 3x3 to 6x6 squares
-   **Letter Placement**: Each square contains one letter or is blank (in builder mode)
-   **Adjacency Rule**: Letters can connect horizontally, vertically, or diagonally
-   **Usage Rule**: Every letter in the grid must be used in at least one valid word

### 2.2 Word Formation

-   **Tracing Method**: Players drag finger from letter to letter
-   **Path Rules**: Must move to adjacent squares only, can change direction freely
-   **Backtracking**: Players can slide finger back over previous letters to correct mistakes
-   **Letter Reuse**: Each letter can only be used once per word attempt

### 2.3 Word Validation

-   **Dictionary**: Scrabble word list as base dictionary
-   **Word Length**: Minimum 3 letters (default 4), maximum grid size (e.g., 25 for 5x5)
-   **Content Filter**: Remove offensive words using maintained blocklist
-   **Word Variants**: Plurals, past tense count as separate valid words

## 3. Game Modes

### 3.1 Single Player Modes

#### 3.1.1 Beginner Mode

-   All hints enabled at all times
-   Total word count shown immediately
-   Word length breakdown shown immediately
-   Letter start hints (bottom-left numbers) shown immediately
-   Letter containment hints (bottom-right numbers) shown immediately
-   No time pressure (timers disabled)
-   "Reveal Word" hint always available
-   Auto-save enabled
-   Letter fade-out when no remaining words contain that letter

#### 3.1.2 Normal Mode

-   Progressive hint system:
    -   Total word count: Shown at start
    -   Word length breakdown: Shown after 10% completion
    -   Letter start hints: Shown after 35% completion
    -   Letter containment hints: Shown after 50% completion
-   Timer continues after expiration (no game over)
-   "Reveal Word" hint available after 80% completion
-   Auto-save enabled
-   Letter fade-out enabled

#### 3.1.3 Hardcore Mode

-   No hints provided
-   No word count or breakdown shown
-   No numerical indicators on letters
-   Timer ends game if set by puzzle creator
-   No "Reveal Word" option
-   No auto-save
-   No letter fade-out

### 3.2 Multiplayer Modes

#### 3.2.1 Cooperative Multiplayer

-   **Concept**: Two players work together on the same puzzle in real-time
-   **Shared Progress**: Both players see the same grid and found words list
-   **Word Discovery**: Either player can find and submit words
-   **Real-time Sync**: All actions (word tracing, discoveries) sync instantly
-   **Communication**: Optional text chat or emoji reactions
-   **Scoring**: Shared score with bonus for teamwork
-   **Session Management**: Host creates room, shares code with partner
-   **Difficulty Modes**: All single-player difficulty modes available

#### 3.2.2 Competitive Multiplayer

-   **Concept**: Two players race to complete identical puzzles
-   **Separate Progress**: Each player has their own progress tracking
-   **Real-time Updates**: See opponent's word count and score (optional setting)
-   **Victory Conditions**: First to find all words wins, or highest score after time limit
-   **Spectator Mode**: Completed player can watch opponent finish
-   **Rematch**: Easy option to play again with same or different puzzle
-   **Ranking**: Track wins/losses between regular opponents
-   **Tournament Mode**: Single elimination brackets for multiple players (future feature)

#### 3.2.3 Multiplayer Interface Elements

-   **Room Creation**: Simple 6-digit code system for joining
-   **Player Status**: Online/offline indicators, typing indicators during chat
-   **Progress Sharing**: Optional real-time visibility of opponent progress
-   **Connection Management**: Graceful handling of disconnections with rejoin capability
-   **Cross-platform**: Support for playing across different devices

### 3.3 Builder Mode

-   Create custom puzzles with grid sizes 3x3 to 6x6
-   Toggle squares between letter input and blank
-   Real-time word validation and counting
-   Option to disable specific words (become bonus words)
-   Save drafts locally
-   Submit puzzles to server with optional contact info
-   Set optional time limits for puzzles

## 4. User Interface Specifications

### 4.1 Grid Display

-   **Letter Squares**:
    -   Size: 60x60 points on iPhone, 80x80 on iPad
    -   Border: 1pt border with corner radius 8pt
    -   Background: System background color (.systemBackground)
    -   Border color: System gray 4 (.systemGray4)
    -   Font: SF Pro Display, size 24pt (iPhone), 32pt (iPad), weight: semibold
    -   Letter color: Label color (.label)
-   **Active Tracing**:
    -   Path color: System blue (.systemBlue) with 4pt stroke width
    -   Selected letters: Background changes to system blue (.systemBlue), text white
    -   Connection line: Smooth curved path with 3pt stroke, 50% opacity
-   **Letter States**:
    -   Normal: Standard appearance as above
    -   Selected: Blue background (#007AFF), white text
    -   Faded: 30% opacity, gray background (.systemGray5)
-   **Hint Numbers**:
    -   Font: SF Pro Text, size 12pt, weight: medium
    -   Bottom-left (start hints): Red (#FF3B30), 4pt from edges
    -   Bottom-right (contain hints): Gray (.secondaryLabel), 4pt from edges
    -   Background: White circle with 2pt radius, 20% opacity

### 4.2 Game Interface

-   **Word List**:
    -   Font: SF Pro Text, size 16pt, weight: regular
    -   Found words: Primary label color (.label)
    -   Background: Grouped background color (.systemGroupedBackground)
    -   Cell height: 44pt minimum
    -   Word length indicator: Secondary text in parentheses
-   **Progress Indicators**:
    -   Progress bar: System blue (.systemBlue), 6pt height, rounded corners
    -   Text: SF Pro Text, size 14pt, secondary label color (.secondaryLabel)
    -   Percentage completion: Bold weight for emphasis
    -   Words found vs total: Regular weight when appropriate for mode
    -   Breakdown by word length: Indented 16pt, tertiary label color
-   **Timer**:
    -   Font: SF Pro Display, size 18pt, weight: medium
    -   Color: Label color (.label), changes to red (.systemRed) in final 60 seconds
    -   Background: System background with subtle border
-   **Score**:
    -   Font: SF Pro Display, size 20pt, weight: semibold
    -   Color: System blue (.systemBlue)
    -   Breakdown: Smaller text, secondary label color

### 4.5 Feedback Systems

-   **Valid Word**:
    -   Success sound: System sound "Tock" (or custom equivalent)
    -   Visual: Word briefly highlights in green (#34C759) for 0.3 seconds
    -   Animation: Gentle scale up (1.1x) and back down, 0.2 second duration
    -   Haptic: Light impact feedback
-   **Invalid Word**:
    -   Shake animation: 3 quick shakes, 0.5 second total duration
    -   Visual: Selection clears with fade out animation
    -   Haptic: Error feedback (if available)
-   **Puzzle Complete**:
    -   Completion sound: System sound "Glass" (or custom celebration sound)
    -   Visual: Confetti animation or similar celebration effect
    -   Score summary: Modal overlay with score breakdown and statistics
    -   Haptic: Success feedback
-   **Multiplayer Events**:
    -   Partner word discovery: Subtle chime and brief highlight
    -   Opponent word discovery: Different sound cue in competitive mode
    -   Connection status: Visual and audio indicators for connect/disconnect
-   **Valid Word**:
    -   Success sound: System sound "Tock" (or custom equivalent)
    -   Visual: Word briefly highlights in green (#34C759) for 0.3 seconds
    -   Animation: Gentle scale up (1.1x) and back down, 0.2 second duration
    -   Haptic: Light impact feedback
-   **Invalid Word**:
    -   Shake animation: 3 quick shakes, 0.5 second total duration
    -   Visual: Selection clears with fade out animation
    -   Haptic: Error feedback (if available)
-   **Puzzle Complete**:
    -   Completion sound: System sound "Glass" (or custom celebration sound)
    -   Visual: Confetti animation or similar celebration effect
    -   Score summary: Modal overlay with score breakdown and statistics
    -   Haptic: Success feedback

## 5. Scoring System

### 5.1 Base Scoring

-   **Word Length Scoring**: Exponential formula: `basePoints * (2^(length-3))`
    -   Base points = 100
    -   3 letters: 100 points (100 \* 2^0)
    -   4 letters: 200 points (100 \* 2^1)
    -   5 letters: 400 points (100 \* 2^2)
    -   6 letters: 800 points (100 \* 2^3)
    -   7+ letters: Continue exponential pattern

### 5.2 Bonus Systems

-   **Consecutive Words**: Multiplier for finding multiple words in sequence
-   **Time Bonus**: Faster completion = higher bonus (formula TBD)
-   **Rare Word Bonus**: Extra points for finding disabled/uncommon words

## 6. Tutorial and Onboarding

### 6.1 First Launch Tutorial

-   **Step 1**: Show simple grid with one obvious word to trace
-   **Step 2**: Demonstrate that paths don't need to be straight lines
-   **Step 3**: Explain that all letters will be used
-   **Step 4**: Mode selection with explanation of each mode

### 6.2 Interface Tutorial

-   Highlight hint numbers when they first appear
-   Show where found words appear
-   Explain scoring briefly

## 7. Settings and Preferences

### 7.1 Gameplay Settings

-   **Default Mode**: Beginner/Normal/Hardcore
-   **Sound Effects**: On/Off toggle
-   **Haptic Feedback**: On/Off toggle
-   **Auto-save**: On/Off toggle (disabled in Hardcore)

### 7.2 Accessibility Settings

-   **Text Size**: Small/Medium/Large/Extra Large
-   **High Contrast**: On/Off
-   **Color Blind Support**: Color palette options
-   **Dark Mode**: System/Light/Dark

### 7.3 Advanced Settings

-   **Analytics Sharing**: Anonymous data sharing toggle
-   **Tutorial Reset**: Option to replay tutorial

## 8. Data Models

### 8.1 Puzzle Structure

```json
{
	"id": "string",
	"title": "string",
	"creator": "string (optional)",
	"grid": [
		["A", "B", "C"],
		["D", null, "E"],
		["F", "G", "H"]
	],
	"size": { "width": 3, "height": 3 },
	"words": [
		{
			"word": "string",
			"path": [
				{ "x": 0, "y": 0 },
				{ "x": 1, "y": 0 }
			],
			"required": true,
			"difficulty": "common|uncommon|rare"
		}
	],
	"timeLimit": "number (seconds, optional)",
	"minimumWordLength": "number (default 4)",
	"difficulty": "string",
	"createdDate": "timestamp"
}
```

### 8.2 Game State

```json
{
	"puzzleId": "string",
	"foundWords": ["array of strings"],
	"currentScore": "number",
	"startTime": "timestamp",
	"mode": "beginner|normal|hardcore",
	"hintsEnabled": {
		"wordCount": "boolean",
		"lengthBreakdown": "boolean",
		"letterStart": "boolean",
		"letterContain": "boolean"
	}
}
```

### 8.5 User Progress

```json
{
	"completedPuzzles": ["array of puzzle IDs"],
	"totalScore": "number",
	"totalTime": "number",
	"preferences": "settings object",
	"multiplayerStats": {
		"cooperativeGamesPlayed": "number",
		"competitiveGamesPlayed": "number",
		"competitiveWins": "number",
		"averageCooperativeTime": "number",
		"favoritePartner": "playerId (optional)"
	}
}
```

```json
{
	"completedPuzzles": ["array of puzzle IDs"],
	"totalScore": "number",
	"totalTime": "number",
	"preferences": "settings object"
}
```

## 9. Server Integration

### 9.1 API Endpoints

#### 9.1.1 Daily Puzzle

-   **GET /api/daily-puzzle**: Returns puzzle of the day
-   **Response**: Puzzle object with metadata

#### 9.1.2 Puzzle Submission

-   **POST /api/puzzles/submit**: Submit user-created puzzle
-   **Payload**: Puzzle object + optional contact info
-   **Response**: Submission confirmation

#### 9.1.3 Analytics

-   **POST /api/analytics/game-complete**: Submit completion data
-   **Payload**: Anonymous game statistics
-   **Response**: Success confirmation

#### 9.1.4 Statistics

-   **GET /api/statistics/:puzzleId**: Get puzzle statistics
-   **Response**: Aggregated completion data

#### 9.1.5 Multiplayer Endpoints

-   **POST /api/rooms/create**: Create new multiplayer room
-   **POST /api/rooms/:roomId/join**: Join existing room
-   **GET /api/rooms/:roomId**: Get room state
-   **DELETE /api/rooms/:roomId/leave**: Leave room
-   **WebSocket /ws/rooms/:roomId**: Real-time game communication
-   **POST /api/rooms/:roomId/start**: Start multiplayer game
-   **POST /api/multiplayer/analytics**: Submit multiplayer game statistics

### 9.2 Analytics Data Collection

#### 9.2.1 Single Player Analytics

-   Puzzle completion time
-   First word found
-   Last word found
-   Completion percentage
-   Mode used
-   Words found in order

#### 9.2.2 Multiplayer Analytics

-   **Cooperative Mode**:
    -   Combined completion time
    -   Words found by each player
    -   Communication frequency (chat messages sent)
    -   Session duration
    -   Reconnection events
-   **Competitive Mode**:
    -   Individual completion times
    -   Winner determination
    -   Score differential
    -   Word discovery race patterns
    -   Rematch frequency

## 10. Builder Mode Specifications

### 10.1 Grid Editor

-   **Letter Input**: Tap square to enter letter
-   **Blank Toggle**: Tap to toggle between letter and blank
-   **Grid Resize**: Option to change grid dimensions
-   **Clear Grid**: Reset all squares

### 10.2 Word Analysis

-   **Real-time Checking**: Update word count as grid changes
-   **Word List Display**: Show all possible words with classifications
-   **Difficulty Assessment**: Algorithm to calculate puzzle difficulty
-   **Word Management**: Enable/disable specific words

### 10.3 Puzzle Validation

-   **Minimum Words**: Ensure sufficient words for engaging puzzle
-   **Letter Usage**: Verify all letters are used in at least one word
-   **Connectivity**: Ensure all required words are possible to trace

### 10.4 Difficulty Assessment Algorithm

-   **Total Word Count**: More words = higher difficulty
-   **Average Word Length**: Longer average = higher difficulty
-   **Uncommon Letters**: Presence of Q, X, Z, J increases difficulty
-   **Grid Utilization**: Percentage of non-blank squares affects difficulty
-   **Difficulty Score Calculation**:
    ```
    difficultyScore = (wordCount * 0.3) + (avgWordLength * 0.25) +
                     (uncommonLetterCount * 0.2) + (gridUtilization * 0.25)
    ```
-   **Difficulty Tiers**:
    -   Easy: Score 0-30
    -   Medium: Score 31-60
    -   Hard: Score 61-90
    -   Expert: Score 91+

## 11. Technical Requirements

### 11.1 Performance

-   **Word Checking**: Efficient algorithm for real-time validation using Trie data structure
-   **Grid Analysis**: Trie-based depth-first search for word discovery optimization
    -   Build Trie from dictionary on app launch
    -   For each grid position, perform DFS following Trie paths
    -   Prune search when current path doesn't match any Trie prefixes
    -   Cache results for identical grid configurations
-   **Memory Management**: Handle large word dictionaries efficiently

### 11.5 Performance Thresholds

-   **Word Validation During Tracing**: ≤50ms response time
-   **Builder Mode Word Analysis**:
    -   3x3 grid: ≤100ms
    -   4x4 grid: ≤500ms
    -   5x5 grid: ≤2 seconds
    -   6x6 grid: ≤5 seconds (with progress indicator)
-   **App Launch Time**: ≤3 seconds to main menu
-   **Dictionary Loading**: ≤2 seconds on first launch
-   **Grid Rendering**: 60fps minimum during tracing interactions
-   **Memory Usage**: ≤50MB for dictionary and game state
-   **Network Requests**:
    -   Daily puzzle fetch: ≤5 seconds
    -   Analytics submission: ≤3 seconds (background operation)
-   **Multiplayer Performance**:
    -   Room creation/joining: ≤2 seconds
    -   WebSocket message latency: ≤100ms
    -   State synchronization: ≤200ms
    -   Reconnection time: ≤5 seconds

### 11.3 Storage

-   **Local Storage**: Puzzle progress, user preferences, drafts
-   **Cloud Sync**: Optional for puzzle submissions and daily puzzles
-   **Offline Mode**: Full gameplay without internet connection (single-player only)

### 11.4 Networking (Multiplayer)

-   **WebSocket Connections**: Real-time bidirectional communication
-   **Connection Management**: Automatic reconnection with exponential backoff
-   **State Synchronization**: Conflict resolution for simultaneous actions
-   **Latency Handling**: Predictive UI updates with server reconciliation
-   **Bandwidth Optimization**: Efficient event serialization and compression

### 11.6 Development Workflow

-   **Primary IDE**: VS Code for logic development
-   **UI Development**: Xcode for SwiftUI interfaces and previews
-   **Testing**: Unit tests for game logic, UI tests for interactions

## 12. Acceptance Criteria

### 12.1 Core Gameplay

-   [ ] Player can trace words by dragging finger across adjacent letters
-   [ ] Valid words are added to found list and scored appropriately
-   [ ] Invalid words trigger shake animation and clear selection
-   [ ] All three difficulty modes function as specified
-   [ ] Hint system activates at correct completion percentages

### 12.2 Builder Mode

-   [ ] Can create grids from 3x3 to 6x6
-   [ ] Real-time word count updates as grid changes
-   [ ] Can save drafts locally
-   [ ] Can submit puzzles to server
-   [ ] Word enable/disable functionality works

### 12.5 Technical

-   [ ] App works offline for local puzzles
-   [ ] Daily puzzles download and cache properly
-   [ ] Analytics data submits correctly
-   [ ] All accessibility features function properly
-   [ ] Performance remains smooth on supported devices
-   [ ] App works offline for local puzzles
-   [ ] Daily puzzles download and cache properly
-   [ ] Analytics data submits correctly
-   [ ] All accessibility features function properly
-   [ ] Performance remains smooth on supported devices

## 13. Future Considerations

### 13.1 Version 2 Features

-   Tournament modes with elimination brackets
-   Themed puzzle packs with curated word lists
-   Additional language support beyond English
-   Advanced social features (friend lists, leaderboards)
-   Spectator mode for competitive games
-   Team competitions (3v3, 4v4)

### 13.2 Monetization Opportunities

-   Premium puzzle packs
-   Remove ads option
-   Advanced builder features
-   Custom themes and visual styles
