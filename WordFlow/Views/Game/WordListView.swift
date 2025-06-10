//
//  WordListView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-12.
//

import SwiftUI

/// A view that displays a list of words the player has successfully found.
///
/// This view observes the `GameViewModel` and presents a dynamic, scrollable list
/// of all the words in the `gameState`'s `foundWords` array. It is styled according
/// to the specifications in the Product Requirements Document to ensure a consistent
/// look and feel with the rest of the application.
struct WordListView: View {
    /// A reference to the view model that manages the game's state and logic.
    /// The `@ObservedObject` property wrapper creates a subscription to the view model.
    /// Whenever the `viewModel`'s `@Published` properties change (specifically, when a new
    // word is added to `foundWords`), SwiftUI will automatically re-render this view.
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        // We use a Group to conditionally show either the list of words or a loading/empty message.
        Group {
            // First, we safely unwrap the gameState. If it's not available, we show a placeholder.
            if let gameState = viewModel.gameState {
                // We calculate the data needed for our list.
                // 1. Group all solution words by their length. This gives us the total count for each category.
                let allWordsByLength = Dictionary(
                    grouping: gameState.puzzle.words, by: { $0.word.count })

                // 2. Group all *found* words by their length. This tells us what the user has discovered.
                let foundWordsByLength = Dictionary(
                    grouping: gameState.foundWords, by: { $0.word.count })

                // 3. Get all unique word lengths from the puzzle's solution and sort them,
                // so the list is always ordered consistently (e.g., 3-letter, 4-letter, etc.).
                let sortedLengths = allWordsByLength.keys.sorted()

                // List is the standard SwiftUI component for creating a scrollable list of data.
                List {
                    // We iterate over each word length to create a section in our list.
                    ForEach(sortedLengths, id: \.self) { length in
                        // Safely get the words for the current length.
                        let solutionsForLength = allWordsByLength[length] ?? []
                        let foundForLength = foundWordsByLength[length] ?? []

                        // DisclosureGroup creates a collapsible section, perfect for this kind of summary view.
                        DisclosureGroup(
                            content: {
                                // This is the content that appears when the user expands the group.
                                if foundForLength.isEmpty {
                                    // If no words of this length have been found, show a helpful placeholder.
                                    Text("None found yet.")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .padding(.leading)
                                } else {
                                    // As requested, we display the found words as a compact, comma-separated string.
                                    Text(
                                        foundForLength.map { $0.word.capitalized }
                                            .joined(separator: ", ")
                                    )
                                    .font(.system(.body, design: .rounded))
                                    .padding(.leading)
                                }
                            },
                            label: {
                                // This is the label for the collapsible row.
                                HStack {
                                    Text("\(length)-Letter Words")
                                        .font(.system(.callout, design: .rounded))
                                        .fontWeight(.medium)
                                    Spacer()
                                    // The "(found/total)" count gives the user a clear sense of progress.
                                    Text("(\(foundForLength.count)/\(solutionsForLength.count))")
                                        .font(.system(.callout, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        )
                    }
                }
                // .listStyle(.insetGrouped) gives us the modern, card-like appearance.
                .listStyle(.insetGrouped)

            } else {
                // If there is no game in progress, show a simple placeholder message.
                Text("No words found yet.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
    struct WordListView_Previews: PreviewProvider {
        /// Creates a sample `GameViewModel` with mock data for the preview.
        /// This has been updated to include a full mock `Puzzle` object, which is now
        /// necessary for the view to calculate the total number of words for each length.
        static func createMockViewModel() -> GameViewModel {
            let viewModel = GameViewModel()

            // 1. Create a set of mock solution words with varying lengths.
            let mockSolutions = [
                SolutionWord(word: "SWIFT", path: [], required: true, difficulty: .common),
                SolutionWord(word: "STYLE", path: [], required: true, difficulty: .common),
                SolutionWord(word: "KOTLIN", path: [], required: true, difficulty: .common),
                SolutionWord(word: "SHEETS", path: [], required: true, difficulty: .common),
                SolutionWord(word: "DART", path: [], required: true, difficulty: .common),
                SolutionWord(word: "CASCADING", path: [], required: true, difficulty: .common),
                SolutionWord(word: "HIDDEN", path: [], required: true, difficulty: .common),
            ]

            // 2. Create a dummy grid and puzzle object. These don't need to be functional
            // for this preview, they just need to exist.
            let mockGrid = PuzzleGrid(
                size: .init(width: 3, height: 3),
                squares: []
            )
            let mockPuzzle = Puzzle(
                id: "preview-1",
                title: "Preview Puzzle",
                grid: mockGrid,
                words: mockSolutions,
                minimumWordLength: 4
            )

            // 3. Create a game state with our mock puzzle.
            var gameState = GameState(puzzle: mockPuzzle)

            // 4. Add a few "found" words to simulate a game in progress.
            gameState.foundWords = [
                FoundWord(word: "SWIFT", path: [], score: 120, foundAt: Date()),
                FoundWord(word: "DART", path: [], score: 80, foundAt: Date()),
                FoundWord(word: "SHEETS", path: [], score: 140, foundAt: Date()),
            ]

            // 5. Assign the complete, mock game state to the view model.
            viewModel.gameState = gameState

            return viewModel
        }

        static var previews: some View {
            let mockViewModel = createMockViewModel()

            // We embed our WordListView in a standard VStack and give it a frame
            // to simulate how it might appear on a device screen.
            VStack(spacing: 0) {
                Text("Found Words")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))

                WordListView(viewModel: mockViewModel)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
#endif
