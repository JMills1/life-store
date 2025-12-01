import SwiftUI

struct CollapsibleDatePicker: View {
    let label: String
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date, .hourAndMinute]
    var onChange: ((Date) -> Void)?
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(label)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.caption)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .onChange(of: date) { oldValue, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onChange?(newValue)
                        withAnimation {
                            isExpanded = false
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
    
    private var formattedDate: String {
        if displayedComponents == [.date] {
            return date.formatted(date: .abbreviated, time: .omitted)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

