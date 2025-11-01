import CoreData

@objc(KeyResultEntity)
final class KeyResultEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var title: String
    @NSManaged var sortIndex: Int64
    @NSManaged var timeUnitRaw: String?
    @NSManaged var timeTarget: NSNumber?
    @NSManaged var timeLogged: NSNumber?
    @NSManaged var quantityUnit: String?
    @NSManaged var quantityTarget: NSNumber?
    @NSManaged var quantityCurrent: NSNumber?
    @NSManaged var objective: ObjectiveEntity?
}
