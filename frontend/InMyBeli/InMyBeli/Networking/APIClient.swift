import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case http(status: Int, body: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .transport(let err): return err.localizedDescription
        case .http(let status, let body): return "HTTP \(status): \(body ?? "")"
        case .decoding(let err): return "Decoding failed: \(err.localizedDescription)"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    var baseURL: URL = URL(string: "http://localhost:5000/api")!
    var sessionToken: String?

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func get<T: Decodable>(_ path: String, as: T.Type) async throws -> T {
        try await request(path: path, method: "GET", body: Optional<Data>.none, as: T.self)
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B, as: T.Type) async throws -> T {
        let data = try JSONEncoder().encode(body)
        return try await request(path: path, method: "POST", body: data, as: T.self)
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        as: T.Type
    ) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = sessionToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.http(status: -1, body: nil)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(status: http.statusCode, body: String(data: data, encoding: .utf8))
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
