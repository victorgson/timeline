import Foundation

protocol UpsertObjectiveUseCase {
    func execute(_ objective: Objective) async throws
}

struct DefaultUpsertObjectiveUseCase: UpsertObjectiveUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ objective: Objective) async throws {
        try await repository.upsertObjective(objective)
    }
}
