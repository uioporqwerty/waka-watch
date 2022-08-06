import SwiftUI
import Charts

@available(watchOSApplicationExtension 9.0, *)
struct SwiftChartsView: View {
    private var summaryData: [SummaryData]?
    private var size: CGSize?
    private var languages: [SummaryLanguageData] = []

    init(summaryData: [SummaryData]?,
         size: CGSize?
        ) {
        self.summaryData = summaryData
        self.size = size
        
        for data in summaryData ?? [] {
            guard let dayLanguages = data.languages else {
                continue
            }
            languages.append(contentsOf: dayLanguages)
        }
    }

    var body: some View {
        if self.summaryData == nil {
            ProgressView()
        } else {
            Text(LocalizedStringKey("SwiftCharts_LanguagesChart_Title"))
                .font(.system(size: 12))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

            Chart(self.languages, id: \.name!) {
                BarMark(x: .value("Language", $0.name!),
                        y: .value("Total Minutes Used", $0.total_seconds?.minute ?? 0))
                .foregroundStyle(by: .value("Language", $0.name ?? ""))
                .accessibilityLabel($0.name ?? "")
                .accessibilityValue(Text(
                    LocalizedStringKey("SwiftCharts_Languages_Value_A11Y")
                        .toString()
                        .replaceArgs(String($0.total_seconds?.toFullFormat ?? ""))))
            }
            .chartXAxis(.hidden)
            .chartLegend(position: .bottom,
                         alignment: .bottom,
                         spacing: 15)
            .frame(height: self.size?.height)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
    }
}

@available(watchOSApplicationExtension 9.0, *)
struct SwiftChartsView_Previews: PreviewProvider {
    static var previews: some View {
        let summaryData = SummaryData(projects: nil,
                                      editors: nil,
                                      languages: [SummaryLanguageData(name: "Python",
                                                                      total_seconds: 12344,
                                                                      text: nil),
                                                  SummaryLanguageData(name: "C#",
                                                                      total_seconds: 1344,
                                                                      text: nil),
                                                  SummaryLanguageData(name: "JS",
                                                                      total_seconds: 14334,
                                                                      text: nil)
                                                 ],
                                      range: SummaryRangeData(date: "2022-"))
        SwiftChartsView(summaryData: [summaryData], size: nil)
    }
}
