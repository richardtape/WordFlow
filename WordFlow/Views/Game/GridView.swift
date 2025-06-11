//
//  GridView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-08.
//

import SwiftUI
import UIKit  // We need to import UIKit to get access to UIImpactFeedbackGenerator for haptic feedback.

// A custom view modifier to create a shake animation effect.
// This is a more advanced SwiftUI technique. By creating a `GeometryEffect`,
// we can manipulate the drawing of a view in a highly performant way.
struct Shake: GeometryEffect {
    // We animate a `CGFloat` from 0 to 1 to drive the animation.
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        // The translation on the x-axis is what creates the shake.
        // We use a sine wave to create a smooth back-and-forth motion.
        ProjectionTransform(
            CGAffineTransform(
                translationX:
                    amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
    }
}

/// A view that arranges `LetterSquareView`s into a responsive, interactive grid.
///
/// This view is responsible for the overall layout of the puzzle. It takes a `Grid` data model
/// and dynamically calculates the size of each square to ensure the entire puzzle fits
/// perfectly on any device screen, from a small iPhone to a large iPad.
struct GridView: View {
    /// The static grid data to be displayed. By passing in just the `PuzzleGrid` model,
    /// this view becomes more reusable and decoupled from the main `GameViewModel`.
    /// It no longer needs to know about the entire game state.
    let grid: PuzzleGrid

    /// A callback function that the `GridView` will execute when the user completes a gesture.
    /// It passes the traced path (an array of coordinates) back to the parent view (`GameView`),
    /// which is responsible for handling the validation logic. This is a form of delegation.
    let onPathValidated: ([GridCoordinate]) -> Void

    // MARK: - State for UI Feedback (passed from parent)

    /// The path of a successfully found word, used to create a temporary "flash" effect.
    /// This is a `Binding` because the parent view (`GameView`) owns and modifies this state.
    @Binding var highlightedPath: [GridCoordinate]

    /// A counter that, when changed by the parent view, triggers the shake animation.
    @Binding var invalidShake: Int

    // MARK: - Gesture State Properties
    /// The path of coordinates the user is currently tracing with their finger.
    /// The `@State` property wrapper allows this view to have its own internal state,
    /// which is essential for tracking the drag gesture.
    @State private var currentPath: [GridCoordinate] = []

    /// The coordinate of a square that is a potential candidate for being added to the path.
    /// This is used with a timer to create a slight delay, ensuring the user's intent.
    @State private var candidateCoord: GridCoordinate? = nil

    /// The timer responsible for confirming the selection of a `candidateCoord`.
    @State private var selectionTimer: Timer? = nil

    // MARK: - Tunable Constants
    /// The short delay before a hovered square is officially selected. This makes the gesture more forgiving.
    /// This value can be tweaked to get the "feel" of the game just right.
    private let selectionDelay = 0.05
    /// A constant that defines the spacing between each square in the grid.
    private let spacing: CGFloat = 8

    var body: some View {
        // We now directly use the `grid` property that is passed into this view.
        // This removes the dependency on the `GameViewModel` inside this component.
        GeometryReader { geometry in
            // Calculate the size for each square based on the available width from the GeometryReader.
            let squareSize = calculateSquareSize(for: geometry.size)

            // LazyVGrid is a view that arranges its children in a grid that grows vertically.
            // It's "lazy" because it only creates the child views (our LetterSquareViews)
            // when they are needed to be displayed, which is very efficient.
            LazyVGrid(columns: columns, spacing: spacing) {
                // We loop through each `LetterSquare` in our data model.
                // Because `LetterSquare` is `Identifiable`, SwiftUI can track each square
                // efficiently.
                ForEach(grid.squares) { square in
                    LetterSquareView(
                        letter: square.letter,
                        // The state is now determined by multiple factors for rich feedback:
                        // 1. Is it part of the temporary green highlight path? -> .traced
                        // 2. Is the user currently selecting it? -> .selected
                        // 3. Otherwise, use its base state from the model.
                        state: state(for: square),
                        // We pass the dynamically calculated size to each square.
                        size: squareSize
                    )
                }
            }
            // We attach the drag gesture to the grid container.
            .gesture(dragGesture(squareSize: squareSize))
            // Apply the shake effect. The `modifier` is triggered whenever `invalidShake` changes.
            .modifier(Shake(animatableData: CGFloat(invalidShake)))
        }
        // Add some padding around the entire grid.
        .padding(spacing)
        // Set a background color for the grid container to visually separate it from the screen background.
        .background(Color(.systemGray6))
        // Round the corners of the grid container for a modern UI look.
        .cornerRadius(12)
        // By enforcing a 1:1 aspect ratio, we ensure the grid is always a perfect square.
        // The `.fit` content mode tells the view to scale down to fit the available space
        // without being clipped. This is the key to solving the layout issue.
        .aspectRatio(1, contentMode: .fit)
    }

    /// A computed property that defines the column layout for the `LazyVGrid`.
    /// The number of columns is determined by the width of the grid data.
    private var columns: [GridItem] {
        // `GridItem(.flexible())` creates a column that takes up an equal share of the available space.
        // By creating an array of these, we define the grid's structure.
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: grid.size.width)
    }

    /// Calculates the optimal size for each square to fit within the available geometry.
    /// This is the core of the responsive layout logic.
    /// - Parameter size: The size of the container view, provided by `GeometryReader`.
    /// - Returns: The calculated width and height for a single square.
    private func calculateSquareSize(for size: CGSize) -> CGFloat {
        // To calculate the size, we first determine the total amount of space taken up by spacing.
        let totalSpacing = spacing * CGFloat(grid.size.width - 1)
        // Then, we subtract that from the total available width.
        let availableWidth = size.width - totalSpacing
        // The size of each square is the remaining width divided by the number of squares in a row.
        return availableWidth / CGFloat(grid.size.width)
    }

    /// Creates and configures the `DragGesture` for the grid.
    /// - Parameter squareSize: The size of each square, needed for coordinate calculation.
    /// - Returns: A configured `DragGesture`.
    private func dragGesture(squareSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Determine which square the user's finger is currently over.
                guard let hoveredCoord = coordinate(for: value.location, in: squareSize)
                else {
                    // If the finger moves outside the grid, cancel any pending selection.
                    selectionTimer?.invalidate()
                    candidateCoord = nil
                    return
                }

                // If this is the start of a new trace, select the first letter instantly.
                if currentPath.isEmpty {
                    currentPath.append(hoveredCoord)
                    triggerHapticFeedback()
                    return
                }

                // This is the core check: only do work if the finger is on a NEW square.
                guard let lastCoord = currentPath.last, hoveredCoord != lastCoord else {
                    return
                }

                // 1. Check for Backtracking first. This is an immediate action.
                if currentPath.count > 1 && hoveredCoord == currentPath[currentPath.count - 2] {
                    selectionTimer?.invalidate()  // Cancel any pending selection.
                    candidateCoord = nil
                    currentPath.removeLast()
                    triggerHapticFeedback()
                    return
                }

                // 2. We've moved to a new square. If it's different from our current candidate,
                // we need to update our intention.
                if hoveredCoord != candidateCoord {
                    selectionTimer?.invalidate()  // Cancel the timer for the old candidate.

                    // 3. Check if this new square is a valid forward move.
                    if areAdjacent(lastCoord, hoveredCoord) && !currentPath.contains(hoveredCoord) {
                        // It's a valid new candidate. Set it and start the timer.
                        candidateCoord = hoveredCoord
                        scheduleSelection(of: hoveredCoord)
                    } else {
                        // The user moved to an invalid square (e.g., not adjacent). Clear the candidate.
                        candidateCoord = nil
                    }
                }
                // If hoveredCoord is the SAME as candidateCoord, we do nothing, letting the timer run.
            }
            .onEnded { _ in
                // When the gesture ends, cancel any pending timer.
                selectionTimer?.invalidate()

                // Immediately confirm any pending candidate. This handles fast taps.
                if let finalCandidate = candidateCoord {
                    // Only add if it's not already the last item.
                    if currentPath.last != finalCandidate {
                        currentPath.append(finalCandidate)
                        triggerHapticFeedback()
                    }
                }

                // If the path is not empty, we can pass it to the view model for validation.
                if !currentPath.isEmpty {
                    // Instead of calling the viewModel directly, we use our callback.
                    // The parent view (`GameView`) is now responsible for handling the result.
                    onPathValidated(currentPath)
                }

                // Reset for the next gesture.
                currentPath.removeAll()
                candidateCoord = nil
            }
    }

    /// Schedules the confirmation of a square selection after a short delay.
    /// - Parameter coordinate: The `GridCoordinate` to be selected.
    private func scheduleSelection(of coordinate: GridCoordinate) {
        selectionTimer = Timer.scheduledTimer(withTimeInterval: selectionDelay, repeats: false) {
            _ in
            // Ensure the candidate is still the same one we scheduled for.
            guard self.candidateCoord == coordinate else { return }

            // A candidate should only be added if the path is not empty.
            // The first letter is added instantly, not via the timer.
            if !self.currentPath.isEmpty {
                // Add the coordinate to the path and provide feedback.
                self.currentPath.append(coordinate)
                self.triggerHapticFeedback()
            }

            // The candidate has been confirmed, so it's no longer a candidate.
            self.candidateCoord = nil
        }
    }

    /// Triggers a gentle haptic feedback to confirm a selection.
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Calculates the `GridCoordinate` for a given touch location. This is mainly used to find the starting square.
    /// - Parameters:
    ///   - location: The `CGPoint` of the touch from the `DragGesture`.
    ///   - squareSize: The size of each square in the grid.
    /// - Returns: A `GridCoordinate` if the location is within the bounds of the grid, otherwise `nil`.
    private func coordinate(for location: CGPoint, in squareSize: CGFloat)
        -> GridCoordinate?
    {
        let col = Int(location.x / (squareSize + spacing))
        let row = Int(location.y / (squareSize + spacing))

        // Ensure the calculated coordinate is within the grid's bounds.
        guard col >= 0, col < grid.size.width, row >= 0, row < grid.size.height else {
            return nil
        }

        return GridCoordinate(x: col, y: row)
    }

    /// Checks if two coordinates are adjacent (horizontally, vertically, or diagonally).
    /// - Parameters:
    ///   - c1: The first coordinate.
    ///   - c2: The second coordinate.
    /// - Returns: `true` if the coordinates are adjacent, otherwise `false`.
    private func areAdjacent(_ c1: GridCoordinate, _ c2: GridCoordinate) -> Bool {
        let dx = abs(c1.x - c2.x)
        let dy = abs(c1.y - c2.y)
        // Two coordinates are adjacent if they are not the same point and the distance
        // on both axes is at most 1. This covers all 8 directions.
        return (dx <= 1 && dy <= 1) && (dx != 0 || dy != 0)
    }

    /// Determines the correct `SquareState` for a given square, layering temporary UI states over the base model state.
    private func state(for square: LetterSquare) -> SquareState {
        let coord = square.coordinate

        if highlightedPath.contains(coord) {
            // If the square is part of the success flash, its state is temporarily .traced (green).
            return .traced
        }
        if currentPath.contains(coord) || candidateCoord == coord {
            // If the user is actively tracing over the square, it's .selected (blue).
            return .selected
        }
        // Otherwise, we fall back to the authoritative state from the GameState model.
        // We look up the square's state from the viewModel to ensure we have the most recent data.
        return grid[coord].state
    }

    // MARK: - Animation Triggers

    /// Triggers a brief "flash" of a path by highlighting it and then clearing the highlight after a delay.
    /// - Parameter path: The path of coordinates to flash.
    private func flash(path: [GridCoordinate]) {
        self.highlightedPath = path
        // Schedule the highlight to disappear after a short delay.
        // This creates the "flash" effect.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.highlightedPath.removeAll()
        }
    }

    /// Triggers the shake animation by incrementing the `invalidShake` state property.
    private func shake() {
        // We wrap the state change in `withAnimation` to ensure SwiftUI animates the transition.
        withAnimation(.default) {
            self.invalidShake += 1
        }
    }
}

// MARK: - Preview

#if DEBUG
    /// A private wrapper view used to host and set up the `GridView` for previewing.
    ///
    /// This is the standard best-practice pattern for creating complex SwiftUI previews that
    /// require their own state management or setup logic.
    private struct GridView_Preview_Wrapper: View {
        // MARK: State
        // The wrapper view now correctly owns all the state needed for the preview.
        @StateObject private var viewModel = GameViewModel()
        @State private var highlightedPath: [GridCoordinate] = []
        @State private var invalidShake = 0

        var body: some View {
            // We use a Group to allow for conditional logic inside.
            Group {
                // We only attempt to show the GridView if the grid data is available.
                if let grid = viewModel.gameState?.grid {
                    GridView(
                        grid: grid,
                        onPathValidated: { path in
                            // For the preview, we can just print the result.
                            print("Path validated in preview: \(path)")
                            // We could even simulate the full validation for a more interactive preview.
                            // let _ = viewModel.validatePath(path)
                        },
                        highlightedPath: $highlightedPath,
                        invalidShake: $invalidShake
                    )
                    .frame(width: 350, height: 350)
                    .padding()
                } else {
                    Text("Loading Preview...")
                }
            }
            // .onAppear is the correct place to put setup logic that doesn't return a View.
            // It runs once when the view is first drawn.
            .onAppear {
                viewModel.startNewGame(puzzleIndex: 0)
            }
        }
    }

    struct GridView_Previews: PreviewProvider {
        static var previews: some View {
            // The preview provider is now incredibly simple: it just returns our wrapper.
            GridView_Preview_Wrapper()
        }
    }
#endif
