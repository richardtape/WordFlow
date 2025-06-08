# WordFlow

A unique word search puzzle game for iOS where players trace connected letters in any direction to form words.

## 🎮 Game Features

### Single Player Modes

-   **Beginner**: Full hints and guidance for new players
-   **Normal**: Progressive hint system that reveals more as you progress
-   **Hardcore**: No hints, maximum challenge

### Multiplayer Modes

-   **Cooperative**: Work together with a partner to solve puzzles remotely
-   **Competitive**: Race against friends to complete identical puzzles

### Builder Mode

-   Create custom puzzles with grids from 3x3 to 6x6
-   Real-time word validation and analysis
-   Submit puzzles to the community

## 🔧 Technical Stack

-   **Platform**: iOS (Native Swift)
-   **UI Framework**: SwiftUI
-   **Backend**: Node.js server for multiplayer and daily puzzles
-   **Real-time Communication**: WebSockets for multiplayer functionality

## 📁 Project Structure

```
WordFlow/
├── docs/                    # Documentation
├── WordFlow/               # iOS app source code
├── server/                 # Node.js backend (future)
└── README.md              # This file
```

## 🏗️ Development Setup

1. **Requirements**: Xcode 16.2+, iOS 18.2+
2. **Primary Development**: VS Code/Cursor for logic
3. **UI Development**: Xcode for SwiftUI interfaces and testing

## 📋 Current Status

🚧 **In Development** - Project setup phase

## 🎯 Core Game Mechanics

-   **Unique Pathfinding**: Words can be formed by connecting letters in any direction (not just straight lines)
-   **Complete Grid Usage**: Every letter in the grid is used in at least one word
-   **Progressive Difficulty**: Exponential scoring system rewards longer words
-   **Real-time Multiplayer**: Seamless cooperative and competitive gameplay

## 📄 Documentation

-   [Product Requirements Document](docs/PRD.md) - Complete feature specifications
-   [Development Plan](docs/development-plan.md) - Implementation roadmap (coming soon)

---

**Created with ❤️ for Penny Crayon 💃**
