import CoreData

enum SessionTrackerManagedObjectModelFactory {
    static func make() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let objective = makeObjectiveComponents()
        let keyResult = makeKeyResultComponents()
        let activity = makeActivityComponents()
        let allocation = makeAllocationComponents()

        configureRelationships(
            objective: objective,
            keyResult: keyResult,
            activity: activity,
            allocation: allocation
        )

        let session = makeSessionEntity()

        model.entities = [
            objective.entity,
            keyResult.entity,
            activity.entity,
            allocation.entity,
            session
        ]
        return model
    }
}

// MARK: - Entity Builders

private extension SessionTrackerManagedObjectModelFactory {
    static func makeObjectiveComponents() -> ObjectiveComponents {
        let entity = makeEntity(
            name: "ObjectiveEntity",
            managedObjectClass: ObjectiveEntity.self
        )

        let attributes = [
            attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
            attribute(name: "title", type: .stringAttributeType, isOptional: false, defaultValue: ""),
            attribute(name: "colorHex", type: .stringAttributeType, isOptional: true)
        ]

        let keyResults = relationship(
            name: "keyResults",
            minCount: 0,
            maxCount: 0,
            deleteRule: .cascadeDeleteRule
        )

        let activities = relationship(
            name: "activities",
            minCount: 0,
            maxCount: 0,
            deleteRule: .nullifyDeleteRule
        )

        entity.properties = attributes + [keyResults, activities]

        return ObjectiveComponents(
            entity: entity,
            keyResults: keyResults,
            activities: activities
        )
    }

    static func makeKeyResultComponents() -> KeyResultComponents {
        let entity = makeEntity(
            name: "KeyResultEntity",
            managedObjectClass: KeyResultEntity.self
        )

        let attributes = [
            attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
            attribute(name: "title", type: .stringAttributeType, isOptional: false, defaultValue: ""),
            attribute(
                name: "sortIndex",
                type: .integer64AttributeType,
                isOptional: false,
                defaultValue: NSNumber(value: 0)
            ),
            attribute(name: "timeUnitRaw", type: .stringAttributeType, isOptional: true),
            attribute(name: "timeTarget", type: .doubleAttributeType, isOptional: true),
            attribute(name: "timeLogged", type: .doubleAttributeType, isOptional: true),
            attribute(name: "quantityUnit", type: .stringAttributeType, isOptional: true),
            attribute(name: "quantityTarget", type: .doubleAttributeType, isOptional: true),
            attribute(name: "quantityCurrent", type: .doubleAttributeType, isOptional: true)
        ]

        let objective = relationship(
            name: "objective",
            minCount: 0,
            maxCount: 1,
            deleteRule: .nullifyDeleteRule
        )

        entity.properties = attributes + [objective]

        return KeyResultComponents(entity: entity, objective: objective)
    }

    static func makeActivityComponents() -> ActivityComponents {
        let entity = makeEntity(
            name: "ActivityEntity",
            managedObjectClass: ActivityEntity.self
        )

        let attributes = [
            attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
            attribute(name: "date", type: .dateAttributeType, isOptional: true),
            attribute(
                name: "duration",
                type: .doubleAttributeType,
                isOptional: false,
                defaultValue: NSNumber(value: 0)
            ),
            attribute(name: "note", type: .stringAttributeType, isOptional: true),
            attribute(name: "tagsData", type: .binaryDataAttributeType, isOptional: true)
        ]

        let objective = relationship(
            name: "objective",
            minCount: 0,
            maxCount: 1,
            deleteRule: .nullifyDeleteRule
        )

        let allocations = relationship(
            name: "allocations",
            minCount: 0,
            maxCount: 0,
            deleteRule: .cascadeDeleteRule
        )

        entity.properties = attributes + [objective, allocations]

        return ActivityComponents(
            entity: entity,
            objective: objective,
            allocations: allocations
        )
    }

    static func makeAllocationComponents() -> AllocationComponents {
        let entity = makeEntity(
            name: "KeyResultAllocationEntity",
            managedObjectClass: KeyResultAllocationEntity.self
        )

        let attributes = [
            attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
            attribute(name: "keyResultID", type: .UUIDAttributeType, isOptional: true),
            attribute(
                name: "seconds",
                type: .doubleAttributeType,
                isOptional: false,
                defaultValue: NSNumber(value: 0)
            )
        ]

        let activity = relationship(
            name: "activity",
            minCount: 0,
            maxCount: 1,
            deleteRule: .nullifyDeleteRule
        )

        entity.properties = attributes + [activity]

        return AllocationComponents(entity: entity, activity: activity)
    }

    static func makeSessionEntity() -> NSEntityDescription {
        let entity = makeEntity(
            name: "SessionDTO",
            managedObjectClass: SessionDTO.self
        )

        entity.properties = [
            attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
            attribute(name: "startedAt", type: .dateAttributeType, isOptional: true),
            attribute(
                name: "duration",
                type: .doubleAttributeType,
                isOptional: false,
                defaultValue: NSNumber(value: 0)
            )
        ]

        return entity
    }
}

// MARK: - Relationship Configuration

private extension SessionTrackerManagedObjectModelFactory {
    static func configureRelationships(
        objective: ObjectiveComponents,
        keyResult: KeyResultComponents,
        activity: ActivityComponents,
        allocation: AllocationComponents
    ) {
        objective.keyResults.destinationEntity = keyResult.entity
        objective.activities.destinationEntity = activity.entity

        keyResult.objective.destinationEntity = objective.entity
        activity.objective.destinationEntity = objective.entity
        activity.allocations.destinationEntity = allocation.entity

        allocation.activity.destinationEntity = activity.entity

        objective.keyResults.inverseRelationship = keyResult.objective
        keyResult.objective.inverseRelationship = objective.keyResults

        objective.activities.inverseRelationship = activity.objective
        activity.objective.inverseRelationship = objective.activities

        activity.allocations.inverseRelationship = allocation.activity
        allocation.activity.inverseRelationship = activity.allocations
    }
}

// MARK: - Helpers

private extension SessionTrackerManagedObjectModelFactory {
    static func makeEntity(
        name: String,
        managedObjectClass: AnyClass
    ) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = NSStringFromClass(managedObjectClass)
        return entity
    }

    static func attribute(
        name: String,
        type: NSAttributeType,
        isOptional: Bool,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        if let defaultValue {
            attribute.defaultValue = defaultValue
        }
        return attribute
    }

    static func relationship(
        name: String,
        minCount: Int,
        maxCount: Int,
        deleteRule: NSDeleteRule
    ) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.minCount = minCount
        relationship.maxCount = maxCount
        relationship.deleteRule = deleteRule
        return relationship
    }
}

// MARK: - Component Containers

private struct ObjectiveComponents {
    let entity: NSEntityDescription
    let keyResults: NSRelationshipDescription
    let activities: NSRelationshipDescription
}

private struct KeyResultComponents {
    let entity: NSEntityDescription
    let objective: NSRelationshipDescription
}

private struct ActivityComponents {
    let entity: NSEntityDescription
    let objective: NSRelationshipDescription
    let allocations: NSRelationshipDescription
}

private struct AllocationComponents {
    let entity: NSEntityDescription
    let activity: NSRelationshipDescription
}
