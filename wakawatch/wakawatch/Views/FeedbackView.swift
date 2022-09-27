import SwiftUI

struct FeedbackView: View {
    enum FocusField: Hashable {
        case field
      }

    @ObservedObject private var viewModel: FeedbackViewModel
    @FocusState private var focusedField: FocusField?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL

    init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: .init(
                    get: { self.viewModel.selectedCategory },
                    set: { self.viewModel.selectedCategory = $0 }
                ), label: Text("FeedbackView_FeedbackCategory_Picker")) {
                    ForEach(0..<self.viewModel.categories.count) {
                        if self.viewModel.categories[$0] == "Feature" {
                            Text(LocalizedStringKey("FeedbackView_FeatureCategory_Text"))
                        } else if self.viewModel.categories[$0] == "Bug" {
                            Text(LocalizedStringKey("FeedbackView_BugCategory_Text"))
                        } else {
                            Text(LocalizedStringKey("FeedbackView_NoneCategory_Text"))
                        }
                    }
                }

                if self.viewModel.selectedCategory == 2 {
                    Text("FeedbackView_Bug_Text")
                }

                Divider()
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                TextEditor(text: .init(
                    get: { self.viewModel.feedback },
                    set: { self.viewModel.feedback = $0 }
                ))
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxHeight: .infinity)
                    .focused($focusedField, equals: .field)

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
                .disabled(self.viewModel.isSubmitting ||
                          self.viewModel.feedback.trim().isEmpty ||
                          self.viewModel.selectedCategory == 0)
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
                    let button = Alert.Button.cancel(buttonText) {
                        if self.viewModel.isSubmissionSuccessful! {
                            presentationMode.wrappedValue.dismiss()
                        }
                        self.viewModel.isSubmissionSuccessful = nil
                    }

                    let viewIssueButton = Alert.Button.default(Text("FeedbackView_ViewIssueAlert_Button")) {
                        presentationMode.wrappedValue.dismiss()
                        self.viewModel.isSubmissionSuccessful = nil
                        openURL(self.viewModel.issueUrl!)
                    }

                    let title = (self.viewModel.isSubmissionSuccessful ?? false) ?
                                Text("FeedbackView_SuccessAlert_Title") :
                                Text("FeedbackView_ErrorAlert_Title")
                    let message = (self.viewModel.isSubmissionSuccessful ?? false) ?
                                Text("FeedbackView_SuccessAlert_Message") :
                                Text("FeedbackView_ErrorAlert_Message")

                    return Alert(title: title,
                                 message: message,
                                 primaryButton: viewIssueButton,
                                 secondaryButton: button)
             }
            .onAppear {
                self.viewModel
                    .telemetry
                    .recordViewEvent(elementName: String(describing: FeedbackView.self))
                self.viewModel
                    .analytics
                    .track(event: "Feedback View Shown")
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
