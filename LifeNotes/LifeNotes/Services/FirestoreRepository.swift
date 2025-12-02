import Foundation
import FirebaseFirestore

@MainActor
class FirestoreRepository<T: Codable> {
    private let db = Firestore.firestore()
    private let collectionName: String
    private var listener: ListenerRegistration?
    
    init(collectionName: String) {
        self.collectionName = collectionName
    }
    
    func create(_ item: T) async throws -> String {
        let docRef = try db.collection(collectionName).addDocument(from: item)
        return docRef.documentID
    }
    
    func update(_ item: T, documentId: String) async throws {
        print("🔄 FirestoreRepository: Updating document \(documentId) in collection '\(collectionName)'")
        try db.collection(collectionName).document(documentId).setData(from: item)
        print("✅ FirestoreRepository: Document \(documentId) updated successfully")
    }
    
    func delete(documentId: String) async throws {
        try await db.collection(collectionName).document(documentId).delete()
    }
    
    func get(documentId: String) async throws -> T? {
        let doc = try await db.collection(collectionName).document(documentId).getDocument()
        return try? doc.data(as: T.self)
    }
    
    func query(field: String, isEqualTo value: Any) async throws -> [T] {
        let snapshot = try await db.collection(collectionName)
            .whereField(field, isEqualTo: value)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: T.self)
        }
    }
    
    func query(field: String, in values: [Any]) async throws -> [T] {
        let snapshot = try await db.collection(collectionName)
            .whereField(field, in: values)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: T.self)
        }
    }
    
    func listen(field: String, isEqualTo value: Any, onChange: @escaping ([T]) -> Void) {
        listener?.remove()
        
        let collection = collectionName
        listener = db.collection(collectionName)
            .whereField(field, isEqualTo: value)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to \(collection): \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let items = documents.compactMap { doc in
                    try? doc.data(as: T.self)
                }
                
                onChange(items)
            }
    }
    
    func listen(field: String, in values: [Any], onChange: @escaping ([T]) -> Void) {
        listener?.remove()
        
        let collection = collectionName
        listener = db.collection(collectionName)
            .whereField(field, in: values)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to \(collection): \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let items = documents.compactMap { doc in
                    try? doc.data(as: T.self)
                }
                
                onChange(items)
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        listener?.remove()
    }
}

