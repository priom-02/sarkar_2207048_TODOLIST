import SwiftUI
import FirebaseCore

/// Main entry point for the Todo application.
/// Configures Firebase services during initialization and sets up the root view.
@main
struct TodoAppApp: App {
    
    init() {
        guard FirebaseApp.app() == nil else {
            return
        }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            assertionFailure("GoogleService-Info.plist is missing from the app bundle.")
            return
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
