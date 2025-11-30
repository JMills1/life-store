//
//  WorkspaceSelectorView.swift
//  LifePlanner
//

import SwiftUI

struct WorkspaceSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Text("Workspace selector - to be implemented")
            }
            .navigationTitle("Select Workspace")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WorkspaceSelectorView()
}

