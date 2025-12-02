//
//  WorkspaceManager.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class WorkspaceManager: ObservableObject {
    static let shared = WorkspaceManager()
    
    @Published var availableWorkspaces: [Workspace] = []
    @Published var selectedWorkspace: Workspace?
    @Published var selectedWorkspaceIds: [String] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var workspacesListener: ListenerRegistration?
    
    private init() {}
    
    func initialize() async {
        await loadWorkspaces()
    }
    
    func loadWorkspaces() async {
        guard let userId = AuthService.shared.currentUser?.id else {
            print("WorkspaceManager: No user ID")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        workspacesListener?.remove()
        
        workspacesListener = db.collection("workspaces")
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("WorkspaceManager: Error loading workspaces - \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("WorkspaceManager: No documents")
                    return
                }
                
                self.availableWorkspaces = documents.compactMap { doc in
                    try? doc.data(as: Workspace.self)
                }
                
                print("WorkspaceManager: Loaded \(self.availableWorkspaces.count) workspaces")
                
                if self.selectedWorkspace == nil, let firstWorkspace = self.availableWorkspaces.first {
                    self.selectedWorkspace = firstWorkspace
                    self.selectedWorkspaceIds = [firstWorkspace.id].compactMap { $0 }
                    print("WorkspaceManager: Selected workspace - \(firstWorkspace.name)")
                } else if let selectedId = self.selectedWorkspace?.id, !self.availableWorkspaces.contains(where: { $0.id == selectedId }) {
                    self.selectedWorkspace = self.availableWorkspaces.first
                    self.selectedWorkspaceIds = self.availableWorkspaces.first.flatMap { [$0.id].compactMap { $0 } } ?? []
                }
            }
    }
    
    func selectWorkspace(_ workspace: Workspace) {
        selectedWorkspace = workspace
        print("WorkspaceManager: Switched to workspace - \(workspace.name)")
    }
    
    func createWorkspace(name: String, type: Workspace.WorkspaceType, color: String = "4CAF50", familyId: String? = nil) async throws -> Workspace {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw NSError(domain: "WorkspaceManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user ID"])
        }
        
        let workspace = Workspace(
            name: name,
            type: type,
            ownerId: userId,
            familyId: familyId,
            color: color,
            members: [WorkspaceMember(userId: userId, role: .owner)]
        )
        
        do {
            let docRef = try db.collection("workspaces").addDocument(from: workspace)
            print("WorkspaceManager: Created workspace - \(name) with ID: \(docRef.documentID)")
            return workspace
        } catch {
            print("WorkspaceManager: Error creating workspace - \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Create workspace from a Workspace object
    func createWorkspace(_ workspace: Workspace) async throws {
        do {
            let docRef = try db.collection("workspaces").addDocument(from: workspace)
            print("WorkspaceManager: Created workspace - \(workspace.name) with ID: \(docRef.documentID)")
        } catch {
            print("WorkspaceManager: Error creating workspace - \(error.localizedDescription)")
            throw error
        }
    }
    
    deinit {
        workspacesListener?.remove()
    }
}

