//
//  GridView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-08.
//

import SwiftUI

/// A view that arranges `LetterSquareView`s into a responsive, interactive grid.
///
/// This view is responsible for the overall layout of the puzzle. It takes a `Grid` data model
/// and dynamically calculates the size of each square to ensure the entire puzzle fits
/// perfectly on any device screen, from a small iPhone to a large iPad.
struct GridView: View {
    /// The data model representing the puzzle grid, containing all the squares and their properties.
    let grid: Grid

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
        // GeometryReader is a container view that provides the size of the parent view.
        // It's the key to making our grid responsive. We use its size to calculate the
        // dimensions of our letter squares.
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
                        // The state is determined by whether the square is in the confirmed path or is the current candidate.
                        state: currentPath.contains(square.coordinate) || square.coordinate == candidateCoord ? .selected : square.state,
                        // We pass the dynamically calculated size to each square.
                        size: squareSize
                    )
                }
            }
            // We attach the drag gesture to the grid container.
            .gesture(dragGesture(squareSize: squareSize))
        }
        // Add some padding around the entire grid.
        .padding(spacing)
        // Set a background color for the grid container to visually separate it from the screen background.
        .background(Color(.systemGray6))
        // Round the corners of the grid container for a modern UI look.
        .cornerRadius(12)
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
                guard let hoveredCoord = coordinate(for: value.location, in: squareSize) else {
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
                    selectionTimer?.invalidate() // Cancel any pending selection.
                    candidateCoord = nil
                    currentPath.removeLast()
                    triggerHapticFeedback()
                    return
                }

                // 2. We've moved to a new square. If it's different from our current candidate,
                // we need to update our intention.
                if hoveredCoord != candidateCoord {
                    selectionTimer?.invalidate() // Cancel the timer for the old candidate.

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

                // Here is where we will eventually add word validation logic.
                #if DEBUG
                print("Drag ended. Final path: \(currentPath.map { "(\($0.x),\($0.y))" }))")
                #endif

                // Reset for the next gesture.
                currentPath.removeAll()
                candidateCoord = nil
            }
    }

    /// Schedules the confirmation of a square selection after a short delay.
    /// - Parameter coordinate: The `GridCoordinate` to be selected.
    private func scheduleSelection(of coordinate: GridCoordinate) {
        selectionTimer = Timer.scheduledTimer(withTimeInterval: selectionDelay, repeats: false) { _ in
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
    private func coordinate(for location: CGPoint, in squareSize: CGFloat) -> GridCoordinate? {
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
}


// MARK: - Preview
#if DEBUG
struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        // Using a ScrollView allows us to see both grids without them overlapping,
        // even on smaller preview screens.
        ScrollView {
            // Using a VStack to show multiple previews at once is a great way to test
            // different configurations side-by-side.
            VStack(spacing: 20) {
                Text("3x3 Grid")
                    .font(.headline)
                GridView(grid: mockGrid(width: 3, height: 3))
                    // We provide a fixed frame in the preview for demonstration purposes.
                    // In the actual app, the GeometryReader will use the screen size.
                    .frame(width: 300, height: 300)

                Text("5x5 Grid")
                    .font(.headline)
                GridView(grid: mockGrid(width: 5, height: 5))
                    .frame(width: 300, height: 300)
            }
            .padding()
        }
    }

    /// A helper function to generate a mock `Grid` of any size for testing in previews.
    /// This is more flexible than having a single, hard-coded mock grid.
    static func mockGrid(width: Int, height: Int) -> Grid {
        let size = GridSize(width: width, height: height)
        var squares = [LetterSquare]()
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for i in 0..<(width * height) {
            let letter = String(letters.randomElement()!)
            let x = i % size.width
            let y = i / size.width
            squares.append(
                LetterSquare(letter: letter, coordinate: GridCoordinate(x: x, y: y), state: .normal)
            )
        }
        return Grid(size: size, squares: squares)
    }
}
#endif