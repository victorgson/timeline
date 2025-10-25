import Foundation

protocol RecordActivityUseCase {
    func execute(_ activity: Activity) async throws
}

struct DefaultRecordActivityUseCase: RecordActivityUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ activity: Activity) async throws {
        try await repository.recordActivity(activity)
    }
}
