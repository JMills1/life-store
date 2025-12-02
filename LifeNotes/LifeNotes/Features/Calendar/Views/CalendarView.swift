//
//  CalendarView.swift
//  LifePlanner
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @ObservedObject private var authService = AuthService.shared
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    @State private var showingCreateEvent = false
    @State private var showingWorkspaceSelector = false
    @State private var calendarMode: CalendarMode = .month
    
    enum CalendarMode {
        case month, week, day
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                workspaceHeader
                
                calendarModeSelector
                
                switch calendarMode {
                case .month:
                    MonthView(
                        selectedDate: $selectedDate,
                        events: viewModel.events,
                        todos: viewModel.todos,
                        notes: viewModel.notes,
                        workspaces: viewModel.selectedWorkspaces
                    )
                case .week:
                    WeekView(
                        selectedDate: $selectedDate,
                        events: viewModel.events
                    )
                case .day:
                    DayView(
                        selectedDate: $selectedDate,
                        events: viewModel.events,
                        workspaces: workspaceManager.availableWorkspaces
                    )
                }
                
                if !viewModel.isPremium {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    WorkspaceSelector()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selectedDate = Date() }) {
                        Text("Today")
                            .font(AppTheme.Fonts.subheadline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingWorkspaceSelector) {
                WorkspaceSelectorView()
            }
            .task {
                await viewModel.loadData(workspaceIds: workspaceManager.selectedWorkspaceIds)
            }
            .onChange(of: workspaceManager.selectedWorkspaceIds) { oldValue, newValue in
                Task {
                    await viewModel.loadData(workspaceIds: newValue)
                }
            }
        }
    }
    
    private var workspaceHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(viewModel.selectedWorkspaces) { workspace in
                    let personalColor = AuthService.shared.currentUser?.preferences.personalColor
                    let currentUserId = AuthService.shared.currentUser?.id
                    let displayColor = workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: displayColor))
                            .frame(width: 6, height: 6)
                        Text(workspace.name)
                            .font(AppTheme.Fonts.caption1)
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Color(hex: displayColor).opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colors.background)
    }
    
    private var calendarModeSelector: some View {
        let personalColor = AppTheme.Colors.personalColor(from: authService)
        
        return HStack(spacing: 0) {
            ForEach([CalendarMode.month, .week, .day], id: \.self) { mode in
                Button(action: { calendarMode = mode }) {
                    Text(mode.title)
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(calendarMode == mode ? .white : AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(calendarMode == mode ? personalColor : Color.clear)
                }
            }
        }
        .background(AppTheme.Colors.divider)
    }
}

extension CalendarView.CalendarMode {
    var title: String {
        switch self {
        case .month: return "Month"
        case .week: return "Week"
        case .day: return "Day"
        }
    }
}

#Preview {
    CalendarView()
}

