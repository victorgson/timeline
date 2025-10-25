import CoreData

@objc(KeyResultAllocationEntity)
final class KeyResultAllocationEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var keyResultID: UUID?
    @NSManaged var seconds: Double
    @NSManaged var activity: ActivityEntity?
}
