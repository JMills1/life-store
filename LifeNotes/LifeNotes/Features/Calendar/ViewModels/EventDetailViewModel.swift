//
//  EventDetailViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var event: Event
    @Published var comments: [EventComment] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var commentsListener: ListenerRegistration?
    
    init(event: Event) {
        self.event = event
    }
    
    func loadComments() async {
        guard let eventId = event.id else { return }
        
        commentsListener?.remove()
        commentsListener = db.collection("eventComments")
            .whereField("eventId", isEqualTo: eventId)
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading comments: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.comments = documents.compactMap { doc in
                    try? doc.data(as: EventComment.self)
                }
                
                print("Loaded \(self.comments.count) comments")
            }
    }
    
    func addComment(content: String) async {
        guard let eventId = event.id,
              let userId = AuthService.shared.currentUser?.id,
              let userName = AuthService.shared.currentUser?.displayName else {
            print("Missing required data for comment")
            return
        }
        
        let userColor = AuthService.shared.currentUser?.preferences.personalColor ?? "4CAF50"
        
        let comment = EventComment(
            eventId: eventId,
            userId: userId,
            userName: userName,
            userColor: userColor,
            content: content
        )
        
        do {
            _ = try db.collection("eventComments").addDocument(from: comment)
            print("Comment added successfully")
        } catch {
            print("Error adding comment: \(error.localizedDescription)")
        }
    }
    
    deinit {
        commentsListener?.remove()
    }
}

