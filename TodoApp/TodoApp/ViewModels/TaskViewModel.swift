import Foundation

/// ViewModel handling Todo task operations (CRUD) for the current user.
@MainActor
final class TodoViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let firestoreService: FirestoreServiceProtocol
    let userUID: String
    
    init(userUID: String, firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.userUID = userUID
        self.firestoreService = firestoreService
    }
    
    func fetchTasks() async {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try await firestoreService.fetchTasks(for: userUID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addTask(title: String, description: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        let task = TodoTask(title: title, description: description, isCompleted: false)
        do {
            let newID = try await firestoreService.addTask(task, for: userUID)
            var createdTask = task
            createdTask.id = newID
            createdTask.createdAt = Date()
            createdTask.updatedAt = Date()
            tasks.insert(createdTask, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateTask(_ task: TodoTask) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await firestoreService.updateTask(task, for: userUID)
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteTask(task: TodoTask) async {
        guard let taskID = task.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await firestoreService.deleteTask(taskID: taskID, for: userUID)
            tasks.removeAll { $0.id == taskID }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func toggleTaskCompletion(task: TodoTask) async {
        var updated = task
        updated.isCompleted.toggle()
        _ = await updateTask(updated)
    }
}
