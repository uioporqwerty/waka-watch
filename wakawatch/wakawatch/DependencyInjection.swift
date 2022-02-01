import Swinject

final class DependencyInjection {
    static let shared = DependencyInjection()
    public let container = Container()
    
    private init() { }
    
    func register() {
        #if DEBUG
        self.container.register(LoggingService.self) { _ in ConsoleLoggingService() }
        self.container.register(TelemetryService.self) { _ in ConsoleTelemetryService() }
        #else
        self.container.register(APMService.self) { r in RollbarAPMService() }
        self.container.register(LoggingService.self) { _ in RollbarLoggingService() }
        self.container.register(TelemetryService.self) { _ in RollbarTelemetryService() }
        #endif
        
        self.container.register(LogManager.self) { r in LogManager(loggingService: r.resolve(LoggingService.self)!)}
        self.container.register(AuthenticationService.self) { r in AuthenticationService(logManager: r.resolve(LogManager.self)!, telemetryService: r.resolve(TelemetryService.self)!)}
        
        self.container.register(AuthenticationViewModel.self) { r in AuthenticationViewModel(authenticationService: r.resolve(AuthenticationService.self)!,
                                                                                             telemetryService: r.resolve(TelemetryService.self)!)}
        self.container.register(SplashViewModel.self) { r in SplashViewModel(telemetryService: r.resolve(TelemetryService.self)!)}
        
        self.container.register(AuthenticationView.self) { r in AuthenticationView(viewModel: r.resolve(AuthenticationViewModel.self)!)}
        self.container.register(SplashView.self) { r in SplashView(viewModel: r.resolve(SplashViewModel.self)!)}
    }
}
