//
//  WordValidator.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-07.
//

import Foundation

/// A service responsible for loading the game's dictionary and validating words.
///
/// This class uses a singleton pattern (`shared`) to ensure that the dictionary is loaded from disk
/// only once for performance. The word list is stored in a `Set` for very fast, O(1) average time complexity lookups.
final class WordValidator {

    /// The shared singleton instance of the validator.
    static let shared = WordValidator()

    /// A private set that stores all the valid words from the dictionary file for quick lookups.
    /// The `private(set)` access control means the property can only be modified from within this class.
    private(set) var words: Set<String> = []

    /// The private initializer prevents the creation of other instances of this class.
    /// This enforces the singleton pattern.
    private init() {
        loadDictionary()
    }

    /// Loads words from the `words.txt` file in the app's main bundle into the `words` set.
    ///
    /// This method is called once when the `WordValidator` is initialized. It locates the dictionary file,
    /// reads its contents, and populates the `words` set for fast lookups. If the file cannot be
    /// found or read, it will trigger a `fatalError`, as the dictionary is essential for gameplay.
    private func loadDictionary() {
        // Record the start time to measure performance.
        let startTime = Date()

        // 1. Find the path for `words.txt` in the app's main resource bundle.
        // The bundle is like a folder that contains all your app's assets.
        guard let path = Bundle.main.path(forResource: "words", ofType: "txt") else {
            // This is a programmer error. The file must be included in the project and added to the target.
            fatalError("Could not find words.txt in the app bundle.")
        }

        do {
            // 2. Read the entire file content into a single string.
            let content = try String(contentsOfFile: path, encoding: .utf8)

            // 3. Split the content by newlines to get an array of words, filtering out any empty lines.
            let wordList = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

            // 4. Populate the `words` set with the loaded list.
            self.words = Set(wordList)

            // Calculate the time elapsed since the start.
            let duration = Date().timeIntervalSince(startTime)

            // A helpful debug message to confirm the dictionary loaded correctly and show performance.
            #if DEBUG
            print("WordValidator: Successfully loaded \(self.words.count) words into the dictionary in \(String(format: "%.3f", duration)) seconds.")
            #endif

        } catch {
            // This would happen if the file is found but there's a problem reading it.
            fatalError("Could not load content from words.txt: \(error)")
        }
    }

    /// Checks if a given word is valid according to the loaded dictionary and game rules.
    ///
    /// This method performs several checks:
    /// 1. It ensures the word meets a minimum length requirement.
    /// 2. It performs a case-insensitive check by converting the input word to lowercase, as our dictionary is entirely lowercase.
    /// 3. It verifies if the lowercase word exists in the dictionary set.
    ///
    /// - Parameters:
    ///   - word: The word to validate.
    ///   - minimumLength: The minimum number of characters the word must have to be considered valid.
    /// - Returns: `true` if the word is valid, otherwise `false`.
    func isValidWord(_ word: String, minimumLength: Int) -> Bool {
        // 1. Check if the word meets the minimum length requirement.
        guard word.count >= minimumLength else {
            return false
        }

        // 2. Perform a case-insensitive check against the words set.
        return words.contains(word.lowercased())
    }

}