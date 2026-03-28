import Foundation
import Combine

@MainActor
final class UserFollowViewModel: ObservableObject {
    @Published var followedSchoolIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let followService = UserFollowService()
    
    func loadFollowedSchools(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let schoolIds = try await followService.getFollowedSchools(for: userId)
            followedSchoolIds = Set(schoolIds)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFollow(userId: UUID, schoolId: UUID) async {
        do {
            if followedSchoolIds.contains(schoolId) {
                try await followService.unfollowSchool(userId: userId, schoolId: schoolId)
                followedSchoolIds.remove(schoolId)
            } else {
                try await followService.followSchool(userId: userId, schoolId: schoolId)
                followedSchoolIds.insert(schoolId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func isFollowing(_ schoolId: UUID) -> Bool {
        return followedSchoolIds.contains(schoolId)
    }
}
