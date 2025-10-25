import CoreData

@objc(SessionDTO)
final class SessionDTO: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var startedAt: Date?
    @NSManaged var duration: Double
}

extension SessionDTO {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SessionDTO> {
        NSFetchRequest<SessionDTO>(entityName: "SessionDTO")
    }

    func configure(with session: Session) {
        id = session.id
        startedAt = session.startedAt
        duration = session.duration
    }

    func makeDomainModel() -> Session {
        Session(
            id: id ?? UUID(),
            startedAt: startedAt ?? Date(),
            duration: duration
        )
    }
}
