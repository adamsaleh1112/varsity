import Foundation

final class UserFollowService {
    // Mock storage for development
    private var mockFollows: Set<UUID> = []
    
    func followSchool(userId: UUID, schoolId: UUID) async throws {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        mockFollows.insert(schoolId)
    }
    
    func unfollowSchool(userId: UUID, schoolId: UUID) async throws {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        mockFollows.remove(schoolId)
    }
    
    func getFollowedSchools(for userId: UUID) async throws -> [UUID] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return Array(mockFollows)
    }
    
    func isFollowing(userId: UUID, schoolId: UUID) async throws -> Bool {
        return mockFollows.contains(schoolId)
    }
}
