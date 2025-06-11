//
//  ContentView.swift
//  WordFlow
//
//  Created by Rich Tape on 2025-06-07.
//

import SwiftUI

// =================================================================================
// MARK: - Main App Container
// =================================a=================================================
//
// `ContentView` is the root view of our application.
//
// Its role has now been simplified. It no longer contains complex layout code.
// Instead, its primary responsibility is to act as a container for the main
// views of the app.
//
// For now, it directly displays the `GameView`. In the future (Task 17), this
// view will be updated to use a `NavigationStack` to manage transitions between
// different screens, such as a main menu, settings, and the game screen.
//
// =================================================================================

struct ContentView: View {
    var body: some View {
        // We now simply embed our self-contained `GameView` here.
        // This makes our `ContentView` clean and easy to understand. It acts as the
        // entry point that directs the user to the initial screen of the app.
        GameView()
    }
}

#Preview {
    ContentView()
}
