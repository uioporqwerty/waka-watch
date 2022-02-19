import ClockKit

final class ComplicationService {
    private let complicationServer = CLKComplicationServer.sharedInstance()

    func updateTimelines() {
        if let activeComplications = self.complicationServer.activeComplications {
          for complication in activeComplications {
            complicationServer.reloadTimeline(for: complication)
          }
        }
    }
}
