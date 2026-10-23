import Foundation

enum SyncStatus: String, Codable {
    case pending
    case syncing
    case failed
    case synced
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var updatedAt: Date
    var syncStatus: SyncStatus
    var version: Int
    var lastError: String?

    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .pending,
        version: Int = 1,
        lastError: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
        self.version = version
        self.lastError = lastError
    }
}
