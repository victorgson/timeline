import Foundation

protocol UpdateSessionUseCase {
    func execute(_ session: Session) async throws
}

struct DefaultUpdateSessionUseCase: UpdateSessionUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ session: Session) async throws {
        try await repository.updateSession(session)
    }
}
