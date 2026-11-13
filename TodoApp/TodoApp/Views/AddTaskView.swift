import SwiftUI

/// Screen modal sheet for creating a new task.
struct AddTaskView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var validationError: String? = nil
    @State private var isSubmitting: Bool = false
    
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
                
                if let error = validationError ?? todoViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Task")
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
                        saveTask()
                    }
                    .disabled(isSubmitting || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        validationError = nil
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationError = "Title is required."
            return
        }
        
        isSubmitting = true
        Task {
            let success = await todoViewModel.addTask(
                title: trimmedTitle,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            isSubmitting = false
            if success {
                dismiss()
            }
        }
    }
}

