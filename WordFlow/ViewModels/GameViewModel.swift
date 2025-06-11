//
//  GameViewModel.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-10.
//

// We need to import Foundation for basic data types and services, although we are not using it yet.
// We import SwiftUI because `ObservableObject` is a key part of SwiftUI's data flow framework.
import Foundation
import SwiftUI

/// An enum to represent the specific outcome of a word path validation attempt.
///
/// This provides a much richer and more descriptive result than a simple optional or boolean.
/// The view can use this information to display precise feedback to the user, such as
/// why a word was rejected or the score for a successful word.
enum PathValidationResult {
    /// The traced path formed a valid, newly discovered word.
    /// The associated values contain the word, the score awarded, and the path taken.
    case success(word: String, score: Int, path: [GridCoordinate])
    /// The traced word was valid, but has already been found in this session.
    case alreadyFound(word: String)
    /// The traced word is not in the puzzle's solution list.
    case invalidWord
    /// The traced word is shorter than the puzzle's minimum required length.
    case tooShort
}

/// The `GameViewModel` is the central nervous system for the game screen.
///
/// As a key part of the MVVM (Model-View-ViewModel) architecture, this class is responsible for
/// managing the game's state and contains all the business logic related to gameplay. It acts as a
/// bridge between the game's data models (`Puzzle`, `GameState`, etc.) and the SwiftUI views (`GridView`, `GameView`).
///
/// By conforming to `ObservableObject`, SwiftUI views can subscribe to this view model and automatically
/// update their appearance whenever its `@Published` properties change. This creates a reactive and
/// efficient UI, where the view is always a reflection of the state managed here.
///
/// **Responsibilities:**
/// - Loading the current puzzle.
/// - Tracking the game's state (e.g., found words, score, timer).
/// - Handling user interactions, such as validating a word traced on the grid.
/// - Determining game completion.
//
// `GameViewModel` is a `class` because it needs to be a reference type that can be shared across
// different views and have a single, consistent state. `ObservableObject` requires a class type.
class GameViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The current state of the game. This property is marked with `@Published`, which means that
    /// any SwiftUI view observing this `GameViewModel` will automatically be notified and re-render
    /// whenever this property changes. It's optional (`GameState?`) because it's possible that
    /// no game is currently in progress.
    @Published var gameState: GameState?

    // MARK: - Private Properties

    /// A private array to hold all the puzzles loaded from the data source.
    /// This prevents us from having to load the puzzles from disk every time we start a new game.
    private var allPuzzles: [Puzzle] = []

    // MARK: - Initializer

    /// The initializer for the `GameViewModel`. Its primary job is to load all available puzzles
    /// from our `puzzle-data.json` file using the `PuzzleLoader` service.
    init() {
        do {
            // We use our singleton `PuzzleLoader` to load the puzzles. This operation can throw an
            // error, so we must use `try` within a `do-catch` block for safe error handling.
            self.allPuzzles = try PuzzleLoader.shared.loadPuzzles(from: "puzzle-data")
        } catch {
            // If an error occurs during puzzle loading, we print a descriptive error message
            // to the console. In a production app, we might want to handle this more gracefully,
            // for example, by showing an alert to the user.
            print("Error loading puzzles: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods

    /// Starts a new game with a puzzle at a specific index from the loaded puzzles.
    ///
    /// This method is the primary entry point for kicking off a game session. It ensures that the requested
    /// puzzle exists, creates a fresh `GameState` for it, and then assigns it to the `@Published`
    /// `gameState` property, which in turn causes the UI to update and display the new puzzle.
    ///
    /// - Parameter puzzleIndex: The index of the puzzle to start from the `allPuzzles` array.
    func startNewGame(puzzleIndex: Int) {
        // We use a guard statement for safety, ensuring the requested index is actually
        // within the bounds of our puzzles array. If not, we print an error and exit.
        guard allPuzzles.indices.contains(puzzleIndex) else {
            print("Error: Puzzle index \(puzzleIndex) is out of bounds.")
            return
        }

        // Retrieve the selected puzzle.
        let puzzle = allPuzzles[puzzleIndex]

        // Create a new `GameState` instance. This struct contains a fresh copy of the
        // puzzle's grid and an empty list of found words, ready for a new game.
        self.gameState = GameState(puzzle: puzzle)
    }

    /// This is a convenience method to start a new game with a random puzzle.
    /// It's useful for a "Play Again" feature.
    func startRandomNewGame() {
        let randomIndex = Int.random(in: 0..<allPuzzles.count)
        startNewGame(puzzleIndex: randomIndex)
    }

    /// Validates a path of coordinates traced by the user to see if it forms a valid, undiscovered word.
    ///
    /// This method has been updated to be more flexible. It now checks if the traced word exists in the
    /// solution list, regardless of the specific path taken. This allows for multiple valid ways to form the same word.
    ///
    /// If the word is valid, it updates the `GameState` and returns a `.success` result.
    /// Otherwise, it returns a result indicating the specific reason for failure.
    ///
    /// - Parameter path: An array of `GridCoordinate`s representing the user's trace.
    /// - Returns: A `PathValidationResult` describing the outcome.
    func validatePath(_ path: [GridCoordinate]) -> PathValidationResult? {
        // First, ensure a game is actually in progress. We use `guard let` to safely
        // unwrap the optional `gameState`. The `var` is important because we intend to modify it.
        guard var currentState = self.gameState else {
            // If there's no game state, no word can be valid.
            return nil
        }

        // Convert the traced path of coordinates into a string.
        // We do this by mapping each coordinate to its letter in the grid and joining them.
        let tracedWord = path.map { currentState.grid[$0].letter }.joined()

        // Check if the traced word meets the puzzle's minimum length requirement.
        guard tracedWord.count >= currentState.puzzle.minimumWordLength else {
            #if DEBUG
                print(
                    "Validation failed: '\(tracedWord)' is too short (minimum is \(currentState.puzzle.minimumWordLength))."
                )
            #endif
            return .tooShort
        }

        // Check if this word has already been found. We don't want to give credit twice.
        if currentState.foundWords.contains(where: {
            $0.word.lowercased() == tracedWord.lowercased()
        }) {
            #if DEBUG
                print("Validation failed: '\(tracedWord)' has already been found.")
            #endif
            return .alreadyFound(word: tracedWord)
        }

        // The NEW flexible validation: Does a solution exist in the puzzle's word list that matches
        // the word string (case-insensitively)? We no longer check for a path match here.
        guard
            let solution = currentState.puzzle.words.first(where: {
                $0.word.lowercased() == tracedWord.lowercased()
            })
        else {
            #if DEBUG
                print(
                    "Validation failed: '\(tracedWord)' is not a valid solution word for this puzzle."
                )
            #endif
            return .invalidWord
        }

        // --- Success! The word is valid and new. ---

        // We now use our dedicated ScoringService to calculate the score for the found word.
        // This call replaces the previous placeholder value.
        let score = ScoringService.calculateScore(for: solution.word)

        // Create a `FoundWord` model to record the discovery.
        // Note: We use the traced path, not the original solution path, to record how the user found it.
        let newFoundWord = FoundWord(
            word: solution.word,
            path: path,
            score: score,
            foundAt: Date()
        )

        // Add the newly found word to our state.
        currentState.foundWords.append(newFoundWord)

        // We also add the score of the new word to the player's total score for the puzzle.
        currentState.score += score

        // The view will now be responsible for temporary visual feedback.
        // We no longer change the grid state to `.traced` here.

        // Finally, update the main `gameState` property. Because `GameState` is a struct,
        // we must assign our modified copy (`currentState`) back to the original property.
        // This assignment is what triggers the `@Published` property wrapper to notify SwiftUI of the change.
        self.gameState = currentState

        #if DEBUG
            print("Validation successful: Found '\(solution.word)'!")
        #endif

        // Return the successful path so the view can create a flash effect.
        return .success(word: solution.word, score: score, path: path)
    }
}
