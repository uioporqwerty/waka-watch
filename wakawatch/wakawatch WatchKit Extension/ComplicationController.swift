import Foundation
import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    private let currentCodingTimeIdentifier = "CurrentCodingTime"
    private let goalsIdentifier = "Goals"

    private var complicationsViewModel: ComplicationViewModel?

    override init() {
        super.init()
        DependencyInjection.shared.register()
        self.complicationsViewModel = DependencyInjection.shared.container.resolve(ComplicationViewModel.self)!
    }

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        // swiftlint:disable line_length
        let currentCodingTimeDescriptor = CLKComplicationDescriptor(identifier: self.currentCodingTimeIdentifier,
                                                                    displayName: "\(LocalizedStringKey("Complication_CurrentCodingTimeDescriptor_Text").toString()) (hh:mm)",
                                                                    supportedFamilies: [.graphicCircular,
                                                                                        .utilitarianSmallFlat,
                                                                                        .utilitarianLarge
                                                                                       ])
        handler([currentCodingTimeDescriptor])
    }

    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        switch complication.family {
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularStackViewText(
                content: Image("Complication/Graphic Circular"),
                textProvider: CLKTextProvider(format: self.complicationsViewModel?
                                                          .getLocalCurrentTime()
                                                          .toHourMinuteFormat ?? "00:00")
              )

            let entry = CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template)

            handler(entry)
        case .utilitarianSmallFlat:
            // swiftlint:disable line_length
            let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKTextProvider(format:
                                                                                                        self.complicationsViewModel?
                                                                                                        .getLocalCurrentTime()
                                                                                                        .toHourMinuteFormat ?? "00:00"),
                                                                       imageProvider: CLKImageProvider(onePieceImage:
                                                                                                        UIImage(imageLiteralResourceName:
                                                                                                                "Complication/Utilitarian")))

            let entry = CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template
            )

            handler(entry)
        case .utilitarianLarge:
            // swiftlint:disable line_length
            let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKTextProvider(format:
                                                                                                        self.complicationsViewModel?
                                                                                                        .getLocalCurrentTime()
                                                                                                        .toSpelledOutHourMinuteFormat ?? "0 hrs 0 mins"),
                                                                       imageProvider: CLKImageProvider(onePieceImage:
                                                                                                        UIImage(imageLiteralResourceName:
                                                                                                                "Complication/Utilitarian")))

            let entry = CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template
            )

            handler(entry)

        default:
            handler(nil)
        }
    }
}
