import Swinject

final class DependencyInjection {
    static let shared = DependencyInjection()
    public let container = Container()

    private init() { }

    // swiftlint:disable function_body_length
    func register() {
        #if DEBUG
        self.container.register(TelemetryService.self) { _ in ConsoleTelemetryService() }
        self.container.register(LoggingService.self) { _ in ConsoleLoggingService() }
        self.container.register(APMService.self) { _ in NullAPMService() }
        #else
        self.container.register(TelemetryService.self) { _ in RollbarTelemetryService() }
        self.container.register(LoggingService.self) { _ in RollbarLoggingService() }
        #endif

        self.container.register(LogManager.self) { resolver in
            LogManager(loggingService: resolver.resolve(LoggingService.self)!)
        }
        self.container.register(AuthenticationService.self) { resolver in
            AuthenticationService(logManager: resolver.resolve(LogManager.self)!,
                                  telemetryService: resolver.resolve(TelemetryService.self)!)
        }
        self.container.register(NetworkService.self) { resolver in
            NetworkService(logManager: resolver.resolve(LogManager.self)!,
                           telemetry: resolver.resolve(TelemetryService.self)!,
                           authenticationService: resolver.resolve(AuthenticationService.self)!)
        }

        #if !DEBUG
        self.container.register(APMService.self) { resolver in
            RollbarAPMService(networkService: resolver.resolve(NetworkService.self)!,
                              logManager: resolver.resolve(LogManager.self)!)
        }
        #endif

        self.container.register(SummaryViewModel.self) { resolver in
            SummaryViewModel(networkService: resolver.resolve(NetworkService.self)!,
                             telemetryService: resolver.resolve(TelemetryService.self)!)
        }
        self.container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(networkService: resolver.resolve(NetworkService.self)!,
                             telemetryService: resolver.resolve(TelemetryService.self)!)
        }.inObjectScope(ObjectScope.transient)
        self.container.register(LeaderboardViewModel.self) { resolver in
            LeaderboardViewModel(networkService: resolver.resolve(NetworkService.self)!,
                                 telemetryService: resolver.resolve(TelemetryService.self)!)
        }
        self.container.register(SettingsViewModel.self) { resolver in
            SettingsViewModel(networkService: resolver.resolve(NetworkService.self)!,
                              authenticationService: resolver.resolve(AuthenticationService.self)!,
                              logManager: resolver.resolve(LogManager.self)!,
                              telemetryService: resolver.resolve(TelemetryService.self)!)
        }
        self.container.register(ConnectViewModel.self) { resolver in
            ConnectViewModel(telemetryService: resolver.resolve(TelemetryService.self)!)
        }

        self.container.register(SummaryView.self) { resolver in
            SummaryView(viewModel: resolver.resolve(SummaryViewModel.self)!)
        }
        self.container.register(ProfileView.self) { resolver in
            ProfileView(viewModel: resolver.resolve(ProfileViewModel.self)!, user: nil)
        }
        self.container.register(LeaderboardView.self) { resolver in
            LeaderboardView(viewModel: resolver.resolve(LeaderboardViewModel.self)!,
                            profileViewModel: resolver.resolve(ProfileViewModel.self)!)
        }
        self.container.register(SettingsView.self) { resolver in
            SettingsView(viewModel: resolver.resolve(SettingsViewModel.self)!)
        }
        self.container.register(ConnectView.self) { resolver in
            ConnectView(viewModel: resolver.resolve(ConnectViewModel.self)!)
        }
    }
}
