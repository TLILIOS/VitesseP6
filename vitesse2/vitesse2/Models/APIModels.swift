import Foundation

// Modèle pour les candidats
struct Candidate: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?
    var note: String?
    var linkedinURL: String?
    var isFavorite: Bool
}

// Modèle pour les erreurs API
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
    case unauthorized
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .decodingError:
            return "Erreur lors du décodage des données"
        case .unauthorized:
            return "Non autorisé"
        case .unknown:
            return "Erreur inconnue"
        }
    }
}
