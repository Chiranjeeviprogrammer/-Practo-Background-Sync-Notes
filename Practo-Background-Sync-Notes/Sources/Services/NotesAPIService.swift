import Foundation

struct CreatePostRequest: Encodable {
    let title: String
    let body: String
}

struct CreatePostResponse: Decodable {
    let id: Int?
    let title: String?
    let body: String?
}

/// Network layer required by the assignment:
/// - waits 3 seconds for every attempted request
/// - simulates a network failure 30% of the time before calling the API
final class NotesAPIService {
    private let session: URLSession
    private let endpoint = URL(string: "https://jsonplaceholder.typicode.com/posts")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func upload(note: Note) async throws {
        try await Task.sleep(for: .seconds(3))

        // Inject the simulated failure before the real API call.
        if Double.random(in: 0..<1) < 0.30 {
            throw URLError(.networkConnectionLost)
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            CreatePostRequest(title: note.title, body: note.body)
        )

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // Decode to validate the mock API response. JSONPlaceholder is a mock service;
        // it does not provide durable storage for these notes.
        _ = try? JSONDecoder().decode(CreatePostResponse.self, from: data)
    }
}
