//
//  ScoringService.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-12.
//

import Foundation

/// A stateless utility service responsible for calculating scores for found words.
///
/// This service encapsulates the game's scoring logic, making it easy to manage,
/// test, and extend. Using a `struct` with a `static` method is a clean and
/// efficient way to implement a stateless utility in Swift, as it avoids the
/// overhead of creating and managing an instance of a class.
struct ScoringService {

    // MARK: - Constants

    /// The base value for score calculation, as defined in the Product Requirements Document (Section 5.1).
    /// This is defined as a static constant so it can be easily referenced and modified in one place
    /// if the game's design changes in the future.
    private static let basePoints = 100

    // MARK: - Public Methods

    /// Calculates the score for a given word based on its length.
    ///
    /// This method implements the exponential scoring formula: `basePoints * (2^(length - 3))`.
    /// This formula ensures that longer words are significantly more valuable than shorter ones,
    /// providing a greater reward for more difficult discoveries. For example:
    /// - 3-letter word: 100 * (2^0) = 100 points
    /// - 4-letter word: 100 * (2^1) = 200 points
    /// - 5-letter word: 100 * (2^2) = 400 points
    ///
    /// The `pow` function from `Foundation` is used for the exponentiation calculation. It takes
    /// two `Decimal` or `Double` values, so we must perform type casting to use it.
    ///
    /// - Parameter word: The `String` for which to calculate the score.
    /// - Returns: An `Int` representing the calculated score.
    static func calculateScore(for word: String) -> Int {
        // We ensure the word length is at least 3, as per the formula's design.
        // If a word is shorter (which shouldn't happen with our current validation),
        // this prevents a negative exponent and returns the base score.
        let length = max(3, word.count)
        let exponent = length - 3

        // The `pow` function works with `Double` or `Decimal`. We use `Double` for simplicity here.
        let multiplier = pow(2.0, Double(exponent))

        // We calculate the final score and cast it back to an `Int` as scores are whole numbers.
        let finalScore = Double(basePoints) * multiplier
        return Int(finalScore)
    }
}