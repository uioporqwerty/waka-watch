import SwiftUI

struct LicensesView: View {
    @ObservedObject var viewModel: LicensesViewModel
    @State var hasError = false

    init(viewModel: LicensesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if self.hasError {
            ErrorView(logManager: self.viewModel.logManager,
                      description: LocalizedStringKey("LicenseView_Error_Description").toString()
                      ) {
                do {
                    try self.viewModel.loadLicensesFile()
                    self.hasError = false
                } catch {
                    self.hasError = true
                }
            }
        } else if self.viewModel.licensesText == nil {
            ProgressView().task {
                do {
                    try self.viewModel.loadLicensesFile()
                } catch {
                    self.viewModel.logManager.reportError(error)
                    self.hasError = true
                }
            }
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                if self.viewModel.licensesText != nil {
                    Text(self.viewModel.licensesText!)
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                self.viewModel.telemetry.recordViewEvent(elementName: "\(String(describing: LicensesView.self))")
                self.viewModel.analytics.track(event: "Licenses View Shown")
            }
        }
    }
}

struct LicensesView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(LicensesView.self)!
    }
}
