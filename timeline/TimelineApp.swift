import SwiftUI

@main
struct TimelineApp: App {
    @State private var sessionTrackerViewModel = SessionTrackerViewModel(
        repository: InMemorySessionTrackerRepository()
    )

    var body: some Scene {
        WindowGroup {
            SessionTrackerView(viewModel: sessionTrackerViewModel)
        }
    }
}
