import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State var isRefreshing = false
    @State var thresholdLimitReached = false

    private var content: () -> Content
    private var refreshAction: () async -> Void
    private let threshold: CGFloat = 50.0

    init(action: @escaping () async -> Void,
         @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.refreshAction = action
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if self.isRefreshing {
                    ProgressView()
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
                content()
                    .anchorPreference(key: OffsetPreferenceKey.self, value: .top) {
                        geometry[$0].y
                    }
            }
            .onPreferenceChange(OffsetPreferenceKey.self) { offset in
                if offset > threshold && !self.thresholdLimitReached {
                    self.thresholdLimitReached = true
                    Task {
                        self.isRefreshing = true

                        await refreshAction()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut) {
                                self.isRefreshing = false
                                self.thresholdLimitReached = false
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RefreshableScrollViewModifier: ViewModifier {
    var action: () -> Void

    func body(content: Content) -> some View {
        RefreshableScrollView(action: action) {
            content
        }
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
