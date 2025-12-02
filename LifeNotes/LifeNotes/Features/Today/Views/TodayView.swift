//
//  TodayView.swift
//  LifePlanner
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = TodayViewModel()
    @State private var selectedTodoForEdit: Todo?
    @State private var selectedEvent: Event?
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    greetingHeader
                    
                    todayEventsCard
                    
                    todayTasksCard
                    
                    if !viewModel.pinnedNotes.isEmpty {
                        pinnedNotesCard
                    }
                    
                    if !viewModel.familyUpdates.isEmpty {
                        familyUpdatesCard
                    }
                    
                    statsCard
                }
                .padding()
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Today")
            .task {
                print("📱 TodayView: Loading data for workspaces: \(workspaceManager.selectedWorkspaceIds)")
                await viewModel.loadData(workspaceIds: workspaceManager.selectedWorkspaceIds)
                print("📱 TodayView: Loaded \(viewModel.upcomingEvents.count) events, \(viewModel.todayTasks.count) tasks")
            }
            .refreshable {
                await viewModel.loadData(workspaceIds: workspaceManager.selectedWorkspaceIds)
            }
            .onChange(of: workspaceManager.selectedWorkspaceIds) { oldValue, newValue in
                Task {
                    await viewModel.loadData(workspaceIds: newValue)
                }
            }
            .sheet(item: $selectedTodoForEdit) { todo in
                TodoDetailView(todo: todo)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
        }
    }
    
    var greetingHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("\(greeting), \(viewModel.userName)!")
                    .font(AppTheme.Fonts.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text(Date(), style: .date)
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            if viewModel.totalTasksToday > 0 {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ProgressView(value: viewModel.taskProgress)
                        .tint(AppTheme.Colors.primary)
                    
                    Text("\(viewModel.completedTasksToday)/\(viewModel.totalTasksToday) tasks")
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    var todayEventsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.Colors.personalColor)
                Text("Today's Events")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.upcomingEvents.count)")
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.personalColor)
                    .clipShape(Capsule())
            }
            
            if viewModel.upcomingEvents.isEmpty {
                Text("No events today")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.upcomingEvents) { event in
                    Button(action: {
                        selectedEvent = event
                    }) {
                        HStack {
                            Rectangle()
                                .fill(ColorResolver.shared.colorForEvent(
                                    event,
                                    workspace: ColorResolver.shared.findWorkspace(id: event.workspaceId, in: workspaceManager.availableWorkspaces)
                                ))
                                .frame(width: 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(AppTheme.Fonts.body)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                
                                HStack(spacing: 8) {
                                    Text(event.startDate, style: .time)
                                        .font(AppTheme.Fonts.caption1)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                    
                                    if let location = event.location {
                                        Text("•")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                        Text(location)
                                            .font(AppTheme.Fonts.caption1)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if event.startDate > Date() {
                                Text(timeUntil(event.startDate))
                                    .font(AppTheme.Fonts.caption1)
                                    .foregroundColor(AppTheme.Colors.personalColor)
                                    .padding(.horizontal, AppTheme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.Colors.personalColor.opacity(0.1))
                                    .cornerRadius(AppTheme.CornerRadius.small)
                            } else if event.endDate > Date() {
                                Text("Now")
                                    .font(AppTheme.Fonts.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AppTheme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.Colors.success)
                                    .cornerRadius(AppTheme.CornerRadius.small)
                            }
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.Colors.textTertiary)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(AppTheme.Colors.background)
                        .cornerRadius(AppTheme.CornerRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    var todayTasksCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(AppTheme.Colors.secondary)
                Text("Tasks Due Today")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.todayTasks.count)")
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.secondary)
                    .clipShape(Capsule())
            }
            
            if viewModel.todayTasks.isEmpty {
                Text("No tasks due today")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.todayTasks) { todo in
                    Button(action: { selectedTodoForEdit = todo }) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(todo.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(todo.title)
                                    .font(AppTheme.Fonts.body)
                                    .strikethrough(todo.isCompleted)
                                    .foregroundColor(todo.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: todo.priority.color))
                                        .frame(width: 6, height: 6)
                                    Text(todo.priority.rawValue.capitalized)
                                        .font(AppTheme.Fonts.caption2)
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                    
                                    if !todo.subtasks.isEmpty {
                                        Text("\(todo.subtasks.filter { $0.isCompleted }.count)/\(todo.subtasks.count)")
                                            .font(AppTheme.Fonts.caption2)
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.Colors.textTertiary)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(AppTheme.Colors.background)
                        .cornerRadius(AppTheme.CornerRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    var pinnedNotesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "pin.fill")
                    .foregroundColor(AppTheme.Colors.accent)
                Text("Pinned Notes")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            ForEach(viewModel.pinnedNotes.prefix(3)) { note in
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(AppTheme.Fonts.body)
                        .fontWeight(.medium)
                    Text(note.preview)
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                .padding(AppTheme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.accent.opacity(0.05))
                .cornerRadius(AppTheme.CornerRadius.small)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    var familyUpdatesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(AppTheme.Colors.primary)
                Text("Family Updates")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            ForEach(viewModel.familyUpdates.prefix(5)) { update in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(update.memberName.prefix(1))
                                .font(AppTheme.Fonts.caption1)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.Colors.primary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(update.action)
                            .font(AppTheme.Fonts.body)
                        Text(update.timestamp, style: .relative)
                            .font(AppTheme.Fonts.caption2)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    var statsCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatBadge(
                icon: "flame.fill",
                value: "\(viewModel.currentStreak)",
                label: "Day Streak",
                color: AppTheme.Colors.accent
            )
            
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.tasksCompletedThisWeek)",
                label: "This Week",
                color: AppTheme.Colors.success
            )
            
            StatBadge(
                icon: "calendar",
                value: "\(viewModel.eventsThisWeek)",
                label: "Events",
                color: AppTheme.Colors.primary
            )
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    func timeUntil(_ date: Date) -> String {
        let minutes = Int(date.timeIntervalSinceNow / 60)
        if minutes < 60 {
            return "in \(minutes)m"
        } else {
            return "in \(minutes / 60)h"
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Fonts.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(label)
                .font(AppTheme.Fonts.caption2)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

#Preview {
    TodayView()
}

