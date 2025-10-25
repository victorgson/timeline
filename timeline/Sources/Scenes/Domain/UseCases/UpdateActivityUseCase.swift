import Foundation

protocol UpdateActivityUseCase {
    func execute(_ activity: Activity) async throws
}

struct DefaultUpdateActivityUseCase: UpdateActivityUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ activity: Activity) async throws {
        try await repository.updateActivity(activity)
    }
}
