//
//  ForgotPasswordView.swift
//  LifePlanner
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()
                    
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Reset Password")
                            .font(AppTheme.Fonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Enter your email to receive a password reset link")
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: AppTheme.Spacing.lg) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                        
                        Button(action: handleResetPassword) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Reset Link")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .disabled(email.isEmpty || authService.isLoading)
                        .opacity(email.isEmpty || authService.isLoading ? 0.6 : 1)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    
                    Spacer()
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
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Password reset link sent to \(email)")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func handleResetPassword() {
        Task {
            do {
                try await authService.resetPassword(email: email)
                showingSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}

