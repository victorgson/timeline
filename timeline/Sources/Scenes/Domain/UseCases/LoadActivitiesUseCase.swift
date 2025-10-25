import Foundation

protocol LoadActivitiesUseCase {
    func execute() async throws -> [Activity]
}

struct DefaultLoadActivitiesUseCase: LoadActivitiesUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Activity] {
        try await repository.loadActivities()
    }
}
