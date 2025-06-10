//
//  ContentView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-07.
//

import SwiftUI

// =================================================================================
// MARK: - Temporary Testing Host
// =================================================================================
//
// IMPORTANT: This view has been temporarily modified to act as a direct host
// for the main game screen (`GridView` + `WordListView`). This is a "quick and dirty"
// solution purely for testing and development purposes in the simulator.
//
// The final application will have a proper navigation structure (see Task 17).
// The content of this view will be moved to a dedicated `GameView.swift` (see Task 15)
// and this `ContentView` will become the app's main entry point with a menu.
//
// Please do not build permanent logic here.
//
// =================================================================================

struct ContentView: View {
    // We use `@StateObject` to create and manage the lifecycle of our GameViewModel.
    // `@StateObject` ensures that the `viewModel` is created only once for this view
    // and is kept alive for the entire time the view is on screen. This is the
    // correct property wrapper for when a view "owns" its view model.
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        // This VStack is a temporary layout container for our main game components.
        // In the final design, this layout will live in `GameView.swift`.
        VStack(spacing: 8) {
            // A simple header to show the puzzle title.
            if let puzzleTitle = viewModel.gameState?.puzzle.title {
                Text(puzzleTitle)
                    // We've adjusted the font to be slightly smaller and added bottom padding
                    // to create more visual separation between the title and the grid.
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom)
            }

            // The main interactive grid. It observes the viewModel for state changes.
            GridView(viewModel: viewModel)
                .padding(.horizontal)

            // The list of found words, grouped by length. It also observes the viewModel.
            WordListView(viewModel: viewModel)
        }
        // The `.onAppear` modifier is a convenient way to trigger an action
        // as soon as the view is displayed. Here, we use it to load our first
        // puzzle automatically. This is temporary; in the final app, puzzle
        // selection will happen from a menu.
        .onAppear {
            viewModel.startNewGame(puzzleIndex: 0)
        }
    }
}

#Preview {
    ContentView()
}
