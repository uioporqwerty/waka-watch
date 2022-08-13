import SwiftUI
import Charts

struct DayProjectData {
    let projectName: String
    var data: [ProjectData]
}

struct ProjectData: Identifiable {
    let id = UUID()
    let date: Date
    let total_seconds: Double
}

@available(watchOSApplicationExtension 9.0, *)
struct SwiftChartsView: View {
    private var summaryData: [SummaryData]?
    private var size: CGSize?
    private var languages: [SummaryLanguageData] = []
    private var editors: [SummaryEditorData] = []
    private var projects: [DayProjectData] = []
    
    init(summaryData: [SummaryData]?,
         size: CGSize?
    ) {
        self.summaryData = summaryData
        self.size = size
        
        for data in summaryData ?? [] {
            if let dayLanguages = data.languages {
                self.languages.append(contentsOf: dayLanguages)
            }
    
            if let dayEditors = data.editors {
                self.editors.append(contentsOf: dayEditors)
            }
            
            if let dayProjects = data.projects {
                for project in dayProjects {
                    let projectDate = data.range.date ?? ""
                    guard let projectSeconds = project.total_seconds else {
                        continue
                    }
                    let projectName = project.name ?? ""
                    
                    let dayProjectDataIndex = self.projects.firstIndex(where: { $0.projectName == projectName})
                    if let dayProjectDataIndex = dayProjectDataIndex {
                        self.projects[dayProjectDataIndex].data.append(ProjectData(date: DateUtility.getDate(date: projectDate)!,
                                                               total_seconds: projectSeconds))
                    } else {
                        self.projects.append(DayProjectData(projectName: projectName,
                                                            data: [ProjectData(date: DateUtility.getDate(date: projectDate)!,
                                                                               total_seconds: projectSeconds)]))
                        
                    }
                }
            }
        }
    }
    
    var body: some View {
        if self.summaryData == nil {
            ProgressView()
        } else {
            Text(LocalizedStringKey("SwiftCharts_CodingTimeChart_Title"))
                .font(.system(size: 12))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            
            Chart {
                ForEach(self.projects, id: \.projectName) { projectData in
                    ForEach(projectData.data) {
                        BarMark(x: .value("Date", $0.date, unit: .day),
                                y: .value("Minutes Coded", $0.total_seconds.minute))
                    }.foregroundStyle(by: .value("Project", projectData.projectName))
                }
            }
            .chartLegend(position: .bottom,
                         alignment: .bottom,
                         spacing: 15)
            .frame(height: self.size?.height)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        
            Divider()
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
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
            
            Divider()
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            Text(LocalizedStringKey("SwiftCharts_EditorsChart_Title"))
                .font(.system(size: 12))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            
            Chart(self.editors, id: \.name!) {
                BarMark(x: .value("Editor", $0.name!),
                        y: .value("Total Minutes Used", $0.total_seconds?.minute ?? 0))
                .foregroundStyle(by: .value("Editor", $0.name ?? ""))
                .accessibilityLabel($0.name ?? "")
                .accessibilityValue(Text(
                    LocalizedStringKey("SwiftCharts_Editors_Value_A11Y")
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
