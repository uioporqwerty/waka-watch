import Cleanse

struct AppComponent:    RootComponent {
    typealias Root = PropertyInjector<WakaWatchApp>

    static func configureRoot(binder bind: ReceiptBinder<PropertyInjector<WakaWatchApp>>) -> BindingReceipt<PropertyInjector<WakaWatchApp>> {
        bind.propertyInjector { (bind) -> BindingReceipt<PropertyInjector<WakaWatchApp>> in
            
            return bind.to(injector: WakaWatchApp.injectProperties)
        }
    }
    
    static func configure(binder: Binder<Singleton>) {
    }
}
