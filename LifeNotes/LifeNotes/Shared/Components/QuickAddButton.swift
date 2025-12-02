//
//  QuickAddButton.swift
//  LifePlanner
//

import SwiftUI

struct QuickAddButton: View {
    @ObservedObject private var authService = AuthService.shared
    @State private var showingOptions = false
    @State private var showingCreateEvent = false
    @State private var showingCreateTodo = false
    @State private var showingCreateNote = false
    
    var body: some View {
        ZStack {
            if showingOptions {
                VStack(spacing: AppTheme.Spacing.md) {
                    Spacer()
                    
                    QuickAddOption(
                        icon: "calendar.badge.plus",
                        title: "Event",
                        color: AppTheme.Colors.primary
                    ) {
                        showingCreateEvent = true
                        showingOptions = false
                    }
                    
                    QuickAddOption(
                        icon: "checklist",
                        title: "Task",
                        color: AppTheme.Colors.secondary
                    ) {
                        showingCreateTodo = true
                        showingOptions = false
                    }
                    
                    QuickAddOption(
                        icon: "note.text.badge.plus",
                        title: "Note",
                        color: AppTheme.Colors.accent
                    ) {
                        showingCreateNote = true
                        showingOptions = false
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if !showingOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingOptions = true
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(AppTheme.Colors.personalColor(from: authService))
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(selectedDate: Date())
        }
        .sheet(isPresented: $showingCreateTodo) {
            CreateTodoView()
        }
        .sheet(isPresented: $showingCreateNote) {
            NoteEditorView(note: nil)
        }
    }
}

struct QuickAddOption: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(radius: 2, y: 1)
        }
    }
}

#Preview {
    QuickAddButton()
        .padding()
}

