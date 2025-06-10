//
//  LetterSquareView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-08.
//

import SwiftUI

/// A view that represents a single, interactive square in the word search grid.
///
/// This view is the fundamental visual building block of the game. It is responsible for displaying
/// a single letter and visually representing its current state (e.g., normal, selected, part of a found word).
/// It is designed to be highly reusable and configurable.
struct LetterSquareView: View {
    /// The character to be displayed in the square.
    let letter: String
    /// The current interactive state of the square, which determines its appearance.
    let state: SquareState
    /// The width and height of the square. This is passed in from the parent `GridView` to ensure all squares are uniform and responsive.
    let size: CGFloat

    var body: some View {
        // ZStack is used to layer views on top of each other. Here, it allows us to place
        // the letter text on top of a background color and under a border overlay.
        ZStack {
            // The main view content is only shown if the state is not blank. This allows
            // for the creation of puzzles with irregular shapes.
            if state != .blank {
                Text(letter)
                    // The font size is calculated as a percentage of the square's size,
                    // making the text scale proportionally with the grid.
                    .font(.system(size: size * 0.4, weight: .semibold))
                    // The text color is determined by the square's current state.
                    .foregroundColor(foregroundColor)
            }
        }
        // The frame modifier ensures the ZStack (and thus the square) is the exact size required.
        .frame(width: size, height: size)
        // The background color is determined by the square's current state.
        .background(backgroundColor)
        // cornerRadius rounds the corners to give the square a softer, more modern look.
        .cornerRadius(8)
        .overlay(
            // The border is also hidden for the blank state. Using a Group allows us to
            // apply a condition to a view modifier.
            Group {
                if state != .blank {
                    RoundedRectangle(cornerRadius: 8)
                        // The stroke modifier draws a line along the edge of the shape.
                        // The color is determined by the square's current state.
                        .stroke(borderColor, lineWidth: 1)
                }
            }
        )
        // Apply a faded effect for the .faded state. This provides a visual cue that the
        // letter is no longer useful for finding remaining words.
        .opacity(state == .faded ? 0.5 : 1.0)
        // Animate changes when the `state` property changes. This tells SwiftUI to automatically
        // create a smooth transition between the old and new appearances.
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    // MARK: - State-based Computed Properties
    // Using computed properties for styling keeps the `body` of the view clean and readable.
    // It encapsulates the styling logic, making it easy to modify one state's appearance
    // without affecting the others.

    /// Determines the background color of the square based on its state.
    private var backgroundColor: Color {
        switch state {
        case .normal, .blank:
            // .systemBackground is an adaptive color that works well in both light and dark modes.
            return Color(.systemBackground)
        case .selected:
            // A bright blue to indicate the user is actively tracing over this square.
            return .blue
        case .traced:
            // A green color to provide positive feedback for a correctly found word.
            return .green.opacity(0.8)
        case .faded:
            // A subtle gray to indicate the letter is no longer in play.
            return Color(.systemGray5)
        }
    }

    /// Determines the color of the letter text based on its state.
    private var foregroundColor: Color {
        switch state {
        case .normal, .faded:
            // .primary is an adaptive color for text that ensures readability in light/dark modes.
            return .primary
        case .selected, .traced:
            // High-contrast white text is needed when the background is a solid color.
            return .white
        case .blank:
            // .clear makes the text invisible, which is desired for a blank square.
            return .clear
        }
    }

    /// Determines the border color of the square based on its state.
    private var borderColor: Color {
        switch state {
        case .normal:
            // A standard gray border for the default state.
            return Color(.systemGray4)
        case .selected, .traced:
            // When the square has a solid background color, a border is unnecessary and can look cluttered.
            return .clear
        case .faded:
            // A slightly darker gray border for faded squares to maintain some definition.
            return Color(.systemGray3)
        case .blank:
            // No border needed for a blank square.
            return .clear
        }
    }
}

// MARK: - Interactive Preview
// A helper view for creating an interactive preview to test animations and state changes.
// This is a common pattern for building and testing complex components in isolation.
private struct LetterSquarePreviewWrapper: View {
    // A list of all possible states to cycle through for testing.
    private let allStates: [SquareState] = [.normal, .selected, .traced, .faded, .blank]
    // @State tells SwiftUI to manage this property. When it changes, the view will be re-rendered.
    @State private var currentStateIndex = 0

    var body: some View {
        VStack(spacing: 20) {
            // The LetterSquareView that will animate its state changes.
            LetterSquareView(
                letter: "A",
                state: allStates[currentStateIndex],
                size: 80
            )

            // A button to cycle to the next state, allowing for interactive testing.
            Button("Next State") {
                // Increment the index, wrapping around if it goes past the end of the array.
                // This creates a continuous loop through all the states.
                currentStateIndex = (currentStateIndex + 1) % allStates.count
            }
            .buttonStyle(.borderedProminent)

            // A label to display the current state name for clarity during testing.
            Text("Current State: \(String(describing: allStates[currentStateIndex]))")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LetterSquarePreviewWrapper()
}