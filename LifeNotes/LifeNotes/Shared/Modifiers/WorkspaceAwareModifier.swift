import SwiftUI

struct WorkspaceAwareModifier: ViewModifier {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    let loadData: ([String]) async -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                await loadData(workspaceManager.selectedWorkspaceIds)
            }
            .onChange(of: workspaceManager.selectedWorkspaceIds) { oldValue, newValue in
                Task {
                    await loadData(newValue)
                }
            }
    }
}

extension View {
    func workspaceAware(loadData: @escaping ([String]) async -> Void) -> some View {
        modifier(WorkspaceAwareModifier(loadData: loadData))
    }
}

