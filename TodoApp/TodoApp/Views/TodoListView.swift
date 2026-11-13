import SwiftUI

/// Main screen displaying the user's tasks stored in Cloud Firestore.
struct TodoListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var todoViewModel: TodoViewModel
    
    @State private var showingAddTaskSheet = false
    @State private var taskToEdit: TodoTask? = nil
    @State private var taskToDelete: TodoTask? = nil
    @State private var showingDeleteAlert = false
    @State private var showingLogoutAlert = false
    
    init(userUID: String = AuthService.shared.currentUser?.uid ?? "") {
        _todoViewModel = StateObject(wrappedValue: TodoViewModel(userUID: userUID))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if todoViewModel.isLoading && todoViewModel.tasks.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading your tasks...")
                            .foregroundColor(.secondary)
                    }
                } else if todoViewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive, action: { showingLogoutAlert = true }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTaskSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                AddTaskView(todoViewModel: todoViewModel)
            }
            .sheet(item: $taskToEdit) { task in
                EditTaskView(task: task, todoViewModel: todoViewModel)
            }
            .alert("Delete Task", isPresented: $showingDeleteAlert, presenting: taskToDelete) { task in
                Button("Delete", role: .destructive) {
                    Task {
                        await todoViewModel.deleteTask(task: task)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { task in
                Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out of your account?")
            }
            .task {
                await todoViewModel.fetchTasks()
            }
            .refreshable {
                await todoViewModel.fetchTasks()
            }
        }
    }
    
    // MARK: - Task List View
    private var taskList: some View {
        List {
            ForEach(todoViewModel.tasks) { task in
                TaskRowView(
                    task: task,
                    onToggle: {
                        Task {
                            await todoViewModel.toggleTaskCompletion(task: task)
                        }
                    },
                    onEdit: {
                        taskToEdit = task
                    },
                    onDelete: {
                        taskToDelete = task
                        showingDeleteAlert = true
                    }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Tasks Yet")
                .font(.title2.bold())
            
            Text("Tap the '+' button above to add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: { showingAddTaskSheet = true }) {
                Label("Add Your First Task", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

// MARK: - Task Row Component
struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Checkbox button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
            
            // Action Menu
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
    }
}

#if DEBUG
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .environmentObject(AuthViewModel())
    }
}
#endif

