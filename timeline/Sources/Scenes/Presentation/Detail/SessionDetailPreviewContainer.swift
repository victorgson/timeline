import SwiftUI

struct SessionDetailPreviewContainer: View {
    @Namespace var namespace
    @State var viewModel = SessionTrackerViewModel.preview

    var body: some View {
        NavigationStack {
            SessionDetailView(viewModel: viewModel) {}
        }
    }
}

#Preview("Session Detail") {
    SessionDetailPreviewContainer()
}
