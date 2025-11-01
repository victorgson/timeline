struct SessionTrackerUseCases {
    let loadObjectives: DefaultLoadObjectivesUseCase
    let loadActivities: DefaultLoadActivitiesUseCase
    let upsertObjective: DefaultUpsertObjectiveUseCase
    let createObjective: DefaultCreateObjectiveUseCase
    let removeObjective: DefaultRemoveObjectiveUseCase
    let recordActivity: DefaultRecordActivityUseCase
    let updateActivity: DefaultUpdateActivityUseCase
    let removeActivity: DefaultRemoveActivityUseCase
    let fetchSessions: DefaultFetchSessionsUseCase
    let addSession: DefaultAddSessionUseCase
    let updateSession: DefaultUpdateSessionUseCase
    let deleteSession: DefaultDeleteSessionUseCase

    static func make(repository: SessionTrackerRepository) -> SessionTrackerUseCases {
        SessionTrackerUseCases(
            loadObjectives: DefaultLoadObjectivesUseCase(repository: repository),
            loadActivities: DefaultLoadActivitiesUseCase(repository: repository),
            upsertObjective: DefaultUpsertObjectiveUseCase(repository: repository),
            createObjective: DefaultCreateObjectiveUseCase(repository: repository),
            removeObjective: DefaultRemoveObjectiveUseCase(repository: repository),
            recordActivity: DefaultRecordActivityUseCase(repository: repository),
            updateActivity: DefaultUpdateActivityUseCase(repository: repository),
            removeActivity: DefaultRemoveActivityUseCase(repository: repository),
            fetchSessions: DefaultFetchSessionsUseCase(repository: repository),
            addSession: DefaultAddSessionUseCase(repository: repository),
            updateSession: DefaultUpdateSessionUseCase(repository: repository),
            deleteSession: DefaultDeleteSessionUseCase(repository: repository)
        )
    }
}
