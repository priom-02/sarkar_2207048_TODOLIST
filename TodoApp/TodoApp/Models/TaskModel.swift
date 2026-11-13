import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Model representing a single Todo Task.
/// Stored in Cloud Firestore at: `users/{userUID}/tasks/{taskID}`
///
/// Conforms to:
/// - `Identifiable`: Allows SwiftUI `List` and `ForEach` to uniquely identify each row using `id`.
/// - `Codable`: Enables automatic encoding and decoding between this Swift struct and Firestore documents.
/// - `Equatable`: Allows SwiftUI to compare two tasks to determine if UI re-rendering is necessary.
struct TodoTask: Identifiable, Codable, Equatable {
    
    /// Unique identifier for the task document in Firestore.
    /// The `@DocumentID` property wrapper tells Firestore to automatically map the document ID
    /// from Firestore to this variable when decoding, and omits it when writing the document body.
    @DocumentID var id: String?
    
    /// Title of the task (e.g., "Complete Mobile Computing Assignment").
    var title: String
    
    /// Detailed description of the task requirements or notes.
    var description: String
    
    /// Boolean flag indicating whether the task has been completed.
    var isCompleted: Bool
    
    /// Date when the task was created.
    /// The `@ServerTimestamp` property wrapper causes Firestore to write the server's current timestamp
    /// when saving a new document, preventing client clock drift.
    @ServerTimestamp var createdAt: Date?
    
    /// Date when the task was last edited or modified.
    @ServerTimestamp var updatedAt: Date?
    
    /// Explicit memberwise initializer with practical defaults.
    /// - Parameters:
    ///   - id: Optional document ID (nil for new tasks not yet written to Firestore).
    ///   - title: Non-empty task title.
    ///   - description: Optional descriptive text (defaults to empty string).
    ///   - isCompleted: Initial completion state (defaults to false).
    ///   - createdAt: Creation timestamp (defaults to nil, populated by Firestore server timestamp).
    ///   - updatedAt: Update timestamp (defaults to nil, populated by Firestore server timestamp).
    init(
        id: String? = nil,
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Sample Data for Previews and Testing
extension TodoTask {
    /// Sample tasks used for SwiftUI Previews and offline testing.
    static let sampleTasks: [TodoTask] = [
        TodoTask(
            id: "sample_task_1",
            title: "Study SwiftUI State Management",
            description: "Understand @State, @Binding, @StateObject, and @ObservedObject.",
            isCompleted: true,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date().addingTimeInterval(-3600)
        ),
        TodoTask(
            id: "sample_task_2",
            title: "Configure Firebase Authentication",
            description: "Set up Email/Password auth in Firebase Console and test registration.",
            isCompleted: false,
            createdAt: Date().addingTimeInterval(-3600),
            updatedAt: Date().addingTimeInterval(-1800)
        ),
        TodoTask(
            id: "sample_task_3",
            title: "Test CRUD on University Mac",
            description: "Clone repo from GitHub, open in Xcode, and run on iPhone 15 simulator.",
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
