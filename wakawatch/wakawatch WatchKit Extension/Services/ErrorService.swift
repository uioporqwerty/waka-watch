import Foundation

final class ErrorService {
    private let authenticationService: AuthenticationService
    
    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
    }
    
    func handleWakaTimeError(error: WakaTimeError) async {
        if error == .unauthorized {
            try? await self.authenticationService.disconnect()
        } else if error == .unsetTimezone {
            UserDefaults.standard.set(String(localized: "GlobalError_MissingTimezone"),
                                      forKey: DefaultsKeys.globalErrorMessage)
        }
    }
}
