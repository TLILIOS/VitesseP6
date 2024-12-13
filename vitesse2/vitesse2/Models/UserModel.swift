import Foundation

struct User {
    let email: String
    let password: String
    
    // Ajoutez d'autres propriétés utilisateur si nécessaire
    var id: UUID = UUID()
    var username: String?
    
    // Méthode de validation basique
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
