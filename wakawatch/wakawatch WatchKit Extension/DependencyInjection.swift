import Swinject

final class DependencyInjection {
    static let shared = DependencyInjection()
    public let container = Container()
    
    private init() { }
    
    func register() {
        #if DEBUG
        self.container.register(TelemetryService.self) { _ in ConsoleTelemetryService() }
        self.container.register(LoggingService.self) { _ in ConsoleLoggingService() }
        #else
        self.container.register(APMService.self) { r in RollbarAPMService() }
        self.container.register(TelemetryService.self) { _ in RollbarTelemetryService() }
        self.container.register(LoggingService.self) { _ in RollbarLoggingService() }
        #endif
        
        self.container.register(LogManager.self) { r in LogManager(loggingService: r.resolve(LoggingService.self)!)}
        self.container.register(NetworkService.self) { r in NetworkService(logManager: r.resolve(LogManager.self)!, telemetry: r.resolve(TelemetryService.self)!)}
        
        self.container.register(SummaryViewModel.self) { r in SummaryViewModel(networkService: r.resolve(NetworkService.self)!, telemetryService: r.resolve(TelemetryService.self)!)}
        self.container.register(ProfileViewModel.self) { r in ProfileViewModel(networkService: r.resolve(NetworkService.self)!, telemetryService: r.resolve(TelemetryService.self)! )}
        self.container.register(LeaderboardViewModel.self) { r in LeaderboardViewModel(networkService: r.resolve(NetworkService.self)!, telemetryService: r.resolve(TelemetryService.self)!)}
        self.container.register(SettingsViewModel.self) { r in SettingsViewModel(networkService: r.resolve(NetworkService.self)!,
                                                                                 logManager: r.resolve(LogManager.self)!,
                                                                                 telemetryService: r.resolve(TelemetryService.self)!)}
        self.container.register(ConnectViewModel.self) { r in ConnectViewModel(telemetryService: r.resolve(TelemetryService.self)!)}
        
        self.container.register(SummaryView.self) { r in SummaryView(viewModel: r.resolve(SummaryViewModel.self)!)}
        self.container.register(ProfileView.self) { r in ProfileView(viewModel: r.resolve(ProfileViewModel.self)!, user: nil)}
        self.container.register(LeaderboardView.self) { r in LeaderboardView(viewModel: r.resolve(LeaderboardViewModel.self)!)}
        self.container.register(SettingsView.self) { r in SettingsView(viewModel: r.resolve(SettingsViewModel.self)!)}
        self.container.register(ConnectView.self) { r in ConnectView(viewModel: r.resolve(ConnectViewModel.self)!)}
    }
}
