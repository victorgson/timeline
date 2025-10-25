import Foundation
import CoreData
import CloudKit

final class PersistenceController {
    let mode: PersistenceMode
    let container: NSPersistentContainer

    init(isPremiumEnabled: Bool, useInMemoryStore: Bool = false) {
        // In production, wire `isPremiumEnabled` to the subscription state (RevenueCat / StoreKit).
        let model = Self.makeModel()
        self.mode = isPremiumEnabled ? .cloud : .local

        switch mode {
        case .cloud:
            let cloudContainer = NSPersistentCloudKitContainer(
                name: "SessionTracker",
                managedObjectModel: model
            )
            let description = cloudContainer.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
            if useInMemoryStore {
                description.type = NSInMemoryStoreType
                description.url = URL(fileURLWithPath: "/dev/null")
                description.cloudKitContainerOptions = nil
            } else {
                description.type = NSSQLiteStoreType
                // Replace the placeholder identifier below with the real iCloud container ID once provisioning is in place.
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                    containerIdentifier: "iCloud.com.placeholder.sessiontracker"
                )
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            cloudContainer.persistentStoreDescriptions = [description]
            container = cloudContainer
        case .local:
            let persistentContainer = NSPersistentContainer(
                name: "SessionTracker",
                managedObjectModel: model
            )
            let description = persistentContainer.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
            if useInMemoryStore {
                description.type = NSInMemoryStoreType
                description.url = URL(fileURLWithPath: "/dev/null")
            } else {
                description.type = NSSQLiteStoreType
            }
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            persistentContainer.persistentStoreDescriptions = [description]
            container = persistentContainer
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil

        let semaphore = DispatchSemaphore(value: 0)
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent store: \(error)")
            }
            semaphore.signal()
        }
        semaphore.wait()

        // When upgrading from .local to .cloud, use this hook to migrate the SQLite store into CloudKit.
        // That logic will land alongside the purchase flow once real premium gating is wired up.
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}

private extension PersistenceController {
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Session entity
        // Objective entity
        let objectiveEntity = NSEntityDescription()
        objectiveEntity.name = "ObjectiveEntity"
        objectiveEntity.managedObjectClassName = NSStringFromClass(ObjectiveEntity.self)

        let objectiveID = NSAttributeDescription()
        objectiveID.name = "id"
        objectiveID.attributeType = .UUIDAttributeType
        objectiveID.isOptional = true

        let objectiveTitle = NSAttributeDescription()
        objectiveTitle.name = "title"
        objectiveTitle.attributeType = .stringAttributeType
        objectiveTitle.isOptional = false
        objectiveTitle.defaultValue = ""

        let objectiveColorHex = NSAttributeDescription()
        objectiveColorHex.name = "colorHex"
        objectiveColorHex.attributeType = .stringAttributeType
        objectiveColorHex.isOptional = true

        // KeyResult entity
        let keyResultEntity = NSEntityDescription()
        keyResultEntity.name = "KeyResultEntity"
        keyResultEntity.managedObjectClassName = NSStringFromClass(KeyResultEntity.self)

        let keyResultID = NSAttributeDescription()
        keyResultID.name = "id"
        keyResultID.attributeType = .UUIDAttributeType
        keyResultID.isOptional = true

        let keyResultTitle = NSAttributeDescription()
        keyResultTitle.name = "title"
        keyResultTitle.attributeType = .stringAttributeType
        keyResultTitle.isOptional = false
        keyResultTitle.defaultValue = ""

        let keyResultSortIndex = NSAttributeDescription()
        keyResultSortIndex.name = "sortIndex"
        keyResultSortIndex.attributeType = .integer64AttributeType
        keyResultSortIndex.isOptional = false
        keyResultSortIndex.defaultValue = NSNumber(value: 0)

        let keyResultTimeUnit = NSAttributeDescription()
        keyResultTimeUnit.name = "timeUnitRaw"
        keyResultTimeUnit.attributeType = .stringAttributeType
        keyResultTimeUnit.isOptional = true

        let keyResultTimeTarget = NSAttributeDescription()
        keyResultTimeTarget.name = "timeTarget"
        keyResultTimeTarget.attributeType = .doubleAttributeType
        keyResultTimeTarget.isOptional = true

        let keyResultTimeLogged = NSAttributeDescription()
        keyResultTimeLogged.name = "timeLogged"
        keyResultTimeLogged.attributeType = .doubleAttributeType
        keyResultTimeLogged.isOptional = true

        let keyResultQuantityUnit = NSAttributeDescription()
        keyResultQuantityUnit.name = "quantityUnit"
        keyResultQuantityUnit.attributeType = .stringAttributeType
        keyResultQuantityUnit.isOptional = true

        let keyResultQuantityTarget = NSAttributeDescription()
        keyResultQuantityTarget.name = "quantityTarget"
        keyResultQuantityTarget.attributeType = .doubleAttributeType
        keyResultQuantityTarget.isOptional = true

        let keyResultQuantityCurrent = NSAttributeDescription()
        keyResultQuantityCurrent.name = "quantityCurrent"
        keyResultQuantityCurrent.attributeType = .doubleAttributeType
        keyResultQuantityCurrent.isOptional = true

        // Activity entity
        let activityEntity = NSEntityDescription()
        activityEntity.name = "ActivityEntity"
        activityEntity.managedObjectClassName = NSStringFromClass(ActivityEntity.self)

        let activityID = NSAttributeDescription()
        activityID.name = "id"
        activityID.attributeType = .UUIDAttributeType
        activityID.isOptional = true

        let activityDate = NSAttributeDescription()
        activityDate.name = "date"
        activityDate.attributeType = .dateAttributeType
        activityDate.isOptional = true

        let activityDuration = NSAttributeDescription()
        activityDuration.name = "duration"
        activityDuration.attributeType = .doubleAttributeType
        activityDuration.isOptional = false
        activityDuration.defaultValue = NSNumber(value: 0)

        let activityNote = NSAttributeDescription()
        activityNote.name = "note"
        activityNote.attributeType = .stringAttributeType
        activityNote.isOptional = true

        let activityTags = NSAttributeDescription()
        activityTags.name = "tagsData"
        activityTags.attributeType = .binaryDataAttributeType
        activityTags.isOptional = true

        // KeyResultAllocation entity
        let allocationEntity = NSEntityDescription()
        allocationEntity.name = "KeyResultAllocationEntity"
        allocationEntity.managedObjectClassName = NSStringFromClass(KeyResultAllocationEntity.self)

        let allocationID = NSAttributeDescription()
        allocationID.name = "id"
        allocationID.attributeType = .UUIDAttributeType
        allocationID.isOptional = true

        let allocationKeyResultID = NSAttributeDescription()
        allocationKeyResultID.name = "keyResultID"
        allocationKeyResultID.attributeType = .UUIDAttributeType
        allocationKeyResultID.isOptional = true

        let allocationSeconds = NSAttributeDescription()
        allocationSeconds.name = "seconds"
        allocationSeconds.attributeType = .doubleAttributeType
        allocationSeconds.isOptional = false
        allocationSeconds.defaultValue = NSNumber(value: 0)

        // Relationships
        let objectiveKeyResults = NSRelationshipDescription()
        objectiveKeyResults.name = "keyResults"
        objectiveKeyResults.destinationEntity = keyResultEntity
        objectiveKeyResults.minCount = 0
        objectiveKeyResults.maxCount = 0
        objectiveKeyResults.deleteRule = .cascadeDeleteRule

        let objectiveActivities = NSRelationshipDescription()
        objectiveActivities.name = "activities"
        objectiveActivities.destinationEntity = activityEntity
        objectiveActivities.minCount = 0
        objectiveActivities.maxCount = 0
        objectiveActivities.deleteRule = .nullifyDeleteRule

        let keyResultObjective = NSRelationshipDescription()
        keyResultObjective.name = "objective"
        keyResultObjective.destinationEntity = objectiveEntity
        keyResultObjective.minCount = 0
        keyResultObjective.maxCount = 1
        keyResultObjective.deleteRule = .nullifyDeleteRule

        let activityObjective = NSRelationshipDescription()
        activityObjective.name = "objective"
        activityObjective.destinationEntity = objectiveEntity
        activityObjective.minCount = 0
        activityObjective.maxCount = 1
        activityObjective.deleteRule = .nullifyDeleteRule

        let activityAllocations = NSRelationshipDescription()
        activityAllocations.name = "allocations"
        activityAllocations.destinationEntity = allocationEntity
        activityAllocations.minCount = 0
        activityAllocations.maxCount = 0
        activityAllocations.deleteRule = .cascadeDeleteRule

        let allocationActivity = NSRelationshipDescription()
        allocationActivity.name = "activity"
        allocationActivity.destinationEntity = activityEntity
        allocationActivity.minCount = 0
        allocationActivity.maxCount = 1
        allocationActivity.deleteRule = .nullifyDeleteRule

        // Assign properties
        objectiveEntity.properties = [
            objectiveID,
            objectiveTitle,
            objectiveColorHex,
            objectiveKeyResults,
            objectiveActivities
        ]

        keyResultEntity.properties = [
            keyResultID,
            keyResultTitle,
            keyResultSortIndex,
            keyResultTimeUnit,
            keyResultTimeTarget,
            keyResultTimeLogged,
            keyResultQuantityUnit,
            keyResultQuantityTarget,
            keyResultQuantityCurrent,
            keyResultObjective
        ]

        activityEntity.properties = [
            activityID,
            activityDate,
            activityDuration,
            activityNote,
            activityTags,
            activityObjective,
            activityAllocations
        ]

        allocationEntity.properties = [
            allocationID,
            allocationKeyResultID,
            allocationSeconds,
            allocationActivity
        ]

        // Inverse relationships
        objectiveKeyResults.inverseRelationship = keyResultObjective
        keyResultObjective.inverseRelationship = objectiveKeyResults

        objectiveActivities.inverseRelationship = activityObjective
        activityObjective.inverseRelationship = objectiveActivities

        activityAllocations.inverseRelationship = allocationActivity
        allocationActivity.inverseRelationship = activityAllocations

        model.entities = [
            objectiveEntity,
            keyResultEntity,
            activityEntity,
            allocationEntity
        ]
        // Session entity (listed last to reflect standalone data set)
        let sessionEntity = NSEntityDescription()
        sessionEntity.name = "SessionDTO"
        sessionEntity.managedObjectClassName = NSStringFromClass(SessionDTO.self)

        let sessionID = NSAttributeDescription()
        sessionID.name = "id"
        sessionID.attributeType = .UUIDAttributeType
        sessionID.isOptional = true

        let sessionStartedAt = NSAttributeDescription()
        sessionStartedAt.name = "startedAt"
        sessionStartedAt.attributeType = .dateAttributeType
        sessionStartedAt.isOptional = true

        let sessionDuration = NSAttributeDescription()
        sessionDuration.name = "duration"
        sessionDuration.attributeType = .doubleAttributeType
        sessionDuration.isOptional = false
        sessionDuration.defaultValue = NSNumber(value: 0)

        sessionEntity.properties = [
            sessionID,
            sessionStartedAt,
            sessionDuration
        ]

        model.entities.append(sessionEntity)
        return model
    }
}
