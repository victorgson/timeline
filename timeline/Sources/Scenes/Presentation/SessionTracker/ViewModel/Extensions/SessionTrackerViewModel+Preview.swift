import Foundation
import Dispatch

@MainActor
extension SessionTrackerViewModel {
    static var preview: SessionTrackerViewModel {
        let calendar = Calendar.current
        let deepWork = Objective(
            title: "Deep Work",
            colorHex: "#6366F1",
            endDate: calendar.date(byAdding: .day, value: 21, to: .now),
            keyResults: [
                KeyResult(
                    title: "Log 12 hours of focus",
                    timeMetric: .init(unit: .hours, target: 12, logged: 5.5)
                ),
                KeyResult(
                    title: "Ship three features",
                    quantityMetric: .init(unit: "features", target: 3, current: 1)
                )
            ]
        )

        let recovery = Objective(
            title: "Recovery",
            colorHex: "#22C55E",
            endDate: calendar.date(byAdding: .day, value: 14, to: .now),
            keyResults: [
                KeyResult(
                    title: "Sleep 56 hours",
                    timeMetric: .init(unit: .hours, target: 56, logged: 32)
                ),
                KeyResult(
                    title: "Stretch sessions",
                    quantityMetric: .init(unit: "sessions", target: 14, current: 6)
                )
            ]
        )

        let movement = Objective(
            title: "Movement",
            colorHex: "#F59E0B",
            endDate: calendar.date(byAdding: .day, value: 7, to: .now),
            keyResults: [
                KeyResult(
                    title: "Run 20km",
                    quantityMetric: .init(unit: "km", target: 20, current: 8)
                )
            ]
        )

        let activities: [Activity] = [
            Activity(
                date: Date().addingTimeInterval(-1_800),
                duration: 90 * 60,
                linkedObjectiveID: deepWork.id,
                note: "Flowed through the editor build.",
                tags: ["feature", "heads-down"],
                keyResultAllocations: [
                    KeyResultAllocation(keyResultID: deepWork.keyResults[0].id, seconds: 90 * 60)
                ]
            ),
            Activity(
                date: Date().addingTimeInterval(-14_400),
                duration: 45 * 60,
                linkedObjectiveID: recovery.id,
                note: "Mobility + strength block.",
                keyResultAllocations: [
                    KeyResultAllocation(keyResultID: recovery.keyResults[0].id, seconds: 45 * 60)
                ]
            )
        ]

        let persistence = PersistenceController(isPremiumEnabled: false, useInMemoryStore: true)
        let repository = CoreDataSessionTrackerRepository(persistenceController: persistence)
        let useCases = SessionTrackerUseCases.make(repository: repository)

        let semaphore = DispatchSemaphore(value: 0)
        Task {
            await seedPreviewData(
                useCases: useCases,
                objectives: [deepWork, recovery, movement],
                activities: activities
            )
            semaphore.signal()
        }
        semaphore.wait()

        return SessionTrackerViewModel(
            useCases: useCases,
            liveActivityController: NoopSessionLiveActivityController()
        )
    }
}

@MainActor
private extension SessionTrackerViewModel {
    static func seedPreviewData(
        useCases: SessionTrackerUseCases,
        objectives: [Objective],
        activities: [Activity]
    ) async {
        for objective in objectives {
            try? await useCases.upsertObjective.execute(objective)
        }

        for activity in activities {
            try? await useCases.recordActivity.execute(activity)
        }
    }
}
