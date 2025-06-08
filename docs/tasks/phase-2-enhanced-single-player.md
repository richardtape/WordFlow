# Phase 2: Enhanced Single-Player Experience - Task List

## Phase Overview

**Goal**: Complete the single-player experience with all features and polish
**Duration**: 2-3 weeks
**Deliverable**: Polished single-player game ready for user testing and feedback

This phase transforms the basic MVP into a complete single-player experience with three difficulty modes, progressive hints, tutorial system, and comprehensive accessibility features. The architecture established here will support multiplayer features in later phases.

---

## Technical Foundation

### Enhanced Architecture Patterns

-   **Strategy Pattern** for difficulty mode implementations
-   **Observer Pattern** for hint system triggers based on progress
-   **State Management** expansion for user preferences and settings
-   **Progressive Disclosure** UI patterns for hint revelation

### File Organization Extensions

```
WordFlow/
├── App/
│   ├── WordFlowApp.swift
│   └── ContentView.swift
├── Models/
│   ├── GameModels.swift (existing)
│   ├── PuzzleData.swift (existing)
│   ├── Dictionary.swift (existing)
│   ├── DifficultyMode.swift        # NEW: Difficulty mode definitions
│   ├── HintSystem.swift           # NEW: Hint system models
│   └── UserPreferences.swift      # NEW: Settings and preferences
├── Views/
│   ├── Game/
│   │   ├── GameView.swift (existing)
│   │   ├── GridView.swift (existing)
│   │   ├── LetterSquareView.swift (existing)
│   │   ├── WordListView.swift (existing)
│   │   ├── HintOverlayView.swift   # NEW: Hint number display
│   │   └── ProgressIndicatorView.swift # NEW: Progress tracking
│   ├── Tutorial/                   # NEW: Tutorial system
│   │   ├── TutorialView.swift
│   │   ├── TutorialStepView.swift
│   │   └── OnboardingView.swift
│   ├── Settings/                   # NEW: Settings screens
│   │   ├── SettingsView.swift
│   │   ├── DifficultySelectionView.swift
│   │   └── AccessibilitySettingsView.swift
│   └── Shared/
│       ├── HeaderView.swift (existing)
│       ├── ButtonStyles.swift (existing)
│       └── AnimationViews.swift    # NEW: Reusable animations
├── ViewModels/
│   ├── GameViewModel.swift (existing)
│   ├── PuzzleViewModel.swift (existing)
│   ├── HintViewModel.swift         # NEW: Hint system logic
│   ├── TutorialViewModel.swift     # NEW: Tutorial flow
│   └── SettingsViewModel.swift     # NEW: Settings management
├── Services/
│   ├── WordValidator.swift (existing)
│   ├── ScoringService.swift (existing)
│   ├── PuzzleLoader.swift (existing)
│   ├── HintService.swift           # NEW: Hint calculation logic
│   ├── AudioService.swift          # NEW: Sound effects
│   ├── AutoSaveService.swift       # NEW: Game state persistence
│   └── AccessibilityService.swift  # NEW: Accessibility helpers
├── Utilities/
│   ├── Extensions.swift (existing)
│   ├── Constants.swift (existing)
│   └── UserDefaultsKeys.swift      # NEW: Settings storage keys
└── Resources/
    ├── Puzzles/ (existing)
    ├── Dictionary/ (existing)
    ├── Tutorial/                   # NEW: Tutorial content
    │   └── tutorial-puzzles.json
    └── Audio/                      # NEW: Sound effects
        ├── word-found.caf
        ├── invalid-word.caf
        └── puzzle-complete.caf
```

---

## Individual Tasks

### **Task 1: Difficulty Mode System Foundation**

**Context**: Implement the three difficulty modes that control hint visibility and game behavior
**Reference**: See Game Modes section in `docs/product-requirements-document.md` (Section 3.1.1-3.1.3)
**Future Considerations**: Will integrate with multiplayer mode selection and server-side game configuration
**Dependencies**: Phase 1 completion
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Models/DifficultyMode.swift` file
-   [ ] Define `DifficultyMode` enum (beginner, normal, hardcore)
-   [ ] Create `DifficultySettings` struct with hint configuration
-   [ ] Define hint timing thresholds (10%, 35%, 50% completion triggers)
-   [ ] Add auto-save enabled/disabled flag per difficulty
-   [ ] Create reveal word hint availability rules
-   [ ] Add timer behavior configuration (disabled, continues, ends game)
-   [ ] Implement difficulty mode descriptions for UI
-   [ ] Add Codable conformance for settings persistence
-   [ ] Create difficulty validation logic

### **Task 2: Progressive Hint System Models**

**Context**: Define data structures for the hint system that shows word count indicators
**Reference**: See Grid Display hints in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will support multiplayer hint synchronization
**Dependencies**: Difficulty mode system
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Models/HintSystem.swift` file
-   [ ] Define `HintType` enum (wordCount, lengthBreakdown, letterStart, letterContain, fadeOut)
-   [ ] Create `HintState` struct tracking which hints are currently active
-   [ ] Define `LetterHint` struct (startCount: Int, containCount: Int)
-   [ ] Create `ProgressThreshold` enum with completion percentage triggers
-   [ ] Add hint visibility calculation methods
-   [ ] Create hint data caching structures for performance
-   [ ] Define hint animation state management
-   [ ] Add hint persistence for auto-save functionality
-   [ ] Create hint validation and consistency checking

### **Task 3: User Preferences and Settings Model**

**Context**: Create comprehensive settings system for user preferences
**Reference**: See Settings and Preferences in `docs/product-requirements-document.md` (Section 7.1-7.2)
**Future Considerations**: Will sync with server for user profiles in later phases
**Dependencies**: Difficulty mode system
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Models/UserPreferences.swift` file
-   [ ] Define `UserPreferences` class conforming to ObservableObject
-   [ ] Add default difficulty mode preference
-   [ ] Create sound effects enabled/disabled setting
-   [ ] Add haptic feedback preference
-   [ ] Define text size preference (small, medium, large, extraLarge)
-   [ ] Create color scheme preference (system, light, dark)
-   [ ] Add high contrast mode setting
-   [ ] Define tutorial completion tracking
-   [ ] Create auto-save preference override
-   [ ] Add first launch detection flag
-   [ ] Implement UserDefaults integration for persistence

### **Task 4: Hint Calculation Service**

**Context**: Calculate hint numbers for letter squares based on remaining words
**Reference**: See numerical hints description in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will be optimized for real-time multiplayer updates
**Dependencies**: Progressive hint system models
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Services/HintService.swift` file
-   [ ] Implement `calculateStartingLetterHints()` method
-   [ ] Create `calculateContainingLetterHints()` method
-   [ ] Add efficient word filtering for remaining words only
-   [ ] Implement letter position analysis for hint accuracy
-   [ ] Create hint caching for performance optimization
-   [ ] Add hint invalidation when words are found
-   [ ] Implement real-time hint recalculation
-   [ ] Create hint data validation methods
-   [ ] Add comprehensive unit tests for hint accuracy
-   [ ] Optimize hint calculation for larger grids (5x5, 6x6)

### **Task 5: Enhanced Letter Square with Hints**

**Context**: Extend letter squares to display hint numbers in corners
**Reference**: See hint numbers display in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will support multiplayer player indicators
**Dependencies**: Hint calculation service
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Update `Views/Game/LetterSquareView.swift` with hint display
-   [ ] Add optional hint number properties (startCount, containCount)
-   [ ] Implement bottom-left red number for word starts (12pt font, 4pt margins)
-   [ ] Add bottom-right gray number for word contains (secondary label color)
-   [ ] Create hint number background circles (white with 20% opacity, 2pt radius)
-   [ ] Add smooth animations for hint number appearance/disappearance
-   [ ] Implement hint number visibility based on difficulty mode
-   [ ] Add accessibility labels for hint numbers
-   [ ] Test hint number legibility on different backgrounds
-   [ ] Optimize hint number layout for different square sizes

### **Task 6: Hint Display Management**

**Context**: Coordinate hint visibility and updates across the game
**Reference**: See progressive hint system in `docs/product-requirements-document.md` (Section 3.1.2)
**Future Considerations**: Will integrate with multiplayer hint synchronization
**Dependencies**: Enhanced letter square with hints
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `ViewModels/HintViewModel.swift` file
-   [ ] Implement progress percentage calculation based on found words
-   [ ] Add hint visibility determination logic for each difficulty mode
-   [ ] Create hint state management with @Published properties
-   [ ] Implement hint trigger detection (10%, 35%, 50% thresholds)
-   [ ] Add hint data updates when words are found
-   [ ] Create hint animation coordination
-   [ ] Implement hint reset for new puzzles
-   [ ] Add hint state persistence for auto-save
-   [ ] Create comprehensive hint system testing

### **Task 7: Letter Fade-Out System**

**Context**: Fade letters that are no longer in any remaining words
**Reference**: See letter fade-out in `docs/product-requirements-document.md` (Section 4.1)
**Future Considerations**: Will sync fade state across multiplayer sessions
**Dependencies**: Hint display management
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Add fade state tracking to letter square models
-   [ ] Implement letter usage analysis for remaining words
-   [ ] Create fade detection logic when words are found
-   [ ] Update LetterSquareView with faded appearance (30% opacity, gray background)
-   [ ] Add smooth fade animations with proper timing
-   [ ] Integrate fade logic with hint calculations
-   [ ] Create fade state reset for new puzzles
-   [ ] Add accessibility support for faded letters
-   [ ] Test fade behavior across different difficulty modes
-   [ ] Optimize fade calculations for performance

### **Task 8: Audio Service and Sound Effects**

**Context**: Add audio feedback for game actions and achievements
**Reference**: See sound effects in `docs/product-requirements-document.md` (Section 4.3)
**Future Considerations**: Will support multiplayer sound coordination
**Dependencies**: User preferences model
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Services/AudioService.swift` file
-   [ ] Set up AVAudioPlayer for sound effect playback
-   [ ] Add sound effect resource files (word-found.caf, invalid-word.caf, puzzle-complete.caf)
-   [ ] Implement `playWordFoundSound()` method
-   [ ] Create `playInvalidWordSound()` method
-   [ ] Add `playPuzzleCompleteSound()` method
-   [ ] Integrate with user preferences for sound on/off
-   [ ] Add sound effect volume management
-   [ ] Create fallback to system sounds if custom sounds fail
-   [ ] Test audio on different devices and iOS versions
-   [ ] Add audio session management for proper behavior

### **Task 9: Auto-Save Service Implementation**

**Context**: Persist game state automatically during gameplay
**Reference**: See auto-save functionality in `docs/product-requirements-document.md` (Section 3.1)
**Future Considerations**: Will integrate with server sync for cross-device play
**Dependencies**: User preferences model
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Services/AutoSaveService.swift` file
-   [ ] Implement game state serialization to UserDefaults
-   [ ] Add automatic save triggers (word found, every 30 seconds)
-   [ ] Create game state restoration on app launch
-   [ ] Implement save state validation and error handling
-   [ ] Add difficulty mode integration (disabled in hardcore mode)
-   [ ] Create save state cleanup for completed puzzles
-   [ ] Add save state versioning for future compatibility
-   [ ] Implement save state debugging and diagnostics
-   [ ] Test save/restore across app lifecycle events

### **Task 10: Tutorial System Foundation**

**Context**: Create tutorial infrastructure and simple puzzle for onboarding
**Reference**: See Tutorial and Onboarding in `docs/product-requirements-document.md` (Section 6.1)
**Future Considerations**: Will include multiplayer tutorial in later phases
**Dependencies**: All core game components from Phase 1
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Resources/Tutorial/tutorial-puzzles.json` with simple 3x3 puzzle
-   [ ] Design tutorial puzzle with only 1-2 obvious words
-   [ ] Create `Models/TutorialStep.swift` for tutorial flow management
-   [ ] Implement `ViewModels/TutorialViewModel.swift` for tutorial state
-   [ ] Create `Views/Tutorial/TutorialView.swift` as main tutorial screen
-   [ ] Add step-by-step instruction overlay system
-   [ ] Implement tutorial completion tracking in user preferences
-   [ ] Create tutorial skip functionality
-   [ ] Add tutorial reset option in settings
-   [ ] Test tutorial flow with new users

### **Task 11: Tutorial Content and Instructions**

**Context**: Create guided instructions that teach word tracing mechanics
**Reference**: See tutorial requirements in `docs/product-requirements-document.md` (Section 6.1)
**Future Considerations**: Will be expanded for multiplayer features
**Dependencies**: Tutorial system foundation
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Tutorial/TutorialStepView.swift` for individual instruction steps
-   [ ] Design tutorial step: "Tap and drag to connect letters"
-   [ ] Create tutorial step: "Words can bend and turn, not just straight lines"
-   [ ] Add tutorial step: "Find the word 'CAT' to continue"
-   [ ] Implement tutorial completion detection
-   [ ] Create visual highlights and arrows for guidance
-   [ ] Add tutorial instruction text with clear, simple language
-   [ ] Implement tutorial progression logic
-   [ ] Create tutorial reset if user gets stuck
-   [ ] Test tutorial effectiveness with different user types

### **Task 12: Difficulty Mode Selection Interface**

**Context**: Allow users to choose difficulty before starting games
**Reference**: See mode selection in `docs/product-requirements-document.md` (Section 6.1)
**Future Considerations**: Will integrate with multiplayer room creation
**Dependencies**: Difficulty mode system, tutorial completion
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Settings/DifficultySelectionView.swift`
-   [ ] Design mode selection interface with clear descriptions
-   [ ] Add beginner mode description: "All hints shown, no time pressure"
-   [ ] Create normal mode description: "Hints appear as you progress"
-   [ ] Add hardcore mode description: "No hints, no saves, maximum challenge"
-   [ ] Implement mode selection persistence in user preferences
-   [ ] Create mode selection animations and visual feedback
-   [ ] Add mode recommendation for new users (after tutorial)
-   [ ] Integrate with game start flow
-   [ ] Test mode selection accessibility

### **Task 13: Settings Screen Implementation**

**Context**: Create comprehensive settings screen for user preferences
**Reference**: See Settings and Preferences in `docs/product-requirements-document.md` (Section 7.1-7.2)
**Future Considerations**: Will include multiplayer and server settings
**Dependencies**: User preferences model, audio service
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Settings/SettingsView.swift` file
-   [ ] Implement `ViewModels/SettingsViewModel.swift` for settings management
-   [ ] Add default difficulty mode selection
-   [ ] Create sound effects toggle switch
-   [ ] Add haptic feedback preference toggle
-   [ ] Implement text size selection (Small/Medium/Large/Extra Large)
-   [ ] Create color scheme selection (System/Light/Dark)
-   [ ] Add high contrast mode toggle
-   [ ] Create tutorial reset button
-   [ ] Add settings validation and error handling
-   [ ] Test settings persistence across app launches

### **Task 14: Accessibility Features Implementation**

**Context**: Implement comprehensive accessibility support
**Reference**: See Accessibility Settings in `docs/product-requirements-document.md` (Section 7.2)
**Future Considerations**: Will ensure multiplayer features are equally accessible
**Dependencies**: Settings screen, user preferences
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Services/AccessibilityService.swift` for accessibility helpers
-   [ ] Implement dynamic type support throughout the app
-   [ ] Add VoiceOver labels for all interactive elements
-   [ ] Create high contrast color alternatives
-   [ ] Implement reduced motion preferences
-   [ ] Add accessibility hints for complex gestures
-   [ ] Create alternative input methods for word tracing
-   [ ] Test with VoiceOver and Voice Control
-   [ ] Validate contrast ratios meet WCAG guidelines
-   [ ] Add accessibility testing to QA process

### **Task 15: Visual Polish and Animations**

**Context**: Add smooth animations and visual feedback throughout the app
**Reference**: See Feedback Systems in `docs/product-requirements-document.md` (Section 4.3)
**Future Considerations**: Animation system will support multiplayer visual effects
**Dependencies**: All UI components
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Shared/AnimationViews.swift` for reusable animations
-   [ ] Implement smooth word discovery animations (scale up 1.1x for 0.2 seconds)
-   [ ] Add invalid word shake animation (3 quick shakes, 0.5 second duration)
-   [ ] Create puzzle completion celebration animation
-   [ ] Add hint number appearance/disappearance animations
-   [ ] Implement letter fade-out smooth transitions
-   [ ] Create score increase animations
-   [ ] Add navigation transition animations
-   [ ] Implement loading state animations
-   [ ] Test animation performance on older devices

### **Task 16: Enhanced Progress Tracking**

**Context**: Show detailed progress information and statistics
**Reference**: See Progress Indicators in `docs/product-requirements-document.md` (Section 4.2)
**Future Considerations**: Will include multiplayer progress comparison
**Dependencies**: Hint system, visual polish
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Views/Game/ProgressIndicatorView.swift`
-   [ ] Implement percentage completion display
-   [ ] Add words found vs total words count
-   [ ] Create word length breakdown display (when appropriate for difficulty mode)
-   [ ] Add elapsed time tracking and display
-   [ ] Implement progress bar visual with smooth updates
-   [ ] Create progress statistics for completed puzzles
-   [ ] Add progress persistence for session restoration
-   [ ] Test progress accuracy across different puzzle sizes
-   [ ] Integrate with accessibility features

### **Task 17: Enhanced Game Flow Integration**

**Context**: Integrate all new features into a cohesive game experience
**Reference**: See complete game flow in `docs/product-requirements-document.md` (Sections 4.1-4.3)
**Future Considerations**: Game flow will accommodate multiplayer features
**Dependencies**: All previous Phase 2 tasks
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Update `ViewModels/GameViewModel.swift` with all new features
-   [ ] Integrate difficulty mode selection into game start flow
-   [ ] Add tutorial launch for first-time users
-   [ ] Implement settings screen navigation from game
-   [ ] Create seamless transitions between tutorial, game, and settings
-   [ ] Add proper state management for all features
-   [ ] Implement feature flag system for easy testing
-   [ ] Create comprehensive error handling for all new features
-   [ ] Add analytics hooks for feature usage tracking (prepare for Phase 4)
-   [ ] Test complete user flow from tutorial to game completion

---

## Testing & Validation

### Manual Testing Procedures

**Difficulty Mode Testing:**

1. Test each difficulty mode with different puzzles
2. Verify hint visibility follows progressive rules in Normal mode
3. Confirm no hints appear in Hardcore mode
4. Test auto-save behavior in each mode
5. Verify timer behavior differences

**Hint System Testing:**

1. Validate hint number accuracy for different puzzle states
2. Test hint appearance at correct completion percentages
3. Verify hint updates when words are found
4. Test letter fade-out when no remaining words use the letter
5. Confirm hint performance on larger grids

**Tutorial System Testing:**

1. Complete tutorial as a new user
2. Test tutorial skip functionality
3. Verify tutorial completion is remembered
4. Test tutorial reset from settings
5. Validate tutorial guidance clarity

**Accessibility Testing:**

1. Navigate entire app using VoiceOver
2. Test with different dynamic type sizes
3. Verify high contrast mode functionality
4. Test reduced motion preferences
5. Validate color contrast ratios

**Settings and Persistence Testing:**

1. Change settings and verify persistence across app launches
2. Test auto-save functionality in different scenarios
3. Verify sound effect toggles work correctly
4. Test settings changes during active gameplay
5. Validate settings reset functionality

### Success Criteria for Phase Completion

-   [ ] All three difficulty modes work correctly with appropriate hint behavior
-   [ ] Progressive hint system accurately shows word count indicators
-   [ ] Tutorial successfully teaches new users the game mechanics
-   [ ] Settings screen allows full customization of user preferences
-   [ ] Auto-save correctly preserves and restores game state
-   [ ] Sound effects enhance the game experience
-   [ ] Accessibility features make the game usable for users with disabilities
-   [ ] Visual animations and polish create a professional user experience
-   [ ] All features work seamlessly together without conflicts
-   [ ] Performance remains smooth with all features enabled

---

## Handoff to Next Phase

### What Should Be Working

-   Complete single-player experience with all difficulty modes
-   Comprehensive settings and accessibility support
-   Smooth tutorial flow for new users
-   Professional visual polish and audio feedback
-   Robust auto-save and preference persistence

### Architecture Decisions Enabling Phase 3

-   **Service layer architecture** ready for builder mode integration
-   **Settings system** prepared for builder mode preferences
-   **Tutorial framework** extensible for builder mode instructions
-   **Audio system** ready for builder mode feedback

### Known Technical Debt

-   Audio files are placeholder system sounds (should be custom)
-   Tutorial puzzle is very simple (could be more comprehensive)
-   Hint calculations could be optimized for better performance
-   Some animations may need fine-tuning based on user feedback

### Code Quality Standards

-   All features should be modular and independently testable
-   Settings changes should take effect immediately without app restart
-   Error handling should be comprehensive and user-friendly
-   Performance should remain smooth on older iOS devices
