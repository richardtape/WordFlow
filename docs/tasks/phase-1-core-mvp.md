# Phase 1: Core Single-Player MVP - Task List

## Phase Overview

**Goal**: Create a playable word search game with fundamental functionality
**Duration**: 2-3 weeks
**Deliverable**: A functional word game that users can play and complete puzzles

This phase establishes the core architecture and basic gameplay mechanics. Everything built here will be extended in future phases, so focus on clean, extensible code patterns.

---

## Technical Foundation

### Architecture Pattern

-   **MVVM (Model-View-ViewModel)** pattern with SwiftUI
-   **Single source of truth** for game state
-   **Reactive programming** using SwiftUI's state management
-   **Modular design** allowing easy extension for multiplayer features

### File Organization Structure

```
WordFlow/
├── App/
│   ├── WordFlowApp.swift          # App entry point
│   └── ContentView.swift          # Main navigation container
├── Models/                        # Data models and game logic
│   ├── GameModels.swift          # Core game data structures
│   ├── PuzzleData.swift          # Puzzle and grid definitions
│   └── Dictionary.swift          # Word validation and dictionary
├── Views/                         # SwiftUI view components
│   ├── Game/                     # Game-specific views
│   │   ├── GameView.swift        # Main game screen
│   │   ├── GridView.swift        # Word grid display
│   │   ├── LetterSquareView.swift # Individual letter squares
│   │   └── WordListView.swift    # Found words display
│   └── Shared/                   # Reusable UI components
│       ├── HeaderView.swift      # Common header component
│       └── ButtonStyles.swift    # Custom button styles
├── ViewModels/                   # Business logic and state management
│   ├── GameViewModel.swift       # Main game state manager
│   └── PuzzleViewModel.swift     # Puzzle-specific logic
├── Services/                     # Business logic services
│   ├── WordValidator.swift       # Word validation service
│   ├── ScoringService.swift      # Score calculation
│   └── PuzzleLoader.swift        # Puzzle loading logic
├── Utilities/                    # Helper functions and extensions
│   ├── Extensions.swift          # Swift/SwiftUI extensions
│   └── Constants.swift           # App-wide constants
└── Resources/                    # Static resources
    ├── Puzzles/                  # Built-in puzzle files
    │   └── puzzle-data.json      # Sample puzzle definitions
    └── Dictionary/               # Word lists
        └── words.txt             # Basic English word list
```

---

## Individual Tasks

### **Task 1: Project Structure Setup** **Task Complete**

**Context**: Establish the file organization that will support all future features
**Reference**: See file organization structure above and Technical Implementation section in `docs/project-specification.md`
**Future Considerations**: This structure will accommodate multiplayer views, server integration, and builder mode
**Dependencies**: None
**Complexity**: Simple

**Sub-tasks:**

-   [x] Create `Models/` folder and move/create model files
-   [x] Create `Views/` folder with `Game/` and `Shared/` subfolders
-   [x] Create `ViewModels/` folder for state management classes
-   [x] Create `Services/` folder for business logic services
-   [x] Create `Utilities/` folder for helpers and extensions
-   [x] Create `Resources/` folder with `Puzzles/` and `Dictionary/` subfolders
-   [x] Move existing `ContentView.swift` to `App/` folder
-   [x] Verify all folders are properly organized and visible in Xcode project navigator
-   [x] Update Xcode project references to new file locations

### **Task 2: Core Data Models**

**Context**: Define the fundamental data structures that represent puzzles, grids, and game state
**Reference**: See Data Models section in `docs/product-requirements-document.md` (Section 8.1-8.3)
**Future Considerations**: Models should support multiplayer synchronization and server serialization
**Dependencies**: Project structure setup
**Complexity**: Medium

**Sub-tasks:**

-   [x] Create `Models/GameModels.swift` file
-   [x] Define `GridCoordinate` struct (x: Int, y: Int)
-   [x] Define `LetterSquare` struct (letter: String, coordinate: GridCoordinate, state: SquareState)
-   [x] Define `SquareState` enum (normal, selected, traced, faded, blank)
-   [x] Define `SolutionWord` struct (word: String, path: [GridCoordinate])
-   [x] Define `Grid` struct (size: GridSize, squares: [LetterSquare])
-   [x] Define `GridSize` struct (width: Int, height: Int)
-   [x] Define `FoundWord` struct (word: String, path: [GridCoordinate], score: Int, foundAt: Date)
-   [x] Define `GameState` struct (puzzle: Puzzle, grid: Grid, foundWords: [FoundWord], score: Int, isComplete: Bool, startTime: Date)
-   [x] Add `Codable` conformance to all models for JSON serialization
-   [x] Create computed properties (e.g., `GameState.isComplete`)

### **Task 3: Dictionary Service Implementation**

**Context**: Create word validation system using a basic English word list
**Reference**: See Word Rules & Dictionary section in `docs/product-requirements-document.md` (Section 4.3)
**Future Considerations**: Will be extended to support multiple dictionaries and Scrabble word lists
**Dependencies**: Core data models
**Complexity**: Simple

**Sub-tasks:**

-   [x] Create `Services/WordValidator.swift` file
-   [x] Create `WordValidator` class with singleton pattern
-   [x] Implement `loadDictionary()` method to read from words.txt
-   [x] Create `Set<String>` for fast word lookup
-   [x] Implement `isValidWord(_ word: String) -> Bool` method
-   [x] Add case-insensitive word checking
-   [x] Implement minimum word length filtering (configurable, default 4)
-   [x] Add error handling for missing/corrupted dictionary file
-   [x] Add logging for dictionary loading success/failure

### **Task 4: Basic Word List Resource**

**Context**: Provide initial dictionary for word validation
**Reference**: See Word Rules & Dictionary section in `docs/product-requirements-document.md`
**Future Considerations**: Will be replaced with comprehensive Scrabble dictionary
**Dependencies**: Resources folder structure
**Complexity**: Simple

**Sub-tasks:**

-   [x] Create `Resources/Dictionary/words.txt` file
-   [x] Curate 1000+ common English words (3-8 letters)
-   [x] Ensure all words are family-friendly (no offensive content)
-   [x] Format as one word per line, lowercase
-   [x] Include common word variants (plurals, past tense)
-   [x] Test word list loads properly in app
-   [x] Verify word validation works with sample words
-   [x] Document word list source and criteria used

### **Task 5: Sample Puzzle Data**

**Context**: Create test puzzles for development and initial user experience
**Reference**: See Puzzle Structure in `docs/product-requirements-document.md` (Section 8.1)
**Future Considerations**: Format should match server-delivered puzzle structure
**Dependencies**: Core data models
**Complexity**: Medium

**Sub-tasks:**

-   [x] Create `Resources/Puzzles/puzzle-data.json` file
-   [x] Design 3x3 grid puzzle with 20 words
-   [ ] Design 4x4 grid puzzle with 10-12 words
-   [ ] Design 5x5 grid puzzle with 15-18 words
-   [x] Ensure every letter in each grid is used at least once
-   [x] Verify all words exist in dictionary
-   [x] Test word path connectivity (adjacent letters only)
-   [x] Add puzzle metadata (title)
-   [x] Validate JSON structure matches data models
-   [x] Create puzzle validation script/test

### **Task 6: Puzzle Loading Service**

**Context**: Load puzzle data from resources and validate structure
**Reference**: See Puzzle Management section in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will be extended to load from server API
**Dependencies**: Sample puzzle data, core data models
**Complexity**: Simple

**Sub-tasks:**

-   [x] Create `Services/PuzzleLoader.swift` file
-   [x] Create `PuzzleLoader` class with a singleton instance
-   [x] Implement `loadPuzzles(from: String)` method
-   [x] Add JSON parsing with error handling
-   [x] Implement puzzle structure validation via `Codable`
-   [x] Verify all words in puzzle are valid (using WordValidator)
-   [x] Check letter connectivity requirements
-   [ ] Add `loadRandomPuzzle()` method
-   [ ] Add `loadPuzzleByIndex(_ index: Int)` method
-   [x] Create comprehensive error types for different failure modes

### **Task 7: Individual Letter Square Component**

**Context**: Create reusable component for displaying single letters in the grid
**Reference**: See Grid Display section in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will support hint numbers and multiplayer highlighting
**Dependencies**: Core data models
**Complexity**: Simple

**Sub-tasks:**

-   [x] Create `Views/Game/LetterSquareView.swift` file
-   [x] Define SwiftUI view struct conforming to View protocol
-   [x] Add `letter: String` property for display
-   [x] Add `state: SquareState` property for visual state
-   [x] Implement base square styling (size, colors, typography)
-   [x] Add state-specific styling (normal, selected, traced, faded)
-   [x] Use SF Pro font family as specified in PRD
-   [x] Make square size configurable via parameter
-   [x] Add smooth animations for state transitions
-   [x] Test on different device sizes and orientations

### **Task 8: Grid Layout Component**

**Context**: Arrange letter squares in responsive grid layout
**Reference**: See Grid Display section in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will support multiplayer cursor display and animations
**Dependencies**: LetterSquareView component
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Game/GridView.swift` file
-   [ ] Use SwiftUI `LazyVGrid` for grid layout
-   [ ] Calculate grid columns based on puzzle size
-   [ ] Implement responsive square sizing for different screen sizes
-   [ ] Add proper spacing and padding for touch targets (60x60pt iPhone, 80x80pt iPad)
-   [ ] Ensure grid maintains aspect ratio on rotation
-   [ ] Add grid border and styling
-   [ ] Test layouts for 3x3, 4x4, 5x5, and 6x6 grids
-   [ ] Optimize for different iOS device screen sizes
-   [ ] Add accessibility labels for VoiceOver support

### **Task 9: Basic Touch Gesture Recognition**

**Context**: Detect finger movement across grid squares for word tracing
**Reference**: See Game Interface section in `docs/product-requirements-document.md` (Section 4.2)
**Future Considerations**: Will be extended for multiplayer real-time sharing
**Dependencies**: Grid layout component
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Add `DragGesture` to GridView for touch detection
-   [ ] Implement `onChanged` handler to track finger movement
-   [ ] Calculate which grid square finger is currently over
-   [ ] Implement adjacency checking (8-directional: horizontal, vertical, diagonal)
-   [ ] Add logic to prevent reusing same square in one trace
-   [ ] Implement backtracking (remove letters when finger moves backward)
-   [ ] Add `onEnded` handler for gesture completion
-   [ ] Create visual feedback during tracing (highlight path)
-   [ ] Handle gesture cancellation when finger leaves grid area
-   [ ] Add haptic feedback for square selection
-   [ ] Test gesture accuracy on different device sizes

### **Task 10: Word Path Validation**

**Context**: Ensure traced paths follow adjacency rules and form valid words
**Reference**: See Game Mechanics section in `docs/product-requirements-document.md` (Section 2.1-2.3)
**Future Considerations**: Will support multiplayer conflict resolution
**Dependencies**: Touch gesture recognition, dictionary service
**Complexity**: Medium

**Sub-tasks:**

-   [x] Create path validation logic in GameViewModel
-   [x] Implement adjacency verification for coordinate pairs
-   [x] Add duplicate square detection within single path
-   [ ] Integrate with WordValidator for dictionary checking
-   [x] Create minimum word length checking (configurable, default 4)
-   [x] Add path-to-string conversion logic
-   [x] Implement invalid word feedback system
-   [x] Add word already found detection
-   [ ] Create comprehensive validation error types
-   [ ] Test edge cases (single letter, maximum length words)

### **Task 11: Visual Word Tracing Feedback**

**Context**: Show user's current word selection with visual indicators
**Reference**: See Active Tracing in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will show multiple players' traces in different colors
**Dependencies**: Touch gesture recognition, letter square component
**Complexity**: Medium

**Sub-tasks:**

-   [x] Update LetterSquareView to show selected state
-   [x] Implement highlighting for currently traced letters (system blue background)
-   [ ] Add connecting line/path between selected letters
-   [ ] Use smooth curved paths with 3pt stroke width
-   [x] Implement real-time visual updates during tracing
-   [x] Add animation for letter selection/deselection
-   [ ] Show traced path with 50% opacity
-   [x] Clear visual state when word is completed or cancelled
-   [ ] Test visual feedback on different background colors
-   [ ] Ensure accessibility with high contrast mode

### **Task 12: Found Words Display**

**Context**: Show list of successfully discovered words
**Reference**: See Word List section in `docs/product-requirements-document.md` (Section 4.2)
**Future Considerations**: Will show which player found each word in multiplayer
**Dependencies**: Word validation logic
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Views/Game/WordListView.swift` file
-   [ ] Design scrollable list for found words
-   [ ] Display word with length in parentheses
-   [ ] Show individual word scores
-   [ ] Use chronological ordering (newest first or last)
-   [ ] Add visual styling matching iOS design system
-   [ ] Implement smooth list animations for new words
-   [ ] Handle empty state (no words found yet)
-   [ ] Test scrolling behavior with many words
-   [ ] Add accessibility support for word list

### **Task 13: Basic Scoring System**

**Context**: Calculate and display player score based on word discovery
**Reference**: See Scoring System section in `docs/product-requirements-document.md` (Section 5.1)
**Future Considerations**: Will support bonus scoring and multiplayer score comparison
**Dependencies**: Word validation
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Services/ScoringService.swift` file
-   [ ] Implement exponential scoring formula: `basePoints * (2^(length-3))`
-   [ ] Set basePoints = 100 as specified
-   [ ] Create `calculateWordScore(_ word: String) -> Int` method
-   [ ] Add running total score calculation
-   [ ] Create score display component
-   [ ] Add score animation when new words are found
-   [ ] Test scoring accuracy for different word lengths
-   [ ] Add score persistence between puzzle sessions
-   [ ] Document scoring formula for future reference

### **Task 14: Game State Management**

**Context**: Coordinate overall game flow and state transitions
**Reference**: See Game State section in `docs/product-requirements-document.md` (Section 8.2)
**Future Considerations**: Will manage multiplayer synchronization and server communication
**Dependencies**: All previous game components
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `ViewModels/GameViewModel.swift` file
-   [ ] Make GameViewModel conform to ObservableObject
-   [ ] Add @Published properties for reactive UI updates
-   [ ] Implement puzzle loading and initialization
-   [ ] Create word discovery handling pipeline
-   [ ] Add game completion detection logic
-   [ ] Implement new puzzle loading functionality
-   [ ] Add error state management
-   [ ] Create clean state reset methods
-   [ ] Add timer functionality for future use
-   [ ] Implement progress tracking (percentage complete)
-   [ ] Add game session statistics tracking

### **Task 15: Main Game Screen Layout**

**Context**: Combine all components into playable game interface
**Reference**: See Game Interface section in `docs/product-requirements-document.md` (Section 4.2)
**Future Considerations**: Will accommodate multiplayer UI elements and chat
**Dependencies**: All view components, game state management
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Game/GameView.swift` file
-   [ ] Design main game screen layout using VStack/HStack
-   [ ] Position grid in center of screen
-   [ ] Add score display in prominent location
-   [ ] Position word list in accessible but non-intrusive area
-   [ ] Implement responsive layout for different screen sizes
-   [ ] Add proper padding and spacing throughout
-   [ ] Test layout on iPhone and iPad
-   [ ] Ensure layout works in portrait and landscape
-   [ ] Add navigation bar with game options
-   [ ] Test with different dynamic type sizes

### **Task 16: Simple Game Completion Flow**

**Context**: Detect when puzzle is complete and show completion state
**Reference**: See Puzzle Complete section in `docs/product-requirements-document.md` (Section 4.3)
**Future Considerations**: Will integrate with server analytics and multiplayer victory conditions
**Dependencies**: Game state management
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Add completion detection in GameViewModel
-   [ ] Calculate completion percentage based on found vs required words
-   [ ] Trigger completion when all words are found
-   [ ] Create completion overlay/modal view
-   [ ] Display final score and completion time
-   [ ] Add celebration animation or visual effect
-   [ ] Play completion sound effect (system sound)
-   [ ] Add "New Puzzle" button functionality
-   [ ] Clear game state properly when starting new puzzle
-   [ ] Add completion statistics display

### **Task 17: App Navigation Structure**

**Context**: Set up basic app navigation to support current and future screens
**Reference**: See Navigation structure implied in `docs/project-specification.md`
**Future Considerations**: Will support complex navigation for multiplayer, builder, settings
**Dependencies**: Main game screen
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Update `App/ContentView.swift` with NavigationStack
-   [ ] Create simple navigation to game screen
-   [ ] Add temporary main menu with "Play Game" option
-   [ ] Implement proper back navigation handling
-   [ ] Add navigation state management
-   [ ] Create placeholder menu items for future features
-   [ ] Test navigation flow and state preservation
-   [ ] Add navigation animations and transitions
-   [ ] Ensure navigation follows iOS design guidelines
-   [ ] Test navigation accessibility with VoiceOver

---

## Testing & Validation

### Manual Testing Procedures

**Game Flow Testing:**

1. Launch app and navigate to game screen
2. Load different sample puzzles successfully
3. Trace valid words and verify they're detected
4. Attempt invalid words and verify rejection
5. Complete entire puzzle and verify completion state

**Grid Interaction Testing:**

1. Test tracing on different grid sizes (3x3, 4x4, 5x5)
2. Verify adjacency rules (8-directional movement)
3. Test backtracking during word selection
4. Verify visual feedback during tracing
5. Test gesture cancellation (lifting finger)

**Edge Case Testing:**

1. Very short words (2-3 letters)
2. Maximum length words for each grid size
3. Words using same letters in different paths
4. Invalid JSON puzzle data handling
5. Missing dictionary file handling

### Success Criteria for Phase Completion

-   [ ] Can load and display multiple test puzzles
-   [ ] Word tracing works smoothly on all supported grid sizes
-   [ ] All valid words are detected and scored correctly
-   [ ] Invalid word attempts provide appropriate feedback
-   [ ] Game completion is detected and displayed properly
-   [ ] App performance remains smooth during gameplay
-   [ ] Code architecture supports future feature additions

---

## Handoff to Next Phase

### What Should Be Working

-   Complete single-player word game with basic functionality
-   Clean, modular code architecture ready for extension
-   Reliable word validation and scoring systems
-   Responsive UI working across iOS devices

### Architecture Decisions Enabling Phase 2

-   **MVVM pattern** established for easy hint system integration
-   **Reactive state management** ready for progressive hint triggers
-   **Modular UI components** ready for settings and tutorial integration
-   **Service layer** ready for difficulty mode variations

### Known Technical Debt

-   Basic word list should be replaced with comprehensive dictionary
-   Hard-coded styling should be moved to design system
-   Error handling could be more comprehensive
-   Performance optimization not yet implemented

### Code Quality Standards

-   All SwiftUI views should be composable and reusable
-   State management should be centralized in ViewModels
-   Business logic should be separated from UI code
-   File organization should be maintained for easy navigation
