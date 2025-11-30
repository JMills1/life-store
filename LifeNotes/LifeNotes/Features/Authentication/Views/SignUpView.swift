//
//  SignUpView.swift
//  LifePlanner
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @State private var showingError = false
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !displayName.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        Spacer()
                            .frame(height: 40)
                        
                        VStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("Create Account")
                                .font(AppTheme.Fonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: AppTheme.Spacing.lg) {
                            TextField("Full Name", text: $displayName)
                                .textContentType(.name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("Password must be at least 6 characters")
                                    .font(AppTheme.Fonts.caption1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords don't match")
                                    .font(AppTheme.Fonts.caption1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: handleSignUp) {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign Up")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .disabled(!isFormValid || authService.isLoading)
                            .opacity(!isFormValid || authService.isLoading ? 0.6 : 1)
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func handleSignUp() {
        Task {
            do {
                try await authService.signUpWithEmail(
                    email: email,
                    password: password,
                    displayName: displayName
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    SignUpView()
}

