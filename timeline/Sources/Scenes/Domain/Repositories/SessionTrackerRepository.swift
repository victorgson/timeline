import Foundation

protocol SessionTrackerRepository {
    func loadObjectives() async throws -> [Objective]
    func loadActivities() async throws -> [Activity]
    func upsertObjective(_ objective: Objective) async throws
    func recordActivity(_ activity: Activity) async throws
    func updateActivity(_ activity: Activity) async throws
    func removeActivity(withID id: UUID) async throws
    @discardableResult
    func createObjective(
        title: String,
        colorHex: String?,
        endDate: Date?,
        keyResults: [KeyResult]
    ) async throws -> Objective

    func fetchSessions() async throws -> [Session]
    func addSession(_ session: Session) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
}
