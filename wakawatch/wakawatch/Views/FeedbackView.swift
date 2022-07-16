import SwiftUI

struct FeedbackView: View {
    enum FocusField: Hashable {
        case field
      }

    @ObservedObject private var viewModel: FeedbackViewModel
    @FocusState private var focusedField: FocusField?
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: .init(
                    get: { self.viewModel.feedback },
                    set: { self.viewModel.feedback = $0 }
                ))
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxHeight: .infinity)
                    .focused($focusedField, equals: .field)

                Divider()
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                Text("FeedbackView_Bug_Text")

                Button(action: {
                    self.viewModel.submit()
                }) {
                    Text("FeedbackView_Submit_Button_Label")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                .disabled(self.viewModel.isSubmitting || self.viewModel.feedback.trim().isEmpty)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            .navigationTitle(LocalizedStringKey("FeedbackView_NavigationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    }
                    label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert(isPresented: .init(
                get: { self.viewModel.isSubmissionSuccessful != nil },
                    set: { _ in }
                )) { () -> Alert in
                    let buttonText = (self.viewModel.isSubmissionSuccessful ?? false) ?
                                    Text("FeedbackView_SuccessAlert_Button") :
                                    Text("FeedbackView_ErrorAlert_Button")
                    let button = Alert.Button.default(buttonText) {
                        if self.viewModel.isSubmissionSuccessful! {
                            presentationMode.wrappedValue.dismiss()
                        }
                        self.viewModel.isSubmissionSuccessful = nil
                    }

                    let title = (self.viewModel.isSubmissionSuccessful ?? false) ?
                                Text("FeedbackView_SuccessAlert_Title") :
                                Text("FeedbackView_ErrorAlert_Title")
                    let message = (self.viewModel.isSubmissionSuccessful ?? false) ?
                                Text("FeedbackView_SuccessAlert_Message") :
                                Text("FeedbackView_ErrorAlert_Message")

                    return Alert(title: title,
                                 message: message,
                                 dismissButton: button)
             }
            .onAppear {
                self.viewModel.telemetry.recordViewEvent(elementName: String(describing: FeedbackView.self))
                self.focusedField = .field
            }
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView(viewModel: DependencyInjection.shared.container.resolve(FeedbackViewModel.self)!)
    }
}
