import Foundation
import AuthenticationServices
import Combine

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: MockUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // For development, start unauthenticated
        isAuthenticated = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate Apple Sign-In for development (no delay)
        await createMockAppleUser()
        isLoading = false
    }
    
    private func createMockAppleUser() async {
        // Mock Apple Sign-In for development
        let mockUser = MockUser(
            id: UUID(),
            email: "user@icloud.com",
            displayName: "Apple User",
            avatarURL: nil,
            authProvider: "apple",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            lastLogin: ISO8601DateFormatter().string(from: Date())
        )
        
        currentUser = mockUser
        isAuthenticated = true
    }
    
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Mock email/password authentication for development
        await createMockEmailUser(email: email)
        isLoading = false
    }
    
    private func createMockEmailUser(email: String) async {
        // Mock email/password sign-in for development
        let mockUser = MockUser(
            id: UUID(),
            email: email,
            displayName: email.components(separatedBy: "@").first?.capitalized ?? "User",
            avatarURL: nil,
            authProvider: "email",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            lastLogin: ISO8601DateFormatter().string(from: Date())
        )
        
        currentUser = mockUser
        isAuthenticated = true
    }
    
    func signOut() async {
        currentUser = nil
        isAuthenticated = false
    }
}

// Mock user model for development
struct MockUser: Identifiable {
    let id: UUID
    let email: String?
    let displayName: String?
    let avatarURL: String?
    let authProvider: String
    let createdAt: String
    let lastLogin: String?
}
