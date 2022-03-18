import SwiftUI

struct ComplicationSettingsView: View {
    @ObservedObject var viewModel: ComplicationSettingsViewModel
    @State private var selected = Set<UUID>()

    init(complicationSettingsViewModel: ComplicationSettingsViewModel) {
        self.viewModel = complicationSettingsViewModel
    }

    var body: some View {
        VStack {
            if self.viewModel.goals.isEmpty {
                ProgressView()
            } else {
                Text(LocalizedStringKey("ComplicationSettingsView_Instructions_Text"))
                    .multilineTextAlignment(.leading)

                List(self.viewModel.goals) { goal in
                    SelectableRowView(id: goal.id,
                                      title: goal.title,
                                      isDisabled: self.selected.count >= 3,
                                      onSelect: {
                                        self.viewModel.setGoals(goals: Array(self.selected.compactMap({ element in
                                            return element.uuidString
                                        })))
                                      },
                                      selectedItems: self.$selected
                                      )
                }
            }
        }.task {
            try? await self.viewModel.getGoals()
            self.selected = Set<UUID>(self.viewModel.goals.filter({ $0.selected })
                                                          .compactMap({ $0.id }))
        }
    }
}

struct ComplicationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ComplicationSettingsView(complicationSettingsViewModel: DependencyInjection
                                                                .shared
                                                                .container
                                                                .resolve(ComplicationSettingsViewModel.self)!)
    }
}
