import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Protocol defining Cloud Firestore CRUD operations for Todo Tasks.
protocol FirestoreServiceProtocol {
    func fetchTasks(for userUID: String) async throws -> [TodoTask]
    func addTask(_ task: TodoTask, for userUID: String) async throws -> String
    func updateTask(_ task: TodoTask, for userUID: String) async throws
    func deleteTask(taskID: String, for userUID: String) async throws
}

/// Service implementing Cloud Firestore CRUD operations under users/{userUID}/tasks/{taskID}
final class FirestoreService: FirestoreServiceProtocol {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func tasksCollection(for userUID: String) -> CollectionReference {
        return db.collection("users").document(userUID).collection("tasks")
    }
    
    func fetchTasks(for userUID: String) async throws -> [TodoTask] {
        let snapshot = try await tasksCollection(for: userUID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: TodoTask.self)
        }
    }
    
    func addTask(_ task: TodoTask, for userUID: String) async throws -> String {
        var newTask = task
        let now = Date()
        newTask.createdAt = now
        newTask.updatedAt = now
        
        let docRef = try tasksCollection(for: userUID).addDocument(from: newTask)
        return docRef.documentID
    }
    
    func updateTask(_ task: TodoTask, for userUID: String) async throws {
        guard let taskID = task.id else {
            throw NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID missing"])
        }
        var updatedTask = task
        updatedTask.updatedAt = Date()
        try tasksCollection(for: userUID).document(taskID).setData(from: updatedTask, merge: true)
    }
    
    func deleteTask(taskID: String, for userUID: String) async throws {
        try await tasksCollection(for: userUID).document(taskID).delete()
    }
}

