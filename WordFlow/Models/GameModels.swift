//
//  GameModels.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-07.
//

import Foundation

/// Represents a unique position in the game grid using x (column) and y (row) coordinates.
///
/// Conforms to `Codable` to allow for saving and loading puzzles from data formats like JSON.
/// Conforms to `Hashable` to be used efficiently in `Set`s or as `Dictionary` keys, which is crucial for tracking visited squares during word tracing.
struct GridCoordinate: Codable, Hashable {
    let x: Int
    let y: Int
}

/// Represents the visual and interactive state of a single square in the grid.
///
/// This enum is `Codable` so that the entire state of the grid can be saved and loaded.
enum SquareState: Codable {
    /// The default state for a letter that has not been interacted with.
    case normal
    /// The state when the user's finger is currently on the square during a trace.
    case selected
    /// The state for a letter that is part of a successfully found word.
    case traced
    /// The state for a letter that is no longer part of any remaining valid words.
    case faded
    /// The state for a square that does not contain a letter, used for irregular grid shapes.
    case blank
}

/// Represents a single letter square within the game grid.
/// This model holds the letter itself, its position, and its current state.
///
/// Conforms to `Identifiable` to be used directly in SwiftUI `ForEach` loops. Its `coordinate` provides a unique, stable identifier.
/// Conforms to `Hashable` so that collections of squares can be efficiently stored in `Set`s.
/// Conforms to `Codable` so that its state can be saved as part of the overall grid data.
struct LetterSquare: Identifiable, Hashable, Codable {
    /// A stable, unique identifier for the square, derived from its coordinate.
    var id: GridCoordinate { coordinate }

    /// The character displayed in this square.
    let letter: String
    /// The position of this square in the grid.
    let coordinate: GridCoordinate
    /// The current visual and interactive state of the square, defaulting to `normal`.
    var state: SquareState = .normal
}

/// Represents a single solution word and its corresponding path within a puzzle's definition.
/// This model is used to decode the list of all valid words from a puzzle's data file.
///
/// Conforms to `Codable` to allow for easy decoding from JSON.
/// Conforms to `Hashable` so it can be stored in a `Set` for efficient lookups.
struct SolutionWord: Codable, Hashable {
    /// The solution word.
    let word: String
    /// The sequence of grid coordinates that form the `word`.
    let path: [GridCoordinate]
}

/// Defines the dimensions of the game grid.
///
/// Conforms to `Codable` for puzzle loading and `Equatable` for comparing grid sizes.
struct GridSize: Codable, Equatable {
    let width: Int
    let height: Int
}

/// Represents the entire game grid, containing all the letter squares.
///
/// This struct is the central model for the playable area. It's initialized from a puzzle's raw data
/// and provides helpful methods for accessing and manipulating the grid squares.
/// Conforms to `Codable` so the grid's state can be saved as part of the overall `GameState`.
struct Grid: Codable {
    /// The dimensions of the grid.
    let size: GridSize
    /// A one-dimensional array holding all the `LetterSquare`s that make up the grid.
    /// The squares are stored in row-major order (i.e., all squares of the first row, then the second, and so on).
    var squares: [LetterSquare]

    /// Provides convenient access to a `LetterSquare` using its `GridCoordinate`.
    ///
    /// - Parameter coordinate: The (x, y) coordinate of the square to access.
    /// - Returns: The `LetterSquare` at the specified coordinate.
    subscript(coordinate: GridCoordinate) -> LetterSquare {
        get {
            // Formula to convert 2D coordinate to 1D array index.
            return squares[coordinate.y * size.width + coordinate.x]
        }
        set {
            // Update the square at the given coordinate.
            squares[coordinate.y * size.width + coordinate.x] = newValue
        }
    }
}

/// Represents a word that the player has successfully found during a game session.
///
/// This model stores the word, the path taken, the score awarded, and the timestamp of when it was found.
///
/// Conforms to `Identifiable` so it can be used in SwiftUI lists, using the word itself as a unique ID.
/// Conforms to `Codable` and `Hashable` for saving game state and efficient storage in collections.
struct FoundWord: Identifiable, Codable, Hashable {
    /// A unique identifier for the found word, which is the word string itself.
    var id: String { word }

    /// The word that was found.
    let word: String
    /// The path of coordinates the player traced to form the word.
    let path: [GridCoordinate]
    /// The score awarded for finding this word.
    let score: Int
    /// The date and time when the word was found.
    let foundAt: Date
}

/// Represents a complete puzzle, including its unique ID, title, grid, and the list of words to be found.
///
/// This model is decoded directly from the puzzle data files (e.g., JSON). It contains all the static
/// information needed to start a game. Conforms to `Identifiable` to be used in SwiftUI lists.
struct Puzzle: Codable, Identifiable {
    /// A unique identifier for the puzzle.
    let id: String
    /// The display title of the puzzle.
    let title: String
    /// The 2D grid of letters for the puzzle.
    let grid: Grid
    /// An array of the solution words that can be found within the puzzle.
    let words: [SolutionWord]

    // We define custom coding keys to match the keys in our `puzzle-data.json` file.
    // This is a good practice for making Codable conformance robust.
    enum CodingKeys: String, CodingKey {
        case id, title, grid, words
    }

    // We need a custom initializer to handle the decoding of the `grid` property.
    // The default Codable synthesis can struggle with nested arrays of custom types.
    init(from decoder: Decoder) throws {
        // Create a container keyed by our `CodingKeys` enum.
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the simple properties directly.
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.words = try container.decode([SolutionWord].self, forKey: .words)

        // For the grid, we decode it as a 2D array of optional strings from the JSON
        // to handle blank spaces, which are represented by `null`.
        let stringGrid = try container.decode([[String?]].self, forKey: .grid)

        // Now, we manually construct our `Grid` object from this 2D string array.
        let height = stringGrid.count
        let width = stringGrid.first?.count ?? 0
        let size = GridSize(width: width, height: height)

        var squares = [LetterSquare]()
        squares.reserveCapacity(width * height)

        // We iterate through the string grid with coordinates to create our `LetterSquare`s.
        for (y, row) in stringGrid.enumerated() {
            for (x, letter) in row.enumerated() {
                let coordinate = GridCoordinate(x: x, y: y)
                let letterSquare: LetterSquare
                // If the letter is non-nil and not empty, create a normal letter square.
                // Otherwise, it's a blank space in the grid.
                if let letter = letter, !letter.isEmpty {
                    letterSquare = LetterSquare(letter: letter.uppercased(), coordinate: coordinate, state: .normal)
                } else {
                    letterSquare = LetterSquare(letter: "", coordinate: coordinate, state: .blank)
                }
                squares.append(letterSquare)
            }
        }

        // Finally, create the Grid object and assign it.
        self.grid = Grid(size: size, squares: squares)
    }

    // We also need a memberwise initializer for creating `Puzzle` instances manually,
    // as the compiler no longer provides one after we defined a custom decoder initializer.
    init(id: String, title: String, grid: Grid, words: [SolutionWord]) {
        self.id = id
        self.title = title
        self.grid = grid
        self.words = words
    }
}

/// Represents the dynamic state of a single game session.
///
/// This struct holds all the information that changes as a player interacts with a puzzle,
/// such as which words have been found, the current score, and timing information.
/// It's designed to be `Codable` so that an entire game session can be easily saved and restored.
struct GameState: Codable {
    /// The static puzzle definition for the current game.
    let puzzle: Puzzle

    /// The playable grid, which tracks the state of each letter square.
    var grid: Grid

    /// A list of words the player has successfully found.
    var foundWords: [FoundWord] = []

    /// The player's current total score.
    var score: Int = 0

    /// The time the game session was started.
    let startTime: Date

    /// A computed property that determines if the puzzle has been completed.
    /// The puzzle is complete when the number of found words matches the total number of solution words.
    var isComplete: Bool {
        foundWords.count == puzzle.words.count
    }

    /// Initializes a new game state from a given puzzle.
    /// This initializer sets up the initial playable grid based on the puzzle's definition.
    /// - Parameter puzzle: The puzzle to start a game with.
    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.startTime = Date()

        // The playable grid is a direct copy of the puzzle's grid to start.
        // Since `Grid` is a struct, this creates a unique copy for the game session.
        // All mutations during gameplay will happen on this `GameState.grid` copy.
        self.grid = puzzle.grid
    }
}