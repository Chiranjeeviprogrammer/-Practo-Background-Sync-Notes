import Foundation
import UIKit

final class SyncService {
    private let api: NotesAPIService
    private let retryPolicy: RetryPolicy

    init(api: NotesAPIService = NotesAPIService(),
         retryPolicy: RetryPolicy = .standard) {
        self.api = api
        self.retryPolicy = retryPolicy
    }

    func sync(note: Note) async throws {
        var retryNumber = 0

        while true {
            do {
                try await withBackgroundExecutionTime {
                     try await self.api.upload(note: note)
                }
                return
            } catch {
                guard retryNumber < retryPolicy.maximumRetries else {
                    throw error
                }
                retryNumber += 1
                let delay = retryPolicy.delayBeforeRetry(retryNumber: retryNumber)
                try await Task.sleep(for: .seconds(delay))
            }
        }
    }

    private func withBackgroundExecutionTime<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        let taskIDBox = BackgroundTaskIDBox()
        let application = UIApplication.shared

        taskIDBox.id = application.beginBackgroundTask(withName: "NoteSync") {
            taskIDBox.expired = true
            if taskIDBox.id != .invalid {
                application.endBackgroundTask(taskIDBox.id)
                taskIDBox.id = .invalid
            }
        }

        defer {
            if taskIDBox.id != .invalid {
                application.endBackgroundTask(taskIDBox.id)
                taskIDBox.id = .invalid
            }
        }

        let result = try await operation()
        if taskIDBox.expired {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        return result
    }
}

/// Small reference box used by the background-task expiration handler.
private final class BackgroundTaskIDBox {
    var id: UIBackgroundTaskIdentifier = .invalid
    var expired = false
}
