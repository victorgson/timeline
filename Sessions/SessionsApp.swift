import SwiftUI
import FirebaseCore
import Tracking
import TrackingFirebase
import RevenueCat

@main
@MainActor
struct SessionsApp: App {
    @State private var sessionTrackerViewModel: SessionTrackerViewModel

    init() {
        FirebaseApp.configure()

        let trackerDispatcher = DefaultTrackerDispatcher(
            trackers: [FirebaseTracker(), LogFirebaseTracker()]
        )

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_XuVymhSmFuWhMzaripgyhEZBhut")

        let isPremiumEnabled = false
        // Replace the hard-coded flag above with the real entitlement state from StoreKit / RevenueCat.
        let persistence = PersistenceController(isPremiumEnabled: isPremiumEnabled)
        let repository = CoreDataSessionTrackerRepository(persistenceController: persistence)
        let useCases = SessionTrackerUseCases.make(repository: repository)
        let hapticBox = DefaultHapticBox()
        let liveActivityController = DefaultSessionLiveActivityController()

        _sessionTrackerViewModel = State(
            initialValue: SessionTrackerViewModel(
                useCases: useCases,
                trackerDispatcher: trackerDispatcher,
                hapticBox: hapticBox,
                liveActivityController: liveActivityController
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            SessionTrackerView(viewModel: sessionTrackerViewModel)
        }
    }
}
