# Phase 3: Builder Mode - Task List

## Phase Overview

**Goal**: Enable users to create and test custom puzzles locally
**Duration**: 2 weeks
**Deliverable**: Complete puzzle creation tools allowing users to build custom content

This phase adds comprehensive puzzle creation capabilities, transforming WordFlow from a puzzle consumer into a puzzle creation platform. Users can design grids, validate words, assess difficulty, and test their creations before sharing.

---

## Technical Foundation

### Builder Architecture Patterns

-   **Builder Pattern** for step-by-step puzzle construction
-   **Command Pattern** for undo/redo functionality in grid editing
-   **Factory Pattern** for puzzle validation and word analysis
-   **MVC separation** between builder UI, puzzle data, and validation logic

### File Organization Extensions

```
WordFlow/
├── App/ (existing)
├── Models/
│   ├── (existing Phase 1 & 2 models)
│   ├── BuilderModels.swift        # NEW: Builder-specific data structures
│   ├── PuzzleAnalysis.swift       # NEW: Word analysis and difficulty models
│   ├── ValidationResult.swift     # NEW: Puzzle validation results
│   └── DraftPuzzle.swift          # NEW: Local puzzle storage model
├── Views/
│   ├── Game/ (existing)
│   ├── Tutorial/ (existing)
│   ├── Settings/ (existing)
│   ├── Builder/                   # NEW: Puzzle creation interface
│   │   ├── BuilderView.swift      # Main builder screen
│   │   ├── GridEditorView.swift   # Interactive grid editor
│   │   ├── LetterInputView.swift  # Letter placement interface
│   │   ├── WordAnalysisView.swift # Word discovery results
│   │   ├── DifficultyIndicatorView.swift # Difficulty assessment display
│   │   ├── PuzzlePreviewView.swift # Test puzzle interface
│   │   ├── WordManagementView.swift # Enable/disable words
│   │   └── SavePuzzleView.swift   # Save and export interface
│   └── Shared/ (existing)
├── ViewModels/
│   ├── (existing Phase 1 & 2 view models)
│   ├── BuilderViewModel.swift     # NEW: Main builder state management
│   ├── GridEditorViewModel.swift  # NEW: Grid editing logic
│   ├── WordAnalysisViewModel.swift # NEW: Word discovery coordination
│   └── PuzzleValidationViewModel.swift # NEW: Validation results
├── Services/
│   ├── (existing Phase 1 & 2 services)
│   ├── WordDiscoveryService.swift # NEW: Find all possible words
│   ├── DifficultyCalculationService.swift # NEW: Puzzle difficulty assessment
│   ├── PuzzleValidationService.swift # NEW: Validation logic
│   ├── DraftStorageService.swift  # NEW: Local puzzle persistence
│   └── PuzzleExportService.swift  # NEW: Export for sharing/submission
├── Utilities/
│   ├── (existing utilities)
│   ├── GridAlgorithms.swift       # NEW: Grid analysis algorithms
│   └── PuzzleConstants.swift      # NEW: Builder-specific constants
└── Resources/
    ├── (existing resources)
    └── Builder/                   # NEW: Builder templates and examples
        ├── example-grids.json     # Example grid layouts
        └── builder-tutorial.json  # Builder mode tutorial
```

---

## Individual Tasks

### **Task 1: Builder Data Models**

**Context**: Define data structures for puzzle creation and analysis
**Reference**: See Builder Mode section in `docs/product-requirements-document.md` (Section 3.3)
**Future Considerations**: Models will support server submission and sharing in Phase 4
**Dependencies**: Phase 2 completion
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Models/BuilderModels.swift` file
-   [ ] Define `GridEditorState` struct for tracking edit mode (letter, blank, erase)
-   [ ] Create `BuilderGrid` class extending base Grid with edit capabilities
-   [ ] Define `GridCell` struct (content: String?, isBlank: Bool, isSelected: Bool)
-   [ ] Create `BuilderAction` enum for undo/redo (placeLetter, removeCell, toggleBlank)
-   [ ] Define `BuilderHistory` class for undo/redo stack management
-   [ ] Add `PuzzleMetadata` struct (title, creator, difficulty, tags, description)
-   [ ] Create `BuilderPreferences` struct (defaultGridSize, autoValidate, showHints)
-   [ ] Implement Codable conformance for all builder models
-   [ ] Add validation constraints (3x3 minimum, 6x6 maximum grid size)

### **Task 2: Word Discovery Algorithm**

**Context**: Implement comprehensive word finding algorithm for puzzle analysis
**Reference**: See Builder Mode word analysis in `docs/product-requirements-document.md` (Section 10.2)
**Future Considerations**: Algorithm will be optimized for server-side analysis
**Dependencies**: Builder data models
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Services/WordDiscoveryService.swift` file
-   [ ] Implement depth-first search algorithm for word discovery
-   [ ] Create `findAllWords(in grid: BuilderGrid)` method
-   [ ] Add 8-directional adjacency checking (horizontal, vertical, diagonal)
-   [ ] Implement path tracking to prevent letter reuse within single word
-   [ ] Create word validation integration with dictionary service
-   [ ] Add minimum/maximum word length filtering
-   [ ] Implement performance optimization for larger grids (caching, pruning)
-   [ ] Create comprehensive word analysis result structure
-   [ ] Add progress reporting for long-running analysis
-   [ ] Implement word discovery cancellation for UI responsiveness

### **Task 3: Puzzle Analysis and Difficulty Assessment**

**Context**: Analyze puzzle characteristics and calculate difficulty score
**Reference**: See Difficulty Assessment Algorithm in `docs/server-specification.md` (Section 10.4)
**Future Considerations**: Will match server-side difficulty calculation
**Dependencies**: Word discovery algorithm
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Models/PuzzleAnalysis.swift` file
-   [ ] Define `PuzzleAnalysis` struct with comprehensive metrics
-   [ ] Create `Services/DifficultyCalculationService.swift` file
-   [ ] Implement word count analysis (total words, by length)
-   [ ] Add average word length calculation
-   [ ] Create uncommon letter detection (Q, X, Z, J frequency analysis)
-   [ ] Implement grid utilization percentage calculation
-   [ ] Add difficulty score formula: `(wordCount * 0.3) + (avgWordLength * 0.25) + (uncommonLetters * 0.2) + (gridUtilization * 0.25)`
-   [ ] Create difficulty tier classification (Easy: 0-30, Medium: 31-60, Hard: 61-90, Expert: 91+)
-   [ ] Add letter usage analysis (ensure all letters are used)
-   [ ] Implement word overlap analysis for complexity assessment

### **Task 4: Grid Editor Interface**

**Context**: Create interactive grid editing interface for letter placement
**Reference**: See Builder Mode interface in `docs/product-requirements-document.md` (Section 10.1)
**Future Considerations**: Will support collaborative editing in multiplayer builder mode
**Dependencies**: Builder data models
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Views/Builder/GridEditorView.swift` file
-   [ ] Implement grid size selection (3x3 to 6x6) with dynamic layout
-   [ ] Create `Views/Builder/LetterInputView.swift` for letter placement tools
-   [ ] Add edit mode toolbar (Letter, Blank, Erase modes)
-   [ ] Implement tap-to-edit grid cell functionality
-   [ ] Create letter input popup with keyboard integration
-   [ ] Add blank cell toggle functionality
-   [ ] Implement cell selection and multi-select capabilities
-   [ ] Create visual feedback for different cell states (letter, blank, selected)
-   [ ] Add undo/redo buttons with keyboard shortcut support
-   [ ] Implement grid clear and reset functionality

### **Task 5: Letter Input and Keyboard Integration**

**Context**: Provide intuitive letter input methods for grid creation
**Reference**: See grid editor requirements in `docs/product-requirements-document.md` (Section 10.1)
**Future Considerations**: Will support voice input and accessibility features
**Dependencies**: Grid editor interface
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Enhance `LetterInputView` with multiple input methods
-   [ ] Add on-screen keyboard integration for letter input
-   [ ] Implement hardware keyboard support for rapid editing
-   [ ] Create letter picker interface for touch-friendly input
-   [ ] Add automatic uppercase conversion for consistency
-   [ ] Implement input validation (single letters only, A-Z)
-   [ ] Create batch input mode for filling multiple cells
-   [ ] Add letter suggestion based on common letter patterns
-   [ ] Implement input history and quick letter access
-   [ ] Create accessibility support for letter input (VoiceOver)

### **Task 6: Real-time Word Analysis Display**

**Context**: Show word discovery results as grid is being edited
**Reference**: See real-time word checking in `docs/product-requirements-document.md` (Section 10.2)
**Future Considerations**: Will include collaborative analysis in multiplayer builder
**Dependencies**: Word discovery algorithm
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Builder/WordAnalysisView.swift` file
-   [ ] Implement `ViewModels/WordAnalysisViewModel.swift` for state management
-   [ ] Add real-time word discovery trigger on grid changes
-   [ ] Create word list display with categorization (by length)
-   [ ] Implement word count summary (total, by length breakdown)
-   [ ] Add discovery progress indicator for long-running analysis
-   [ ] Create word validity indicators (valid/invalid/questionable)
-   [ ] Implement word filtering and search functionality
-   [ ] Add word detail view showing path through grid
-   [ ] Create analysis caching to avoid repeated calculations

### **Task 7: Difficulty Assessment Display**

**Context**: Show calculated difficulty metrics and recommendations
**Reference**: See difficulty assessment in `docs/server-specification.md` (Section 10.4)
**Future Considerations**: Will match server-side difficulty display
**Dependencies**: Puzzle analysis and difficulty assessment
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Create `Views/Builder/DifficultyIndicatorView.swift` file
-   [ ] Implement visual difficulty meter with color coding
-   [ ] Add difficulty tier display (Easy/Medium/Hard/Expert)
-   [ ] Create detailed metrics display (word count, avg length, etc.)
-   [ ] Implement difficulty score breakdown explanation
-   [ ] Add recommendations for improving puzzle difficulty
-   [ ] Create difficulty comparison with existing puzzles
-   [ ] Implement difficulty target setting for creators
-   [ ] Add visual indicators for difficulty factors
-   [ ] Create difficulty history tracking for iterations

### **Task 8: Puzzle Validation Service**

**Context**: Comprehensive validation to ensure puzzle quality and playability
**Reference**: See Puzzle Validation in `docs/product-requirements-document.md` (Section 10.3)
**Future Considerations**: Will match server-side validation requirements
**Dependencies**: Word discovery, difficulty assessment
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Models/ValidationResult.swift` file
-   [ ] Define `ValidationError` enum (insufficient words, unused letters, invalid grid, etc.)
-   [ ] Create `Services/PuzzleValidationService.swift` file
-   [ ] Implement minimum word count validation (varies by grid size)
-   [ ] Add all letters used validation (every letter in at least one word)
-   [ ] Create grid connectivity validation (no isolated letter regions)
-   [ ] Implement word path validation (all words traceable with adjacency rules)
-   [ ] Add duplicate word detection
-   [ ] Create content appropriateness validation using word filters
-   [ ] Implement grid size and shape validation
-   [ ] Add comprehensive validation reporting with specific error locations

### **Task 9: Word Management Interface**

**Context**: Allow creators to enable/disable specific words found in their puzzle
**Reference**: See word management in `docs/product-requirements-document.md` (Section 10.2)
**Future Considerations**: Will support server-side word approval workflows
**Dependencies**: Real-time word analysis
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Builder/WordManagementView.swift` file
-   [ ] Implement word list with enable/disable toggles
-   [ ] Add word categorization (required, optional, bonus)
-   [ ] Create word difficulty indicators (common/uncommon/rare)
-   [ ] Implement bulk word management (enable/disable by category)
-   [ ] Add word search and filtering capabilities
-   [ ] Create word path highlighting when selected
-   [ ] Implement word statistics update when toggling words
-   [ ] Add undo/redo support for word management changes
-   [ ] Create word management presets (conservative, moderate, inclusive)

### **Task 10: Puzzle Preview and Testing Mode**

**Context**: Allow creators to test their puzzles before saving
**Reference**: See puzzle testing in `docs/product-requirements-document.md` (Section 10.3)
**Future Considerations**: Will support multiplayer testing sessions
**Dependencies**: Word management, puzzle validation
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Builder/PuzzlePreviewView.swift` file
-   [ ] Implement full game interface within builder mode
-   [ ] Add test mode toggle that switches to player view
-   [ ] Create test session state management (separate from main game)
-   [ ] Implement word discovery testing with immediate feedback
-   [ ] Add test completion detection and statistics
-   [ ] Create test mode reset functionality
-   [ ] Implement test performance metrics (time to complete, words found order)
-   [ ] Add test mode accessibility features
-   [ ] Create test results analysis and recommendations

### **Task 11: Draft Puzzle Storage Service**

**Context**: Save and manage puzzle drafts locally during creation process
**Reference**: See local puzzle storage in `docs/product-requirements-document.md` (Section 10.1)
**Future Considerations**: Will sync with server storage in Phase 4
**Dependencies**: Builder data models
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Models/DraftPuzzle.swift` file
-   [ ] Define comprehensive draft puzzle structure with metadata
-   [ ] Create `Services/DraftStorageService.swift` file
-   [ ] Implement draft puzzle serialization to local storage
-   [ ] Add automatic draft saving during creation (every 2 minutes)
-   [ ] Create draft puzzle list management
-   [ ] Implement draft loading and restoration
-   [ ] Add draft versioning and history tracking
-   [ ] Create draft sharing preparation (export format)
-   [ ] Implement draft cleanup and storage management
-   [ ] Add draft search and organization features

### **Task 12: Builder Main Interface Integration**

**Context**: Create cohesive builder interface integrating all creation tools
**Reference**: See Builder Mode overview in `docs/product-requirements-document.md` (Section 3.3)
**Future Considerations**: Will accommodate multiplayer builder features
**Dependencies**: All builder UI components
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create `Views/Builder/BuilderView.swift` as main builder screen
-   [ ] Implement `ViewModels/BuilderViewModel.swift` for state coordination
-   [ ] Create tabbed interface for different builder phases (Edit, Analyze, Test, Save)
-   [ ] Add responsive layout for different screen sizes
-   [ ] Implement builder workflow guidance for new users
-   [ ] Create builder progress indicators and completion checklist
-   [ ] Add builder preferences integration
-   [ ] Implement builder session management and auto-save
-   [ ] Create builder navigation and state preservation
-   [ ] Add comprehensive error handling and user feedback

### **Task 13: Builder Navigation and Menu Integration**

**Context**: Integrate builder mode into main app navigation
**Reference**: See navigation structure in `docs/project-specification.md`
**Future Considerations**: Will support builder mode multiplayer rooms
**Dependencies**: Builder main interface
**Complexity**: Simple

**Sub-tasks:**

-   [ ] Update main app navigation to include "Create Puzzle" option
-   [ ] Add builder mode to main menu with appropriate icon
-   [ ] Implement navigation state management for builder mode
-   [ ] Create builder mode onboarding for first-time users
-   [ ] Add builder mode tutorial integration
-   [ ] Implement proper back navigation from builder to main menu
-   [ ] Create builder mode deep linking support
-   [ ] Add builder mode accessibility navigation
-   [ ] Implement builder mode state preservation during navigation
-   [ ] Create builder mode quick access shortcuts

### **Task 14: Builder Tutorial System**

**Context**: Guide new users through puzzle creation process
**Reference**: See tutorial system foundation from Phase 2
**Future Considerations**: Will include multiplayer builder tutorials
**Dependencies**: Builder navigation, tutorial system from Phase 2
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create builder-specific tutorial content in `Resources/Builder/builder-tutorial.json`
-   [ ] Design step-by-step builder tutorial flow
-   [ ] Create tutorial step: "Select grid size and place letters"
-   [ ] Add tutorial step: "Use analysis tools to see discovered words"
-   [ ] Create tutorial step: "Test your puzzle before saving"
-   [ ] Implement tutorial overlay system for builder interface
-   [ ] Add tutorial completion tracking for builder mode
-   [ ] Create tutorial skip and resume functionality
-   [ ] Implement contextual help system within builder
-   [ ] Test builder tutorial with new users

### **Task 15: Puzzle Export and Sharing Preparation**

**Context**: Prepare puzzles for sharing and submission to server
**Reference**: See puzzle submission in `docs/product-requirements-document.md` (Section 4.2)
**Future Considerations**: Will integrate with server submission API in Phase 4
**Dependencies**: Draft puzzle storage
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Create `Views/Builder/SavePuzzleView.swift` for export interface
-   [ ] Create `Services/PuzzleExportService.swift` for format conversion
-   [ ] Implement puzzle metadata collection (title, description, creator info)
-   [ ] Add export format validation for server compatibility
-   [ ] Create local puzzle library for completed puzzles
-   [ ] Implement puzzle sharing format (JSON export)
-   [ ] Add puzzle quality checklist before export
-   [ ] Create export progress indicators and error handling
-   [ ] Implement puzzle preview for export verification
-   [ ] Add contact information collection for puzzle submission

### **Task 16: Builder Performance Optimization**

**Context**: Optimize builder performance for smooth creation experience
**Reference**: See Performance Requirements in `docs/product-requirements-document.md` (Section 11.2)
**Future Considerations**: Will scale for collaborative building
**Dependencies**: All builder components
**Complexity**: Medium

**Sub-tasks:**

-   [ ] Implement word discovery caching and optimization
-   [ ] Add debounced analysis triggers to avoid excessive computation
-   [ ] Create background processing for long-running analysis
-   [ ] Implement memory management for large grids and word lists
-   [ ] Add analysis cancellation for improved responsiveness
-   [ ] Create progressive disclosure for analysis results
-   [ ] Implement efficient grid rendering for large sizes
-   [ ] Add performance monitoring and metrics collection
-   [ ] Create fallback modes for lower-performance devices
-   [ ] Test builder performance on various iOS devices

### **Task 17: Builder Quality Assurance and Testing**

**Context**: Comprehensive testing of builder functionality and user experience
**Reference**: See testing requirements across all specification documents
**Future Considerations**: Will extend to multiplayer builder testing
**Dependencies**: All builder features
**Complexity**: Complex

**Sub-tasks:**

-   [ ] Create comprehensive builder test cases
-   [ ] Test grid creation with all supported sizes (3x3 to 6x6)
-   [ ] Validate word discovery accuracy across different grid patterns
-   [ ] Test difficulty calculation accuracy and consistency
-   [ ] Verify puzzle validation catches all error conditions
-   [ ] Test draft saving and loading under various conditions
-   [ ] Validate export format compatibility
-   [ ] Test builder performance with complex puzzles
-   [ ] Verify accessibility features in builder mode
-   [ ] Create builder stress testing and edge case validation

---

## Testing & Validation

### Manual Testing Procedures

**Grid Creation Testing:**

1. Create grids of different sizes (3x3, 4x4, 5x5, 6x6)
2. Test letter placement, blank cells, and cell clearing
3. Verify undo/redo functionality works correctly
4. Test grid validation catches invalid configurations
5. Confirm grid editing is smooth and responsive

**Word Discovery Testing:**

1. Create puzzles with known word counts
2. Verify all discoverable words are found by algorithm
3. Test word discovery on irregular grid shapes
4. Confirm algorithm respects adjacency rules
5. Validate word discovery performance on large grids

**Difficulty Assessment Testing:**

1. Create puzzles with varying complexity
2. Verify difficulty scores match expected ranges
3. Test difficulty recommendations accuracy
4. Confirm difficulty factors are weighted correctly
5. Validate difficulty consistency across similar puzzles

**Puzzle Validation Testing:**

1. Test validation catches insufficient word counts
2. Verify unused letter detection works correctly
3. Test invalid grid configuration detection
4. Confirm all validation errors provide clear messages
5. Validate edge cases and corner scenarios

**Builder Workflow Testing:**

1. Complete full puzzle creation workflow
2. Test draft saving and restoration
3. Verify puzzle testing mode functionality
4. Test export preparation and format validation
5. Confirm builder tutorial guides users effectively

### Success Criteria for Phase Completion

-   [ ] Users can create grids from 3x3 to 6x6 with intuitive interface
-   [ ] Word discovery algorithm finds all valid words accurately
-   [ ] Difficulty assessment provides meaningful puzzle ratings
-   [ ] Puzzle validation ensures quality and playability
-   [ ] Draft system preserves work and allows iteration
-   [ ] Preview mode allows full puzzle testing
-   [ ] Export system prepares puzzles for sharing/submission
-   [ ] Builder tutorial teaches creation process effectively
-   [ ] Performance remains smooth during complex analysis
-   [ ] All builder features integrate seamlessly with main app

---

## Handoff to Next Phase

### What Should Be Working

-   Complete puzzle creation toolkit with intuitive interface
-   Accurate word discovery and difficulty assessment
-   Comprehensive puzzle validation and quality assurance
-   Local draft management and testing capabilities
-   Export system ready for server integration

### Architecture Decisions Enabling Phase 4

-   **Export format compatibility** with server API requirements
-   **Validation system alignment** with server-side validation
-   **Puzzle metadata structure** ready for server submission
-   **Analysis algorithms** matching server-side calculations

### Known Technical Debt

-   Word discovery algorithm could be further optimized for very large grids
-   Difficulty assessment may need tuning based on user feedback
-   Builder interface could benefit from more advanced editing features
-   Tutorial content may need expansion based on user testing

### Code Quality Standards

-   All builder components should be modular and reusable
-   Analysis algorithms should be thoroughly tested for accuracy
-   Performance should remain responsive during complex operations
-   User interface should follow established design patterns
