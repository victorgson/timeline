import Foundation

protocol DeleteSessionUseCase {
    func execute(_ id: UUID) async throws
}

struct DefaultDeleteSessionUseCase: DeleteSessionUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ id: UUID) async throws {
        try await repository.deleteSession(id: id)
    }
}
