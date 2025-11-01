import SwiftUI
import FirebaseCore

@main
@MainActor
struct SessionsApp: App {
    @State private var sessionTrackerViewModel: SessionTrackerViewModel

    init() {
        FirebaseApp.configure()

        let isPremiumEnabled = false
        // Replace the hard-coded flag above with the real entitlement state from StoreKit / RevenueCat.
        let persistence = PersistenceController(isPremiumEnabled: isPremiumEnabled)
        let repository = CoreDataSessionTrackerRepository(persistenceController: persistence)
        let useCases = SessionTrackerUseCases.make(repository: repository)

        _sessionTrackerViewModel = State(
            initialValue: SessionTrackerViewModel(useCases: useCases)
        )
    }

    var body: some Scene {
        WindowGroup {
            SessionTrackerView(viewModel: sessionTrackerViewModel)
        }
    }
}
