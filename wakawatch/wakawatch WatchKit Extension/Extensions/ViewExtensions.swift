import SwiftUI

extension View {

    /// - Warning: https://www.objc.io/blog/2021/08/24/conditional-view-modifiers/ Check this article before using.
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
