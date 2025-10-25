import Foundation

protocol AddSessionUseCase {
    func execute(_ session: Session) async throws
}

struct DefaultAddSessionUseCase: AddSessionUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(_ session: Session) async throws {
        try await repository.addSession(session)
    }
}
