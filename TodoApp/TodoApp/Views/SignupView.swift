import SwiftUI

/// Screen allowing new users to register with Email and Password.
struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var validationError: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("Create Account")
                        .font(.largeTitle.bold())
                    
                    Text("Join to organize your tasks with Firebase")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Form Fields
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("name@university.edu", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password (minimum 6 characters)")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        SecureField("Create a strong password", text: $password)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        SecureField("Re-enter your password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    // Validation or Backend Error Display
                    if let error = validationError ?? authViewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Register Button
                    Button(action: handleSignup) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(authViewModel.isLoading)
                }
                .padding(.horizontal)
                
                // Back to Login Link
                Button(action: { dismiss() }) {
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleSignup() {
        validationError = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            validationError = "Please enter an email address."
            return
        }
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            validationError = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            validationError = "Password must be at least 6 characters."
            return
        }
        guard password == confirmPassword else {
            validationError = "Passwords do not match."
            return
        }
        
        Task {
            await authViewModel.signup(email: trimmedEmail, password: password)
        }
    }
}

#if DEBUG
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignupView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif

