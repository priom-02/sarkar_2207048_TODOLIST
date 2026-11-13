import SwiftUI

/// Screen modal sheet for editing an existing task.
struct EditTaskView: View {
    let task: TodoTask
    @ObservedObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var isCompleted: Bool
    @State private var validationError: String? = nil
    @State private var isSubmitting: Bool = false
    
    init(task: TodoTask, todoViewModel: TodoViewModel) {
        self.task = task
        self.todoViewModel = todoViewModel
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title (Required)", text: $title)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("Status")) {
                    Toggle("Mark as Completed", isOn: $isCompleted)
                }
                
                if let error = validationError ?? todoViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateTask()
                    }
                    .disabled(isSubmitting || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func updateTask() {
        validationError = nil
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationError = "Title is required."
            return
        }
        
        var updated = task
        updated.title = trimmedTitle
        updated.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.isCompleted = isCompleted
        
        isSubmitting = true
        Task {
            let success = await todoViewModel.updateTask(updated)
            isSubmitting = false
            if success {
                dismiss()
            }
        }
    }
}

