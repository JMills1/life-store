//
//  LoginView.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        Spacer()
                            .frame(height: 60)
                        
                        // App Logo & Title
                        VStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("LifePlanner")
                                .font(AppTheme.Fonts.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Organize your family's life together")
                                .font(AppTheme.Fonts.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                        
                        // Login Form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Email Field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                                
                                Button("Forgot Password?") {
                                    showingForgotPassword = true
                                }
                                .font(AppTheme.Fonts.footnote)
                                .foregroundColor(.white)
                            }
                            
                            // Sign In Button
                            Button(action: handleEmailSignIn) {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((authService.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white.opacity(0.5))
                                Text("OR")
                                    .font(AppTheme.Fonts.footnote)
                                    .foregroundColor(.white)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.vertical, AppTheme.Spacing.sm)
                            
                            // Sign in with Apple
                            SignInWithAppleButton(
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                    request.nonce = authService.startSignInWithAppleFlow()
                                },
                                onCompletion: { result in
                                    handleAppleSignIn(result: result)
                                }
                            )
                            .frame(height: 50)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            // Sign Up Link
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.white)
                                Button("Sign Up") {
                                    showingSignUp = true
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            }
                            .font(AppTheme.Fonts.subheadline)
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        
                        Spacer()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleEmailSignIn() {
        print("Sign In button tapped - Email: \(email)")
        print("Password field has \(password.count) characters")
        
        Task {
            do {
                print("Attempting sign in...")
                try await authService.signInWithEmail(email: email, password: password)
                print("Sign in succeeded!")
            } catch {
                print("Sign in failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            Task {
                do {
                    try await authService.signInWithApple(authorization: authorization)
                } catch {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    LoginView()
}

