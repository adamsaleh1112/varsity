import Foundation
import Supabase

final class UserFollowService {
    private let supabase = SupabaseManager.shared.client
    
    func followSchool(userId: UUID, schoolId: UUID) async throws {
        let follow = UserFollow(
            id: UUID(),
            userId: userId,
            schoolId: schoolId,
            followedAt: ISO8601DateFormatter().string(from: Date()),
            notificationsEnabled: true
        )
        
        try await supabase
            .from("user_follows")
            .insert(follow)
            .execute()
    }
    
    func unfollowSchool(userId: UUID, schoolId: UUID) async throws {
        try await supabase
            .from("user_follows")
            .delete()
            .eq("user_id", value: userId)
            .eq("school_id", value: schoolId)
            .execute()
    }
    
    func getFollowedSchools(for userId: UUID) async throws -> [UUID] {
        let follows: [UserFollow] = try await supabase
            .from("user_follows")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return follows.map { $0.schoolId }
    }
    
    func isFollowing(userId: UUID, schoolId: UUID) async throws -> Bool {
        let follows: [UserFollow] = try await supabase
            .from("user_follows")
            .select()
            .eq("user_id", value: userId)
            .eq("school_id", value: schoolId)
            .execute()
            .value
        
        return !follows.isEmpty
    }
}
