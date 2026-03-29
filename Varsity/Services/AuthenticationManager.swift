import Foundation
import AuthenticationServices
import Combine
import Supabase

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client

    init() {
        checkAuthenticationStatus()
    }

    func checkAuthenticationStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                await loadCurrentUser()
                isAuthenticated = currentUser != nil
            } catch {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func signUpWithUsername(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username, email, and password"
            isLoading = false
            return
        }
        
        guard username.count >= 4 else {
            errorMessage = "Username must be at least 4 characters"
            isLoading = false
            return
        }
        
        // Validate username format (alphanumeric, dots, dashes, underscores only)
        let usernameRegex = "^[a-zA-Z0-9._-]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        guard usernamePredicate.evaluate(with: username) else {
            errorMessage = "Username can only contain letters, numbers, dots, dashes, and underscores"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Check if username already exists
        do {
            let existingUsers: [User] = try await supabase
                .from("users")
                .select()
                .eq("username", value: username)
                .execute()
                .value
            
            if !existingUsers.isEmpty {
                errorMessage = "Username already exists. Please choose a different one."
                isLoading = false
                return
            }
        } catch {
            errorMessage = "Error checking username availability"
            isLoading = false
            return
        }
        
        do {
            // Sign up with Supabase Auth, passing username in metadata
            let response = try await supabase.auth.signUp(
                email: email, 
                password: password,
                data: ["username": .string(username)]
            )
            await loadCurrentUser()
            isAuthenticated = currentUser != nil
        } catch {
            print("Signup error: \(error)")
            if error.localizedDescription.contains("duplicate") || error.localizedDescription.contains("unique") {
                errorMessage = "Username or email already exists"
            } else {
                errorMessage = "Database error saving new user"
            }
        }
        
        isLoading = false
    }

    func signInWithUsername(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            isLoading = false
            return
        }
        
        guard username.count >= 4 else {
            errorMessage = "Username must be at least 4 characters"
            isLoading = false
            return
        }
        
        // Find user by username to get their email
        do {
            let users: [User] = try await supabase
                .from("users")
                .select()
                .eq("username", value: username)
                .execute()
                .value
            
            guard let user = users.first, let email = user.email else {
                errorMessage = "Username not found"
                isLoading = false
                return
            }
            
            // Sign in with email and password
            let response = try await supabase.auth.signIn(email: email, password: password)
            await loadCurrentUser()
            isAuthenticated = currentUser != nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement Apple Sign-In with Supabase
        // For now, show message that it's not implemented yet
        errorMessage = "Apple Sign-In coming soon. Please use email/password for now."
        
        isLoading = false
    }
    
    private func loadCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            guard session.user != nil else { 
                currentUser = nil
                return 
            }
            let authUser = session.user
            
            // Fetch user profile from our users table
            let users: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: authUser.id)
                .execute()
                .value
            
            currentUser = users.first
        } catch {
            print("Error loading user: \(error)")
            currentUser = nil
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
