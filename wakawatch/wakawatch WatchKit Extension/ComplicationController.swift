import Foundation
import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    private let currentCodingTimeIdentifier = "CurrentCodingTime"
    private var complicationsViewModel: ComplicationViewModel?

    override init() {
        super.init()
        DependencyInjection.shared.register()
        self.complicationsViewModel = DependencyInjection.shared.container.resolve(ComplicationViewModel.self)!
    }

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let currentCodingTimeDescriptor = CLKComplicationDescriptor(identifier: self.currentCodingTimeIdentifier,
                                                                    displayName: "Today's Coding Time (hh:mm)",
                                                                    supportedFamilies: [.graphicCircular])
        handler([currentCodingTimeDescriptor])
    }

    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        switch complication.family {
        case .graphicCircular:
            self.complicationsViewModel?.getLocalCurrentTime()

            let template = CLKComplicationTemplateGraphicCircularStackViewText(
                content: Image("Complication/Graphic Circular"),
                textProvider: CLKTextProvider(format: self.complicationsViewModel?.totalDisplayTime ?? "")
              )

            let entry = CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template)

            handler(entry)
        default:
            handler(nil)
        }
    }
}
