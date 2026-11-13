import Foundation
import FirebaseAuth

/// Protocol defining authentication operations for dependency injection and testing.
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func registerUser(email: String, password: String) async throws -> User
    func loginUser(email: String, password: String) async throws -> User
    func logoutUser() throws
}

/// Service handling Firebase Authentication operations.
final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    private init() {}
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func registerUser(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authResult.user
    }
    
    func loginUser(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user
    }
    
    func logoutUser() throws {
        try Auth.auth().signOut()
    }
}

