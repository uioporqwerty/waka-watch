import SwiftUI

struct FloatingMenuItem: View {
    var icon: String
    var action: () -> Void

    var body: some View {
        ZStack {
            AsyncButton(action: {
                self.action()
            }) {
                Image(systemName: icon)
                    .padding()
                    .frame(width: 28, height: 28)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }.buttonStyle(PlainButtonStyle())
        }
        .transition(.move(edge: .trailing))
    }
}
