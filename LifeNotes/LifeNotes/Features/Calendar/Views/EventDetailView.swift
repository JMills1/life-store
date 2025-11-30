//
//  EventDetailView.swift
//  LifePlanner
//

import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EventDetailViewModel
    @State private var showingEditSheet = false
    @State private var newComment = ""
    
    init(event: Event) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        eventHeader
                        
                        eventDetails
                        
                        commentsSection
                    }
                    .padding()
                }
                
                commentInput
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditEventView(event: viewModel.event)
            }
            .task {
                await viewModel.loadComments()
            }
        }
    }
    
    private var eventHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Rectangle()
                    .fill(Color(hex: viewModel.event.color ?? "4CAF50"))
                    .frame(width: 4)
                
                Text(viewModel.event.title)
                    .font(AppTheme.Fonts.title2)
                    .fontWeight(.bold)
            }
            
            if let description = viewModel.event.description {
                Text(description)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
    
    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            DetailRowView(
                icon: "calendar",
                label: "Date",
                value: formatDateRange(viewModel.event.startDate, viewModel.event.endDate)
            )
            
            if !viewModel.event.isAllDay {
                DetailRowView(
                    icon: "clock",
                    label: "Time",
                    value: "\(viewModel.event.startDate.formatted(date: .omitted, time: .shortened)) - \(viewModel.event.endDate.formatted(date: .omitted, time: .shortened))"
                )
            }
            
            if let location = viewModel.event.location {
                DetailRowView(
                    icon: "location",
                    label: "Location",
                    value: location
                )
            }
            
            if !viewModel.event.reminders.isEmpty {
                DetailRowView(
                    icon: "bell",
                    label: "Reminders",
                    value: "\(viewModel.event.reminders.count) reminder(s)"
                )
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Comments")
                .font(AppTheme.Fonts.headline)
            
            if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding()
            } else {
                ForEach(viewModel.comments) { comment in
                    CommentRow(comment: comment)
                }
            }
        }
    }
    
    private var commentInput: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            TextField("Add a comment...", text: $newComment)
                .textFieldStyle(.roundedBorder)
            
            Button(action: postComment) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(newComment.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.primary)
            }
            .disabled(newComment.isEmpty)
        }
        .padding()
        .background(AppTheme.Colors.background)
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDate(start, inSameDayAs: end) {
            return start.formatted(date: .long, time: .omitted)
        } else {
            return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
        }
    }
    
    private func postComment() {
        guard !newComment.isEmpty else { return }
        
        Task {
            await viewModel.addComment(content: newComment)
            newComment = ""
        }
    }
}

struct CommentRow: View {
    let comment: EventComment
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(Color(hex: comment.userColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(comment.userName.prefix(1))
                        .font(AppTheme.Fonts.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userName)
                        .font(AppTheme.Fonts.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(comment.createdAt, style: .relative)
                        .font(AppTheme.Fonts.caption2)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    if comment.isEdited {
                        Text("(edited)")
                            .font(AppTheme.Fonts.caption2)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
                
                Text(comment.content)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
        .padding()
        .background(AppTheme.Colors.background)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

#Preview {
    EventDetailView(event: Event(
        workspaceId: "test",
        title: "Team Meeting",
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600),
        createdBy: "user1"
    ))
}

