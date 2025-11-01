import Foundation

protocol LoadObjectivesUseCase {
    func execute() async throws -> [Objective]
}

struct DefaultLoadObjectivesUseCase: LoadObjectivesUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Objective] {
        try await repository.loadObjectives()
    }
}
