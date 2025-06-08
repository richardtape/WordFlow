//
//  PuzzleLoader.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-07.
//

import Foundation

// MARK: - Puzzle Loader
// Manages loading and parsing of puzzle data from a JSON file.
// This class is essential for providing the game with its core content.
class PuzzleLoader {

    // MARK: - Properties

    // The shared singleton instance of PuzzleLoader.
    // Using a singleton pattern ensures that puzzle data is loaded only once.
    static let shared = PuzzleLoader()

    // MARK: - Initializers

    // A private initializer to prevent the creation of other instances of PuzzleLoader.
    // This enforces the singleton pattern.
    private init() {}

    // MARK: - Public Methods

    // Loads and decodes puzzles from a specified JSON file in the app's bundle.
    // This is the primary method for accessing puzzle data.
    //
    // - Parameter filename: The name of the JSON file to load.
    // - Returns: An array of `Puzzle` objects.
    // - Throws: `PuzzleLoaderError` if the file cannot be found or decoded.
    func loadPuzzles(from filename: String) throws -> [Puzzle] {
        // Attempt to find the URL for the specified file in the main app bundle.
        // The bundle is where app resources like our JSON file are stored.
        guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: "json") else {
            // If the file URL is nil, the file doesn't exist in the bundle.
            // We throw a specific error to indicate this.
            throw PuzzleLoaderError.fileNotFound(name: filename)
        }

        // Load the data from the file URL.
        // A `do-catch` block is used here to handle potential errors from `Data(contentsOf:)`.
        let data: Data
        do {
            data = try Data(contentsOf: fileUrl)
        } catch {
            // If data cannot be loaded, we wrap the underlying error in our custom error type.
            throw PuzzleLoaderError.dataLoadingFailed(source: error)
        }

        // Attempt to decode the JSON data into an array of `Puzzle` structs.
        // `JSONDecoder` is a standard Swift tool for this purpose.
        // The `decode` method takes the expected `Codable` type (`[Puzzle].self`) and the data.
        do {
            let puzzles = try JSONDecoder().decode([Puzzle].self, from: data)
            return puzzles
        } catch {
            // If decoding fails, it means the JSON structure doesn't match our `Puzzle` model.
            // We wrap the decoding error to provide more specific feedback.
            throw PuzzleLoaderError.decodingFailed(source: error)
        }
    }
}

// MARK: - Error Handling
// Defines custom, more descriptive errors for the puzzle loading process.
// This helps in debugging and providing clear feedback if something goes wrong.
enum PuzzleLoaderError: Error, LocalizedError {
    // Error for when the JSON file cannot be located in the app bundle.
    case fileNotFound(name: String)
    // Error for when data cannot be loaded from the file URL.
    // It includes the original `Error` for more context.
    case dataLoadingFailed(source: Error)
    // Error for when the JSON data doesn't match the expected `Puzzle` structure.
    // It also includes the original `Error`.
    case decodingFailed(source: Error)

    // MARK: - Validation Errors
    // Errors found during the puzzle content validation stage.

    /// A word in the puzzle's word list is not in the official dictionary.
    case wordNotFoundInDictionary(puzzle: String, word: String)

    /// A word's path does not match the letters on the grid.
    case pathDoesNotMatchWord(puzzle: String, word: String)

    /// A word's path is invalid because it's not contiguous or contains duplicate coordinates.
    case invalidPath(puzzle: String, word: String, reason: String)

    /// A letter in the grid is not used in any of the puzzle's solution words.
    case unusedLetterInGrid(puzzle: String, coordinate: GridCoordinate)

    // Provides human-readable descriptions for each error case.
    // This is useful for logging and debugging.
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "The puzzle file named '\(name).json' could not be found in the app bundle."
        case .dataLoadingFailed(let source):
            return "Failed to load data from the puzzle file. Original error: \(source.localizedDescription)"
        case .decodingFailed(let source):
            // Provides detailed information about decoding errors.
            if let decodingError = source as? DecodingError {
                return "Failed to decode the puzzle data. Please check the JSON format. Details: \(decodingError.humanReadableDescription)"
            } else {
                return "Failed to decode the puzzle data. Original error: \(source.localizedDescription)"
            }

            // Descriptions for our new validation errors.
            case .wordNotFoundInDictionary(let puzzle, let word):
                return "Validation failed for puzzle '\(puzzle)': The word '\(word)' is not in the dictionary."
            case .pathDoesNotMatchWord(let puzzle, let word):
                return "Validation failed for puzzle '\(puzzle)': The path for '\(word)' does not spell the word correctly on the grid."
            case .invalidPath(let puzzle, let word, let reason):
                return "Validation failed for puzzle '\(puzzle)': The path for '\(word)' is invalid. Reason: \(reason)."
            case .unusedLetterInGrid(let puzzle, let coordinate):
                return "Validation failed for puzzle '\(puzzle)': The letter at (\(coordinate.x), \(coordinate.y)) is not used in any word."
        }
    }
}

// MARK: - DecodingError Extension
// An extension to `DecodingError` to provide more actionable, human-readable error messages.
// This is incredibly helpful for diagnosing issues with the JSON file itself.
extension DecodingError {
    // A computed property that generates a detailed, readable description of the decoding error.
    var humanReadableDescription: String {
        switch self {
        case .typeMismatch(let type, let context):
            return "Type mismatch for type '\(type)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value not found for type '\(type)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Key not found: '\(key.stringValue)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). \(context.debugDescription)"
        @unknown default:
            return "An unknown decoding error occurred."
        }
    }
}