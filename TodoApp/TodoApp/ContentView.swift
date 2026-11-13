import SwiftUI

/// Root container view that manages top-level authentication state switching.
struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                TodoListView(userUID: user.uid)
                    .environmentObject(authViewModel)
            } else {
                NavigationStack {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}
