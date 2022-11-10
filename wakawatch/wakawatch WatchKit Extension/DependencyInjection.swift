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

    // swiftlint:disable:next function_body_length
    private func registerServices() {
        self.container.register(ComplicationService.self) { _ in ComplicationService() }
        self.container.register(ChartFactory.self) { _ in ChartFactory() }
        self.container.register(ConsoleLoggingService.self) { _ in ConsoleLoggingService() }
        self.container.register(RollbarLoggingService.self) { _ in RollbarLoggingService() }
        self.container.register(AnalyticsService.self) { _ in
            MixpanelService()
        }.inObjectScope(.container)

        #if DEBUG
            self.container.register(TelemetryService.self) { _ in ConsoleTelemetryService() }
        #else
            self.container.register(TelemetryService.self) { _ in RollbarTelemetryService() }
        #endif

        self.container.register(LogManager.self) { resolver in
            LogManager(loggingServices: [resolver.resolve(ConsoleLoggingService.self)!,
                                        resolver.resolve(RollbarLoggingService.self)!])
        }

        self.container.register(KeychainServicesService.self) { resolver in
            KeychainServicesService(logManager: resolver.resolve(LogManager.self)!)
        }

        self.container.register(TokenManager.self) { resolver in
            TokenManager(keychainService: resolver.resolve(KeychainServicesService.self)!)
        }

        self.container.register(RequestFactory.self) { resolver in
            RequestFactory(tokenManager: resolver.resolve(TokenManager.self)!)
        }

        self.container.register(RollbarAPMService.self) { resolver in
            RollbarAPMService(logManager: resolver.resolve(LogManager.self)!)
        }.inObjectScope(.container)

        self.container.register(AuthenticationService.self) { resolver in
            AuthenticationService(logManager: resolver.resolve(LogManager.self)!,
                                  telemetryService: resolver.resolve(TelemetryService.self)!,
                                  tokenManager: resolver.resolve(TokenManager.self)!
                                 )
        }

        self.container.register(ErrorService.self) { resolver in
            ErrorService(authenticationService: resolver.resolve(AuthenticationService.self)!)
        }

        #if DEBUG
        self.container.register(NetworkService.self) { resolver in
            WakaTimeNetworkService(logManager: resolver.resolve(LogManager.self)!,
                           telemetry: resolver.resolve(TelemetryService.self)!,
                           authenticationService: resolver.resolve(AuthenticationService.self)!,
                           errorService: resolver.resolve(ErrorService.self)!,
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
                               errorService: resolver.resolve(ErrorService.self)!,
                               requestFactory: resolver.resolve(RequestFactory.self)!)
            }
        #endif

        self.container.register(NotificationService.self) { resolver in
            NotificationService(logManager: resolver.resolve(LogManager.self)!,
                                analyticsService: resolver.resolve(AnalyticsService.self)!
                                )
        }

        self.container.register(BackgroundService.self) { resolver in
            BackgroundService(requestFactory: resolver.resolve(RequestFactory.self)!,
                              logManager: resolver.resolve(LogManager.self)!,
                              complicationService: resolver.resolve(ComplicationService.self)!,
                              notificationService: resolver.resolve(NotificationService.self)!
                             )
        }.inObjectScope(.container)

        self.container.register(InternationalizationService.self) { _ in
            InternationalizationService()
        }

        self.container.register(AppInformationService.self) { _ in
            AppInformationService()
        }
    }

    // swiftlint:disable function_body_length
    private func registerViewModels() {
        self.container.register(SummaryViewModel.self) { resolver in
            SummaryViewModel(networkService: resolver.resolve(NetworkService.self)!,
                             complicationService: resolver.resolve(ComplicationService.self)!,
                             telemetryService: resolver.resolve(TelemetryService.self)!,
                             analyticsService: resolver.resolve(AnalyticsService.self)!,
                             chartFactory: resolver.resolve(ChartFactory.self)!,
                             logManager: resolver.resolve(LogManager.self)!
                            )
        }
        self.container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(networkService: resolver.resolve(NetworkService.self)!,
                             telemetryService: resolver.resolve(TelemetryService.self)!,
                             analyticsService: resolver.resolve(AnalyticsService.self)!,
                             logManager: resolver.resolve(LogManager.self)!
                            )
        }.inObjectScope(ObjectScope.transient)
        self.container.register(LeaderboardSelectionViewModel.self) { resolver in
                    LeaderboardSelectionViewModel(networkService: resolver.resolve(NetworkService.self)!,
                                                  authenticationService: resolver.resolve(AuthenticationService.self)!,
                                                  logManager: resolver.resolve(LogManager.self)!,
                                                  telemetryService: resolver.resolve(TelemetryService.self)!,
                                                  analyticsService: resolver.resolve(AnalyticsService.self)!
                    )}
        self.container.register(LeaderboardViewModel.self) { resolver in
            LeaderboardViewModel(networkService: resolver.resolve(NetworkService.self)!,
                                 telemetryService: resolver.resolve(TelemetryService.self)!,
                                 analyticsService: resolver.resolve(AnalyticsService.self)!,
                                 logManager: resolver.resolve(LogManager.self)!)
        }
        self.container.register(SettingsViewModel.self) { resolver in
            SettingsViewModel(networkService: resolver.resolve(NetworkService.self)!,
                              notificationService: resolver.resolve(NotificationService.self)!,
                              authenticationService: resolver.resolve(AuthenticationService.self)!,
                              logManager: resolver.resolve(LogManager.self)!,
                              telemetryService: resolver.resolve(TelemetryService.self)!,
                              analyticsService: resolver.resolve(AnalyticsService.self)!,
                              tokenManager: resolver.resolve(TokenManager.self)!
                             )
        }
        self.container.register(ConnectViewModel.self) { resolver in
            ConnectViewModel(telemetryService: resolver.resolve(TelemetryService.self)!,
                             logManager: resolver.resolve(LogManager.self)!,
                             networkService: resolver.resolve(NetworkService.self)!)
        }
        self.container.register(ComplicationViewModel.self) { _ in ComplicationViewModel() }
        self.container.register(ComplicationSettingsViewModel.self) { resolver in
            ComplicationSettingsViewModel(networkService: resolver.resolve(NetworkService.self)!,
                                          telemetryService: resolver.resolve(TelemetryService.self)!,
                                          logManager: resolver.resolve(LogManager.self)!)
        }
        self.container.register(LicensesViewModel.self) { resolver in
            LicensesViewModel(logManager: resolver.resolve(LogManager.self)!,
                              telemetryService: resolver.resolve(TelemetryService.self)!,
                              analytics: resolver.resolve(AnalyticsService.self)!
                             )
        }
        self.container.register(WhatsNewViewModel.self) { resolver in
            WhatsNewViewModel(telemetryService: resolver.resolve(TelemetryService.self)!,
                              networkService: resolver.resolve(NetworkService.self)!,
                              i18nService: resolver.resolve(InternationalizationService.self)!,
                              appInformationService: resolver.resolve(AppInformationService.self)!)
        }
        self.container.register(AddWatchFaceViewModel.self) { resolver in
            AddWatchFaceViewModel(telemetryService: resolver.resolve(TelemetryService.self)!,
                                  logManager: resolver.resolve(LogManager.self)!,
                                  analytics: resolver.resolve(AnalyticsService.self)!)
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
                            profileViewModel: resolver.resolve(ProfileViewModel.self)!,
                            boardId: nil)
        }
        self.container.register(LeaderboardSelectionView.self) { resolver in
            LeaderboardSelectionView(viewModel: resolver.resolve(LeaderboardSelectionViewModel.self)!)
        }
        self.container.register(SettingsView.self) { resolver in
            SettingsView(viewModel: resolver.resolve(SettingsViewModel.self)!)
        }
        self.container.register(WhatsNewView.self) { resolver in
            WhatsNewView(viewModel: resolver.resolve(WhatsNewViewModel.self)!)
        }
        self.container.register(ConnectView.self) { resolver in
            ConnectView(viewModel: resolver.resolve(ConnectViewModel.self)!,
                        whatsNewViewModel: resolver.resolve(WhatsNewViewModel.self)!)
        }
        self.container.register(ComplicationSettingsView.self) { resolver in
            ComplicationSettingsView(complicationSettingsViewModel:
                                        resolver.resolve(ComplicationSettingsViewModel.self)!)
        }
        self.container.register(LicensesView.self) { resolver in
            LicensesView(viewModel: resolver.resolve(LicensesViewModel.self)!)
        }
        self.container.register(AddWatchFaceView.self) { resolver in
            AddWatchFaceView(viewModel: resolver.resolve(AddWatchFaceViewModel.self)!)
        }
    }
}
