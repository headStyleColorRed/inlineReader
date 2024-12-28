import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    struct ChatResponse: Codable {
        let id: String
        let object: String
        struct Choice: Codable {
            struct Message: Codable {
                let content: String
                let refusal: String?
            }
            let message: Message
            let finish_reason: String
        }
        let choices: [Choice]
    }

    func translate(_ text: String) async throws -> String {
        let prompt = """
        Translate the following text to English::::
        \(text)
        """
        print("Prompt: \(prompt)")

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        print("Request Body: \(body)")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")

        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        print("Decoded Response: \(response)")

        return response.choices.first?.message.content ?? "Translation failed"
    }

    func humanizeHTML(_ text: String) async throws -> String {
        let prompt = """
        Fix the following extracted pdf string so it is coherent by removing those newline characters that don't belong, but leave the ones that make sense:::::
        \(text)
        """
        print("Prompt: \(prompt)")

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        print("Request Body: \(body)")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")

        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        print("Decoded Response: \(response)")

        return response.choices.first?.message.content ?? "Translation failed"
    }

    func furtherTranslate(_ text: String) async throws -> String {
        let prompt = """
        Analyze the following text in detail and provide the following information:

        1. The translation of the text into English.
        2. A phonetic pronunciation of the text.
        3. A breakdown of each word with its individual meaning.
        4. Three example sentences using the words in the original text.

        Text to analyze: '\(text)'
        """
        print("Prompt: \(prompt)")

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        print("Request Body: \(body)")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")

        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        print("Decoded Response: \(response)")

        return response.choices.first?.message.content ?? "Further translation failed"
    }
}
