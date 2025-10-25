import Foundation

protocol FetchSessionsUseCase {
    func execute() async throws -> [Session]
}

struct DefaultFetchSessionsUseCase: FetchSessionsUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Session] {
        try await repository.fetchSessions()
    }
}
