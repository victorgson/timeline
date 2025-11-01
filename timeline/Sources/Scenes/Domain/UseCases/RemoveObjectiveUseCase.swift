import Foundation

protocol RemoveObjectiveUseCase {
    func execute(_ id: UUID) async throws
}

struct DefaultRemoveObjectiveUseCase: RemoveObjectiveUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ id: UUID) async throws {
        try await repository.removeObjective(withID: id)
    }
}
