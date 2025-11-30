//
//  FamilyViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FamilyViewModel: ObservableObject {
    @Published var families: [Family] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func loadData() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("families")
                .whereField("createdBy", isEqualTo: userId)
                .getDocuments()
            
            families = snapshot.documents.compactMap { doc in
                try? doc.data(as: Family.self)
            }
            print("FamilyViewModel: Loaded \(families.count) families")
        } catch {
            print("Error loading families: \(error.localizedDescription)")
        }
    }
    
    func createFamily(name: String) async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        let family = Family(
            name: name,
            createdBy: userId,
            members: [FamilyMember(userId: userId, role: .admin)]
        )
        
        _ = try db.collection("families").addDocument(from: family)
        await loadData()
    }
}

