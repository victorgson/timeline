import Foundation

protocol RemoveActivityUseCase {
    func execute(_ id: UUID) async throws
}

struct DefaultRemoveActivityUseCase: RemoveActivityUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ id: UUID) async throws {
        try await repository.removeActivity(withID: id)
    }
}
