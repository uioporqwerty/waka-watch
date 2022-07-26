import SwiftUI

struct WhatsNewView: View {
    private var viewModel: WhatsNewViewModel
    @AppStorage(DefaultsKeys.authorized) var authorized = false
    @State var requiresUpdate = false

    init(viewModel: WhatsNewViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.viewModel.text == nil {
                ProgressView().task {
                    do {
                        try self.viewModel.loadWhatsNew()
                    } catch {
                        self.viewModel.dismiss()
                    }
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    if self.viewModel.text != nil {
                        Text(self.viewModel.text!)
                        Button {
                            self.viewModel.dismiss()
                        } label: {
                            Text("WhatsNewView_OKButton_Text")
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .onAppear {
            self.viewModel.telemetry.recordViewEvent(elementName: String(describing: WhatsNewView.self))
        }
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(WhatsNewView.self)!
    }
}
