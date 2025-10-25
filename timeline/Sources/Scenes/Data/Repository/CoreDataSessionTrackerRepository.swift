import Foundation
@preconcurrency import CoreData

final class CoreDataSessionTrackerRepository: SessionTrackerRepository {
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    // MARK: - Objectives & Activities

    func loadObjectives() async throws -> [Objective] {
        try await performOnViewContext { context in
            let request = ObjectiveEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: #keyPath(ObjectiveEntity.title),
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )
            ]

            let entities = try context.fetch(request)
            return entities.compactMap(Self.makeObjective)
        }
    }

    func loadActivities() async throws -> [Activity] {
        try await performOnViewContext { context in
            let request = ActivityEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ActivityEntity.date), ascending: false)]
            let entities = try context.fetch(request)
            return entities.compactMap(Self.makeActivity)
        }
    }

    func upsertObjective(_ objective: Objective) async throws {
        try await performOnViewContext { context in
            let entity = try Self.fetchObjectiveEntity(id: objective.id, in: context) ?? ObjectiveEntity(context: context)
            entity.id = objective.id
            entity.title = objective.title
            entity.colorHex = objective.colorHex
            Self.syncKeyResults(objective.keyResults, to: entity, in: context)
            try Self.saveIfNeeded(context: context)
        }
    }

    func recordActivity(_ activity: Activity) async throws {
        try await persistActivity(activity)
    }

    func updateActivity(_ activity: Activity) async throws {
        try await persistActivity(activity)
    }

    func removeActivity(withID id: UUID) async throws {
        try await performOnViewContext { context in
            guard let entity = try Self.fetchActivityEntity(id: id, in: context) else { return }
            context.delete(entity)
            try Self.saveIfNeeded(context: context)
        }
    }

    @discardableResult
    func createObjective(
        title: String,
        colorHex: String?,
        keyResults: [KeyResult]
    ) async throws -> Objective {
        let objective = Objective(
            title: title,
            colorHex: colorHex,
            keyResults: keyResults
        )
        try await upsertObjective(objective)
        return objective
    }

    // MARK: - Sessions

    func fetchSessions() async throws -> [Session] {
        try await performOnBackgroundContext { context in
            let request = SessionDTO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(SessionDTO.startedAt), ascending: false)]
            let dtos = try context.fetch(request)
            return dtos.map { $0.makeDomainModel() }
        }
    }

    func addSession(_ session: Session) async throws {
        try await performOnBackgroundContext { context in
            if let existing = try Self.fetchSessionDTO(id: session.id, in: context) {
                context.delete(existing)
            }
            let dto = SessionDTO(context: context)
            dto.configure(with: session)
            try Self.saveIfNeeded(context: context)
        }
    }

    func updateSession(_ session: Session) async throws {
        try await performOnBackgroundContext { context in
            guard let existing = try Self.fetchSessionDTO(id: session.id, in: context) else {
                let dto = SessionDTO(context: context)
                dto.configure(with: session)
                try Self.saveIfNeeded(context: context)
                return
            }
            existing.configure(with: session)
            try Self.saveIfNeeded(context: context)
        }
    }

    func deleteSession(id: UUID) async throws {
        try await performOnBackgroundContext { context in
            guard let existing = try Self.fetchSessionDTO(id: id, in: context) else { return }
            context.delete(existing)
            try Self.saveIfNeeded(context: context)
        }
    }
}

// MARK: - Private Helpers

private extension CoreDataSessionTrackerRepository {
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    func performOnViewContext<T>(
        _ work: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await perform(on: viewContext, work)
    }

    func performOnBackgroundContext<T>(
        _ work: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        let context = persistenceController.newBackgroundContext()
        return try await perform(on: context, work)
    }

    func perform<T>(
        on context: NSManagedObjectContext,
        _ work: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try work(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func persistActivity(_ activity: Activity) async throws {
        try await performOnViewContext { context in
            let entity = try Self.fetchActivityEntity(id: activity.id, in: context) ?? ActivityEntity(context: context)
            try Self.apply(activity, to: entity, in: context)
            try Self.saveIfNeeded(context: context)
        }
    }

    static func makeObjective(from entity: ObjectiveEntity) -> Objective? {
        guard let id = entity.id else { return nil }
        let keyResults = entity.sortedKeyResults.compactMap(Self.makeKeyResult)
        return Objective(
            id: id,
            title: entity.title,
            colorHex: entity.colorHex,
            keyResults: keyResults
        )
    }

    static func makeKeyResult(from entity: KeyResultEntity) -> KeyResult? {
        guard let id = entity.id else { return nil }

        let timeMetric: KeyResult.TimeMetric? = {
            guard let unitRaw = entity.timeUnitRaw,
                  let unit = KeyResult.TimeMetric.Unit(rawValue: unitRaw),
                  let target = entity.timeTarget?.doubleValue,
                  let logged = entity.timeLogged?.doubleValue else {
                return nil
            }
            return KeyResult.TimeMetric(unit: unit, target: target, logged: logged)
        }()

        let quantityMetric: KeyResult.QuantityMetric? = {
            guard let unit = entity.quantityUnit,
                  let target = entity.quantityTarget?.doubleValue else {
                return nil
            }
            let current = entity.quantityCurrent?.doubleValue ?? 0
            return KeyResult.QuantityMetric(unit: unit, target: target, current: current)
        }()

        return KeyResult(
            id: id,
            title: entity.title,
            timeMetric: timeMetric,
            quantityMetric: quantityMetric
        )
    }

    static func makeActivity(from entity: ActivityEntity) -> Activity? {
        guard let id = entity.id,
              let date = entity.date else { return nil }

        let tags: [String]
        if let data = entity.tagsData,
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            tags = decoded
        } else {
            tags = []
        }

        let allocations = entity.allocationsSet
            .compactMap { allocation -> KeyResultAllocation? in
                guard let keyResultID = allocation.keyResultID else { return nil }
                return KeyResultAllocation(keyResultID: keyResultID, seconds: allocation.seconds)
            }
            .sorted { $0.keyResultID.uuidString < $1.keyResultID.uuidString }

        return Activity(
            id: id,
            date: date,
            duration: entity.duration,
            linkedObjectiveID: entity.objective?.id,
            note: entity.note,
            tags: tags,
            keyResultAllocations: allocations
        )
    }

    static func fetchSessionDTO(id: UUID, in context: NSManagedObjectContext) throws -> SessionDTO? {
        let request = SessionDTO.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(SessionDTO.id), id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func saveIfNeeded(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    static func fetchObjectiveEntity(id: UUID, in context: NSManagedObjectContext) throws -> ObjectiveEntity? {
        let request = ObjectiveEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ObjectiveEntity.id), id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func fetchActivityEntity(id: UUID, in context: NSManagedObjectContext) throws -> ActivityEntity? {
        let request = ActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ActivityEntity.id), id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func syncKeyResults(
        _ keyResults: [KeyResult],
        to objectiveEntity: ObjectiveEntity,
        in context: NSManagedObjectContext
    ) {
        var existing = Dictionary(uniqueKeysWithValues: objectiveEntity.keyResultsSet.compactMap { entity -> (UUID, KeyResultEntity)? in
            guard let identifier = entity.id else { return nil }
            return (identifier, entity)
        })

        var updated: [KeyResultEntity] = []

        for (index, keyResult) in keyResults.enumerated() {
            let entity = existing.removeValue(forKey: keyResult.id) ?? KeyResultEntity(context: context)
            entity.id = keyResult.id
            entity.title = keyResult.title
            entity.sortIndex = Int64(index)
            entity.objective = objectiveEntity

            if let timeMetric = keyResult.timeMetric {
                entity.timeUnitRaw = timeMetric.unit.rawValue
                entity.timeTarget = NSNumber(value: timeMetric.target)
                entity.timeLogged = NSNumber(value: timeMetric.logged)
            } else {
                entity.timeUnitRaw = nil
                entity.timeTarget = nil
                entity.timeLogged = nil
            }

            if let quantityMetric = keyResult.quantityMetric {
                entity.quantityUnit = quantityMetric.unit
                entity.quantityTarget = NSNumber(value: quantityMetric.target)
                entity.quantityCurrent = NSNumber(value: quantityMetric.current)
            } else {
                entity.quantityUnit = nil
                entity.quantityTarget = nil
                entity.quantityCurrent = nil
            }

            updated.append(entity)
        }

        existing.values.forEach { context.delete($0) }
        objectiveEntity.keyResultsSet = Set(updated)
    }

    static func apply(
        _ activity: Activity,
        to entity: ActivityEntity,
        in context: NSManagedObjectContext
    ) throws {
        entity.id = activity.id
        entity.date = activity.date
        entity.duration = activity.duration
        entity.note = activity.note
        entity.tagsData = try JSONEncoder().encode(activity.tags)

        if let objectiveID = activity.linkedObjectiveID,
           let objective = try Self.fetchObjectiveEntity(id: objectiveID, in: context) {
            entity.objective = objective
        } else {
            entity.objective = nil
        }

        entity.allocationsSet.forEach { context.delete($0) }

        let allocationEntities = activity.keyResultAllocations.map { allocation -> KeyResultAllocationEntity in
            let allocationEntity = KeyResultAllocationEntity(context: context)
            allocationEntity.id = UUID()
            allocationEntity.keyResultID = allocation.keyResultID
            allocationEntity.seconds = allocation.seconds
            allocationEntity.activity = entity
            return allocationEntity
        }

        entity.allocationsSet = Set(allocationEntities)
    }
}
