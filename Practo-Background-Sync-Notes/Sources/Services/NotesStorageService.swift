import Foundation

/// Stores notes locally as JSON in the app's Documents directory.
/// This keeps notes available when the network is unavailable.
final class NotesStorageService {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent("notes.json")
    }

    func loadNotes() throws -> [Note] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder.notesDecoder.decode([Note].self, from: data)
    }

    func saveNotes(_ notes: [Note]) throws {
        let data = try JSONEncoder.notesEncoder.encode(notes)
        try data.write(to: fileURL, options: [.atomic])
    }
}

private extension JSONEncoder {
    static var notesEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var notesDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
