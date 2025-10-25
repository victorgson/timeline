import Foundation

protocol CreateObjectiveUseCase {
    func execute(
        title: String,
        colorHex: String?,
        keyResults: [KeyResult]
    ) async throws -> Objective
}

struct DefaultCreateObjectiveUseCase: CreateObjectiveUseCase {
    private let repository: SessionTrackerRepository

    init(repository: SessionTrackerRepository) {
        self.repository = repository
    }

    func execute(
        title: String,
        colorHex: String?,
        keyResults: [KeyResult]
    ) async throws -> Objective {
        try await repository.createObjective(
            title: title,
            colorHex: colorHex,
            keyResults: keyResults
        )
    }
}
