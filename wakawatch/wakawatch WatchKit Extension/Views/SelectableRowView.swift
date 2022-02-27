import SwiftUI

struct SelectableRowView: View {
    var id: UUID
    var title: String
    var isDisabled: Bool
    var onSelect: () -> Void

    @Binding var selectedItems: Set<UUID>

    var isSelected: Bool {
        self.selectedItems.contains(id)
    }

    var body: some View {
        Button(action: {
            if self.isSelected {
                self.selectedItems.remove(self.id)
            } else {
                self.selectedItems.insert(self.id)
            }
            self.onSelect()
        }) {
            HStack {
                Text(self.title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                if self.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.accentColor)
                        .frame(alignment: .trailing)
                        .padding()
                }
            }
        }.disabled(self.isDisabled && !self.isSelected)
    }
}

struct SelectableRowView_Previews: PreviewProvider {
    @State static var selectedItems = Set<UUID>()

    static var previews: some View {
        SelectableRowView(id: UUID(),
                          title: "Code 1 hour perasdfasdfasdf day",
                          isDisabled: selectedItems.count >= 3,
                          onSelect: { },
                          selectedItems: $selectedItems)
    }
}
