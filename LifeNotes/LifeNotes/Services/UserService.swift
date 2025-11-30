import Foundation
import FirebaseFirestore

@MainActor
class UserService {
    static let shared = UserService()
    
    private let db = Firestore.firestore()
    private let repository: FirestoreRepository<User>
    
    private init() {
        self.repository = FirestoreRepository(collectionName: "users")
    }
    
    func getPremiumStatus(userId: String) async -> Bool {
        do {
            if let user = try await repository.get(documentId: userId) {
                return user.isPremium
            }
        } catch {
            print("Error loading premium status: \(error.localizedDescription)")
        }
        return false
    }
    
    func getUser(userId: String) async throws -> User? {
        return try await repository.get(documentId: userId)
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else { return }
        try await repository.update(user, documentId: userId)
    }
}

