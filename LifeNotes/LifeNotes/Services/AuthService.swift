//
//  AuthService.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import Combine

/// Handles all authentication operations
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // For Sign in with Apple
    private var currentNonce: String?
    
    private init() {
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            print("Auth state changed - User: \(firebaseUser?.uid ?? "nil")")
            
            if let firebaseUser = firebaseUser {
                print("Fetching user data for: \(firebaseUser.uid)")
                self.fetchUserData(uid: firebaseUser.uid)
            } else {
                print("No user - setting to unauthenticated")
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signUpWithEmail(email: String, password: String, displayName: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Create user document in Firestore
            let user = User(
                id: result.user.uid,
                email: email,
                displayName: displayName,
                authProvider: .email
            )
            
            try await createUserDocument(user: user)
            
            // Create default personal workspace
            try await createDefaultWorkspace(for: result.user.uid)
            
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign in with Apple
    
    func signInWithApple(authorization: ASAuthorization) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }
        
        guard let nonce = currentNonce else {
            throw AuthError.invalidNonce
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AuthError.missingToken
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.tokenSerializationFailed
        }
        
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        do {
            let result = try await auth.signIn(with: credential)
            
            // Check if user document exists, if not create it
            let userDoc = try await db.collection("users").document(result.user.uid).getDocument()
            
            if !userDoc.exists {
                let displayName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let user = User(
                    id: result.user.uid,
                    email: result.user.email ?? "",
                    displayName: displayName.isEmpty ? "Apple User" : displayName,
                    authProvider: .apple
                )
                
                try await createUserDocument(user: user)
                try await createDefaultWorkspace(for: result.user.uid)
            }
            
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    func startSignInWithAppleFlow() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError.passwordResetFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    // MARK: - User Data Management
    
    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("User document doesn't exist")
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    private func createUserDocument(user: User) async throws {
        guard let userId = user.id else {
            throw AuthError.missingUserId
        }
        
        do {
            try db.collection("users").document(userId).setData(from: user)
        } catch {
            throw AuthError.userCreationFailed(error.localizedDescription)
        }
    }
    
    private func createDefaultWorkspace(for userId: String) async throws {
        let existingWorkspaces = try await db.collection("workspaces")
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()
        
        guard existingWorkspaces.documents.isEmpty else {
            print("Workspace already exists for user")
            return
        }
        
        let workspace = Workspace(
            name: "Personal",
            type: .personal,
            ownerId: userId,
            icon: "person.fill",
            members: [WorkspaceMember(userId: userId, role: .owner)]
        )
        
        do {
            let docRef = try db.collection("workspaces").addDocument(from: workspace)
            print("Created default workspace with ID: \(docRef.documentID)")
        } catch {
            print("Failed to create default workspace: \(error.localizedDescription)")
        }
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        try await db.collection("users").document(userId).updateData([
            "preferences": try Firestore.Encoder().encode(preferences)
        ])
        
        // Update local user
        DispatchQueue.main.async {
            self.currentUser?.preferences = preferences
        }
    }
    
    func updatePremiumStatus(isPremium: Bool) async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        try await db.collection("users").document(userId).updateData([
            "isPremium": isPremium
        ])
        
        DispatchQueue.main.async {
            self.currentUser?.isPremium = isPremium
        }
    }
    
    // MARK: - Helpers for Sign in with Apple
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    case passwordResetFailed(String)
    case userCreationFailed(String)
    case invalidCredential
    case invalidNonce
    case missingToken
    case tokenSerializationFailed
    case missingUserId
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed(let message):
            return "Sign up failed: \(message)"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .passwordResetFailed(let message):
            return "Password reset failed: \(message)"
        case .userCreationFailed(let message):
            return "User creation failed: \(message)"
        case .invalidCredential:
            return "Invalid credential"
        case .invalidNonce:
            return "Invalid nonce"
        case .missingToken:
            return "Missing identity token"
        case .tokenSerializationFailed:
            return "Token serialization failed"
        case .missingUserId:
            return "Missing user ID"
        case .notAuthenticated:
            return "User not authenticated"
        }
    }
}

