import Foundation

enum Configuration {
    static var openAIApiKey: String {
        guard let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("OpenAI API Key not found in configuration")
        }
        return apiKey
    }
}
