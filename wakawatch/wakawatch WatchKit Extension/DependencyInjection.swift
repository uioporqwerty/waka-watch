import Swinject

final class DependencyInjection {
    static let shared = DependencyInjection()
    public let container = Container()

    private init() { }

    func register() {
        registerServices()
        registerViewModels()
        registerViews()
    }

    private func registerServices() {
        self.container.register(ComplicationService.self) { _ in ComplicationService() }
        self.container.register(RequestFactory.self) { _ in RequestFactory() }
        self.container.register(ChartFactory.self) { _ in ChartFactory() }

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

        #if DEBUG
        self.container.register(NetworkService.self) { resolver in
            WakaTimeNetworkService(logManager: resolver.resolve(LogManager.self)!,
                           telemetry: resolver.resolve(TelemetryService.self)!,
                           authenticationService: resolver.resolve(AuthenticationService.self)!,
                           requestFactory: resolver.resolve(RequestFactory.self)!)
        }
        // TODO: Switch from local network service to wakatime network service on actual device run.
//            self.container.register(NetworkService.self) { resolver in
//                LocalNetworkService(logManager: resolver.resolve(LogManager.self)!,
//                               telemetry: resolver.resolve(TelemetryService.self)!,
//                               authenticationService: resolver.resolve(AuthenticationService.self)!,
//                               requestFactory: resolver.resolve(RequestFactory.self)!)
//            }
        #else
            self.container.register(NetworkService.self) { resolver in
                WakaTimeNetworkService(logManager: resolver.resolve(LogManager.self)!,
                               telemetry: resolver.resolve(TelemetryService.self)!,
                               authenticationService: resolver.resolve(AuthenticationService.self)!,
                               requestFactory: resolver.resolve(RequestFactory.self)!)
            }
        #endif

        #if !DEBUG
        self.container.register(APMService.self) { resolver in
            RollbarAPMService(networkService: resolver.resolve(NetworkService.self)!,
                              logManager: resolver.resolve(LogManager.self)!)
        }
        #endif
    }

    private func registerViewModels() {
        self.container.register(SummaryViewModel.self) { resolver in
            SummaryViewModel(networkService: resolver.resolve(NetworkService.self)!,
                             complicationService: resolver.resolve(ComplicationService.self)!,
                             telemetryService: resolver.resolve(TelemetryService.self)!,
                             chartFactory: resolver.resolve(ChartFactory.self)!
                            )
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
            ConnectViewModel(telemetryService: resolver.resolve(TelemetryService.self)!,
                             networkService: resolver.resolve(NetworkService.self)!)
        }
        self.container.register(ComplicationViewModel.self) { _ in ComplicationViewModel() }
        self.container.register(ComplicationSettingsViewModel.self) { resolver in
            ComplicationSettingsViewModel(networkService: resolver.resolve(NetworkService.self)!,
                                          telemetryService: resolver.resolve(TelemetryService.self)!,
                                          logManager: resolver.resolve(LogManager.self)!)
        }
    }

    private func registerViews() {
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
        self.container.register(ComplicationSettingsView.self) { resolver in
            ComplicationSettingsView(complicationSettingsViewModel:
                                        resolver.resolve(ComplicationSettingsViewModel.self)!)
        }
    }
}
