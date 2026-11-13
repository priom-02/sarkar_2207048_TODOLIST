import SwiftUI

/// Screen allowing existing users to log in with Email and Password.
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var validationError: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("Firebase Todo")
                        .font(.largeTitle.bold())
                    
                    Text("Sign in to manage your tasks")
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
                        Text("Password")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        SecureField("Enter your password", text: $password)
                            .textContentType(.password)
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
                    
                    // Login Button
                    Button(action: handleLogin) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Sign In")
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
                
                // Navigation to Signup
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink(destination: SignupView().environmentObject(authViewModel)) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Sign In")
        .navigationBarHidden(true)
    }
    
    private func handleLogin() {
        validationError = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            validationError = "Please enter your email."
            return
        }
        guard password.count >= 6 else {
            validationError = "Password must be at least 6 characters."
            return
        }
        
        Task {
            await authViewModel.login(email: trimmedEmail, password: password)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
#endif

