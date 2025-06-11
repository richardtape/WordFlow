//
//  GameView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-12.
//

import SwiftUI

/// The main view for the game screen, encapsulating all game-related UI components.
///
/// This view is responsible for laying out the puzzle title, score, interactive grid, and the list of found words.
/// By creating a dedicated `GameView`, we follow good SwiftUI practice, making our UI modular and reusable.
/// This view "owns" the `GameViewModel`, creating it as a `@StateObject` to ensure its lifecycle
/// is tied to the view's presence on screen.
struct GameView: View {
    // We use `@StateObject` to create and manage the lifecycle of our GameViewModel.
    // This is the correct property wrapper for when a view "owns" and creates its view model.
    // The viewModel is the single source of truth for the game's state.
    @StateObject private var viewModel = GameViewModel()

    // MARK: - State for UI Feedback

    /// A state property to control the presentation of the puzzle completion alert.
    @State private var isCompletionAlertPresented = false

    /// The text for the dynamic feedback message (e.g., "Already Found", "+100").
    @State private var feedbackMessage: String? = nil

    /// The color of the feedback message, which can change based on the context (e.g., green for success, red for error).
    @State private var feedbackMessageColor: Color = .primary

    /// The timer that automatically hides the feedback message after a short delay.
    @State private var feedbackTimer: Timer? = nil

    // MARK: - State for Animations
    /// The path of a word to be briefly highlighted on success.
    @State private var highlightedPath: [GridCoordinate] = []
    /// A counter that, when changed, triggers the shake animation on the grid.
    @State private var invalidShake = 0

    var body: some View {
        // The main vertical stack that arranges all the game elements.
        VStack(spacing: 8) {
            // A simple header to show the puzzle title. It only appears when a game is loaded.
            if let puzzleTitle = viewModel.gameState?.puzzle.title {
                Text(puzzleTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom)
            }

            // --- Status Header ---
            // This HStack arranges the score and the dynamic feedback message side-by-side.
            // This is a more compact layout that saves vertical space.
            HStack {
                // Display the player's current score. It's always visible.
                if let score = viewModel.gameState?.score {
                    Text("Score: \(score)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(UIColor.systemBlue))
                }

                Spacer() // Pushes the score to the left and the message to the right.

                // The dynamic feedback message area.
                if let message = feedbackMessage {
                    Text(message)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(feedbackMessageColor)
                        // A capsule shape provides a modern, pill-like background.
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(feedbackMessageColor.opacity(0.15))
                        .clipShape(Capsule())
                        // The transition defines how the view appears and disappears.
                        // .move slides it in from the right, and .opacity fades it.
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            // Animate changes within the HStack.
            .animation(.easeInOut, value: feedbackMessage)

            // The main interactive grid. We now pass in the grid data and a completion handler
            // directly, rather than passing the entire view model. This makes our GridView
            // a more reusable and "dumb" component, which is good architectural practice.
            if let grid = viewModel.gameState?.grid {
                GridView(
                    grid: grid,
                    onPathValidated: { path in
                        // When the GridView reports a completed path, we pass it to the viewModel.
                        let result = viewModel.validatePath(path)
                        // We then pass the result to our dedicated handler function.
                        handleValidation(result)
                    },
                    // We pass bindings to our state variables so the GridView can reflect animations
                    // controlled by this parent view.
                    highlightedPath: $highlightedPath,
                    invalidShake: $invalidShake
                )
                .padding(.horizontal)
            } else {
                // Show a progress view if the grid hasn't been loaded yet.
                ProgressView("Loading Grid...")
            }

            // The list of found words, grouped by length. It also observes the viewModel.
            WordListView(viewModel: viewModel)
        }
        // When the game's completion status changes, we check if we should show the alert.
        .onChange(of: viewModel.gameState?.isComplete) { isComplete in
            if isComplete == true {
                // Setting this state property to true will trigger the .alert() modifier below.
                self.isCompletionAlertPresented = true
            }
        }
        // This modifier presents a standard iOS alert when `isCompletionAlertPresented` is true.
        .alert("Puzzle Complete!", isPresented: $isCompletionAlertPresented) {
            // The alert includes a button that allows the user to start a new game.
            Button("Play Again") {
                viewModel.startRandomNewGame()
            }
        } message: {
            // The descriptive text inside the alert, showing the final score.
            Text("Congratulations! Your final score is \(viewModel.gameState?.score ?? 0).")
        }
        .onAppear {
            viewModel.startNewGame(puzzleIndex: 0)
        }
    }

    /// A centralized handler to process the result of a path validation.
    /// This method is passed down to the GridView, keeping the logic clean and in one place.
    /// - Parameter result: The `PathValidationResult` from the `GameViewModel`.
    private func handleValidation(_ result: PathValidationResult?) {
        guard let result = result else { return }

        var message: String
        var color: Color

        switch result {
        case .success(_, let score, let path):
            message = "+\(score)"
            color = .green
            // On success, we trigger the flash effect for the successful path.
            flash(path: path)
        case .alreadyFound:
            message = "Already Found"
            color = .orange
            shake() // Shake on a recoverable error.
        case .invalidWord:
            message = "Invalid Word"
            color = .red
            shake() // Shake on an invalid attempt.
        case .tooShort:
            message = "Too Short"
            color = .orange
            shake() // Shake on a recoverable error.
        }

        // Set the message and color, which will trigger the view to update.
        self.feedbackMessage = message
        self.feedbackMessageColor = color

        // Invalidate any existing timer to ensure messages don't disappear too early.
        feedbackTimer?.invalidate()

        // Schedule a new timer to hide the message after 2 seconds.
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.feedbackMessage = nil
        }
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

#Preview {
    GameView()
}