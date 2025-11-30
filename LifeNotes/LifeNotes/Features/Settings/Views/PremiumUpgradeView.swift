//
//  PremiumUpgradeView.swift
//  LifePlanner
//

import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.Colors.primary, AppTheme.Colors.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        Spacer()
                            .frame(height: 40)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Go Premium")
                            .font(AppTheme.Fonts.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        VStack(spacing: AppTheme.Spacing.md) {
                            FeatureRow(icon: "xmark.circle", text: "No ads")
                            FeatureRow(icon: "rectangle.stack.fill", text: "Unlimited workspaces")
                            FeatureRow(icon: "person.3.fill", text: "Advanced family features")
                            FeatureRow(icon: "bell.badge.fill", text: "Priority notifications")
                            FeatureRow(icon: "cloud.fill", text: "Enhanced cloud sync")
                        }
                        .padding()
                        
                        VStack(spacing: AppTheme.Spacing.md) {
                            Text("$2.99")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("per month")
                                .font(AppTheme.Fonts.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button(action: handlePurchase) {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                                } else {
                                    Text("Start Free Trial")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundColor(AppTheme.Colors.primary)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .padding(.horizontal)
                            
                            Text("7-day free trial, then $2.99/month\nCancel anytime")
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func handlePurchase() {
        isPurchasing = true
        
        Task {
            do {
                try await AuthService.shared.updatePremiumStatus(isPremium: true)
                dismiss()
            } catch {
                print("Purchase failed: \(error.localizedDescription)")
            }
            isPurchasing = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40)
            
            Text(text)
                .font(AppTheme.Fonts.body)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    PremiumUpgradeView()
}

