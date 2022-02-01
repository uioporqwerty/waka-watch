import Swinject

final class DependencyInjection {
    static let shared = DependencyInjection()
    public let container = Container()
    
    private init() {
        #if DEBUG
        self.container.register(LoggingService.self) { _ in ConsoleLoggingService() }
        #else
        self.container.register(APMService.self) { r in RollbarAPMService() }
        self.container.register(LoggingService.self) { _ in RollbarLoggingService() }
        #endif
        
        self.container.register(LogManager.self) { r in LogManager(loggingService: r.resolve(LoggingService.self)!)}
    }
}
