import CoreData

@objc(ObjectiveEntity)
final class ObjectiveEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var title: String
    @NSManaged var colorHex: String?
    @NSManaged var endDate: Date?
    @NSManaged var keyResults: NSSet?
    @NSManaged var activities: NSSet?
}

extension ObjectiveEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ObjectiveEntity> {
        NSFetchRequest<ObjectiveEntity>(entityName: "ObjectiveEntity")
    }

    var keyResultsSet: Set<KeyResultEntity> {
        get { (keyResults as? Set<KeyResultEntity>) ?? [] }
        set { keyResults = NSSet(set: newValue) }
    }

    var activitiesSet: Set<ActivityEntity> {
        get { (activities as? Set<ActivityEntity>) ?? [] }
        set { activities = NSSet(set: newValue) }
    }

    var sortedKeyResults: [KeyResultEntity] {
        keyResultsSet.sorted { $0.sortIndex < $1.sortIndex }
    }
}
