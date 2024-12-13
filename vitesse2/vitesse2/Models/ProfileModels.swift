import Foundation

struct UserProfile: Codable, Equatable {
    var id: String = UUID().uuidString
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var linkedinURL: String?
    var note: String?
    var isFavorite: Bool
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: String = UUID().uuidString,
         firstName: String = "",
         lastName: String = "",
         phone: String = "",
         email: String = "",
         linkedinURL: String? = nil,
         note: String? = nil,
         isFavorite: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.linkedinURL = linkedinURL
        self.note = note
        self.isFavorite = isFavorite
    }
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.id == rhs.id
    }
}
