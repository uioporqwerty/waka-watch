import SwiftUI

struct ErrorView: View {
    @State private var retryCount = 3
    let description: String?
    let showDescription: Bool
    let retryButtonAction: (() async throws -> Void)?

    private let logManager: LogManager
    init(logManager: LogManager,
         description: String?,
         retryButtonAction: (() async throws -> Void)?,
         showDescription: Bool = true
        ) {
        self.logManager = logManager
        self.description = description
        self.retryButtonAction = retryButtonAction
        self.showDescription = showDescription
    }

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                if self.retryCount == 0 {
                    Text(LocalizedStringKey("ErrorView_DescriptionExceededRetryCount_Label"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                } else {
                    if self.showDescription {
                        Text(self.description ?? LocalizedStringKey("ErrorView_Description_Text").toString())
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    }
                }
                if self.retryButtonAction != nil && self.retryCount > 0 {
                    AsyncButton(action: {
                        self.retryCount -= 1
                        do {
                            try await self.retryButtonAction?()
                        } catch {
                            self.logManager.reportError(error)
                        }
                    }) {
                        Text(LocalizedStringKey("ErrorView_RetryButton_Label"))
                    }
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    init() {
        DependencyInjection.shared.register()
    }

    static var previews: some View {
        ErrorView(logManager: DependencyInjection.shared.container.resolve(LogManager.self)!,
                  description: "An unknown error occurred.",
                  retryButtonAction: {print("hello")})
    }
}
