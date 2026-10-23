import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var errorMessage: String?

    private let storage: NotesStorageService
    private let syncService: SyncService
    private var syncTasks: [UUID: Task<Void, Never>] = [:]

    init(storage: NotesStorageService = NotesStorageService(),
         syncService: SyncService = SyncService()) {
        self.storage = storage
        self.syncService = syncService
        do {
            notes = try storage.loadNotes()
        } catch {
            errorMessage = "Could not load local notes: \(error.localizedDescription)"
        }
    }

    func createNote(title: String, body: String) {
        let note = Note(title: title, body: body)
        notes.insert(note, at: 0)
        persist()
        startSync(for: note)
    }

    func updateNote(id: UUID, title: String, body: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        // Increment version so an older in-flight request cannot mark new content as synced.
        notes[index].title = title
        notes[index].body = body
        notes[index].updatedAt = Date()
        notes[index].version += 1
        notes[index].syncStatus = .pending
        notes[index].lastError = nil
        let updatedNote = notes[index]
        persist()

        // Cancel the old local task if possible; version checking below remains the safety net.
        syncTasks[id]?.cancel()
        startSync(for: updatedNote)
    }

    func deleteNote(id: UUID) {
        syncTasks[id]?.cancel()
        syncTasks[id] = nil
        notes.removeAll { $0.id == id }
        persist()
    }

    func retryNote(id: UUID) {
        guard let note = notes.first(where: { $0.id == id }) else { return }
        startSync(for: note)
    }

    private func startSync(for note: Note) {
        syncTasks[note.id]?.cancel()
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].syncStatus = .syncing
        notes[index].lastError = nil
        persist()

        let noteVersion = note.version
        let noteID = note.id
        let service = syncService

        syncTasks[noteID] = Task {
            do {
                try await service.sync(note: note)
                guard let currentIndex = notes.firstIndex(where: { $0.id == noteID }) else {
                    return
                }
                // Ignore completion from a stale upload if the note changed while syncing.
                guard notes[currentIndex].version == noteVersion else { return }
                notes[currentIndex].syncStatus = .synced
                notes[currentIndex].lastError = nil
                persist()
            } catch is CancellationError {
                // An edit or deletion superseded this request.
            } catch {
                guard let currentIndex = notes.firstIndex(where: { $0.id == noteID }),
                      notes[currentIndex].version == noteVersion else { return }
                notes[currentIndex].syncStatus = .failed
                notes[currentIndex].lastError = error.localizedDescription
                errorMessage = "Sync failed for “\(notes[currentIndex].title)”. You can retry."
                persist()
            }
            syncTasks[noteID] = nil
        }
    }

    private func persist() {
        do {
            try storage.saveNotes(notes)
        } catch {
            errorMessage = "Could not save local notes: \(error.localizedDescription)"
        }
    }
}
