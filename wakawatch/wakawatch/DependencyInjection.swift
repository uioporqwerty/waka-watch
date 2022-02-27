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
        self.container.register(RequestFactory.self) { _ in RequestFactory() }

        self.container.register(LogManager.self) { resolver in
            LogManager(loggingService: resolver.resolve(LoggingService.self)!)
        }
        self.container.register(AuthenticationService.self) { resolver in
            AuthenticationService(logManager: resolver.resolve(LogManager.self)!,
                                  telemetryService: resolver.resolve(TelemetryService.self)!)
        }
        self.container.register(NetworkService.self) { resolver in
            WakaTimeNetworkService(logManager: resolver.resolve(LogManager.self)!,
                           telemetry: resolver.resolve(TelemetryService.self)!,
                           authenticationService: resolver.resolve(AuthenticationService.self)!,
                           requestFactory: resolver.resolve(RequestFactory.self)!)
        }

        #if DEBUG
        self.container.register(APMService.self) { _ in NullAPMService() }
        self.container.register(LoggingService.self) { _ in ConsoleLoggingService() }
        self.container.register(TelemetryService.self) { _ in ConsoleTelemetryService() }
        #else
        self.container.register(LoggingService.self) { _ in RollbarLoggingService() }
        self.container.register(TelemetryService.self) { _ in RollbarTelemetryService() }
        self.container.register(APMService.self) { resolver in
            RollbarAPMService(networkService: resolver.resolve(NetworkService.self)!,
                              logManager: resolver.resolve(LogManager.self)!)
        }
        #endif
    }

    private func registerViewModels() {
        self.container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(authenticationService: resolver.resolve(AuthenticationService.self)!,
                                    networkService: resolver.resolve(NetworkService.self)!,
                                    telemetryService: resolver.resolve(TelemetryService.self)!,
                                    apmService: resolver.resolve(APMService.self)!,
                                    logManager: resolver.resolve(LogManager.self)!)
        }
        self.container.register(SplashViewModel.self) { resolver in
            SplashViewModel(telemetryService: resolver.resolve(TelemetryService.self)!)
        }
    }

    private func registerViews() {
        self.container.register(AuthenticationView.self) { resolver in
            AuthenticationView(viewModel: resolver.resolve(AuthenticationViewModel.self)!)
        }
        self.container.register(SplashView.self) { resolver in
            SplashView(viewModel: resolver.resolve(SplashViewModel.self)!)
        }
    }
}
