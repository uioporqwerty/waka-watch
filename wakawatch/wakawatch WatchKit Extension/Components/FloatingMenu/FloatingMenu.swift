import SwiftUI

struct FloatingMenu: View {
    @State var showMenuItem1 = false
    var menuItem1Action: () -> Void

    var body: some View {
        VStack {
            Spacer()

            if showMenuItem1 {
                FloatingMenuItem(icon: "person.fill", action: {
                    self.showMenu(animated: false)
                    self.menuItem1Action()
                })
            }

            Button(action: {
                self.showMenu()
            }) {
                Image(systemName: "square.stack.3d.up")
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }.buttonStyle(PlainButtonStyle())
        }
    }

    func showMenu(animated: Bool =  true) {
        if animated {
            withAnimation {
                showMenuItem1.toggle()
            }
        } else {
            showMenuItem1.toggle()
        }
    }
}
