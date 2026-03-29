import Foundation
import Combine
import CryptoKit
import Supabase

@MainActor
final class SimpleAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: SimpleUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client

    init() {
        // Start unauthenticated - simple approach
        isAuthenticated = false
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
        
        // Validate username format
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
        
        // Check if username or email already exists
        do {
            let existingUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .select()
                .or("username.eq.\(username),email.eq.\(email)")
                .execute()
                .value
            
            if let existingUser = existingUsers.first {
                if existingUser.username == username {
                    errorMessage = "Username already exists"
                } else {
                    errorMessage = "Email already exists"
                }
                isLoading = false
                return
            }
        } catch {
            errorMessage = "Error checking existing users"
            isLoading = false
            return
        }
        
        // Create new user
        do {
            let passwordHash = hashPassword(password)
            let newUserInsert = SimpleUserInsert(
                username: username,
                email: email,
                passwordHash: passwordHash
            )
            
            let insertedUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .insert(newUserInsert)
                .select()
                .execute()
                .value
            
            if let user = insertedUsers.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Database error: \(error)")
            errorMessage = "Error creating account"
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
        
        // Find user by username
        do {
            let users: [SimpleUser] = try await supabase
                .from("simple_users")
                .select()
                .eq("username", value: username)
                .execute()
                .value
            
            guard let user = users.first else {
                errorMessage = "Username not found"
                isLoading = false
                return
            }
            
            // Verify password
            let passwordHash = hashPassword(password)
            guard user.passwordHash == passwordHash else {
                errorMessage = "Incorrect password"
                isLoading = false
                return
            }
            
            // Sign in successful
            currentUser = user
            isAuthenticated = true
        } catch {
            print("Database error: \(error)")
            errorMessage = "Error signing in"
        }
        
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = "Apple Sign-In coming soon. Please use username/password for now."
        isLoading = false
    }
    
    func updateProfile(displayName: String?, bio: String?, avatarUrl: String?) async {
        guard let currentUser = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Update user in database
        do {
            let updateData = SimpleUserUpdate(
                displayName: displayName,
                bio: bio,
                avatarUrl: avatarUrl,
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
            
            let updatedUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .update(updateData)
                .eq("id", value: currentUser.id)
                .select()
                .execute()
                .value
            
            if let updatedUser = updatedUsers.first {
                self.currentUser = updatedUser
            }
        } catch {
            print("Profile update error: \(error)")
            errorMessage = "Error updating profile"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        currentUser = nil
        isAuthenticated = false
    }
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Simple user models
struct SimpleUser: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let passwordHash: String
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case passwordHash = "password_hash"
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SimpleUserInsert: Codable {
    let username: String
    let email: String
    let passwordHash: String
    
    enum CodingKeys: String, CodingKey {
        case username, email
        case passwordHash = "password_hash"
    }
}

struct SimpleUserUpdate: Codable {
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case updatedAt = "updated_at"
    }
}

struct SimpleUserFollow: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let followedAt: String
    let notificationsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case followedAt = "followed_at"
        case notificationsEnabled = "notifications_enabled"
    }
}

struct SimpleUserFollowInsert: Codable {
    let userId: UUID
    let schoolId: UUID
    let notificationsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case schoolId = "school_id"
        case notificationsEnabled = "notifications_enabled"
    }
}
