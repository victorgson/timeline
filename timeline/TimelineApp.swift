import SwiftUI

@main
struct TimelineApp: App {
    @State private var focusTrackerViewModel = FocusTrackerViewModel(
        repository: InMemoryFocusTrackerRepository()
    )

    var body: some Scene {
        WindowGroup {
            FocusTrackerView(viewModel: focusTrackerViewModel)
        }
    }
}
