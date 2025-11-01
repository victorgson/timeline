import CoreData

@objc(ActivityEntity)
final class ActivityEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var date: Date?
    @NSManaged var duration: Double
    @NSManaged var note: String?
    @NSManaged var tagsData: Data?
    @NSManaged var objective: ObjectiveEntity?
    @NSManaged var allocations: NSSet?
}

extension ActivityEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ActivityEntity> {
        NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
    }

    var allocationsSet: Set<KeyResultAllocationEntity> {
        get { (allocations as? Set<KeyResultAllocationEntity>) ?? [] }
        set { allocations = NSSet(set: newValue) }
    }
}
