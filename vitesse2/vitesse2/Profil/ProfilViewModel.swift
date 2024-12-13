//
//  ProfilViewModel.swift
//  vitesse2
//
//  Created by TLiLi Hamdi on 13/12/2024.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var profile: UserProfile
    @Published var editedProfile: UserProfile
    @Published var isEditing: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    private let networkService = NetworkService.shared
    let isAdmin: Bool
    private let candidateId: String
    
    // MARK: - Initialization
    init(candidateId: String, isAdmin: Bool) {
        self.candidateId = candidateId
        self.isAdmin = isAdmin
        self.profile = UserProfile()
        self.editedProfile = UserProfile()
        
        // Charger le profil au démarrage
        Task {
            await fetchProfile()
        }
    }
    
    // MARK: - Profile Management
    func fetchProfile() async {
        isLoading = true
        do {
            let candidate: Candidate = try await networkService.request(.candidate(id: candidateId))
            profile = UserProfile(
                id: candidate.id,
                firstName: candidate.firstName,
                lastName: candidate.lastName,
                phone: candidate.phone ?? "",
                email: candidate.email,
                linkedinURL: candidate.linkedinURL,
                note: candidate.note,
                isFavorite: candidate.isFavorite
            )
            editedProfile = profile
            isLoading = false
        } catch {
            handleError(error)
        }
    }
    
    func saveProfile() async {
        isLoading = true
        do {
            let request = CandidateRequest(
                email: editedProfile.email,
                note: editedProfile.note,
                linkedinURL: editedProfile.linkedinURL,
                firstName: editedProfile.firstName,
                lastName: editedProfile.lastName,
                phone: editedProfile.phone.isEmpty ? nil : editedProfile.phone
            )
            
            let updatedCandidate: Candidate = try await networkService.request(
                .updateCandidate(id: candidateId, candidate: request)
            )
            
            profile = UserProfile(
                id: updatedCandidate.id,
                firstName: updatedCandidate.firstName,
                lastName: updatedCandidate.lastName,
                phone: updatedCandidate.phone ?? "",
                email: updatedCandidate.email,
                linkedinURL: updatedCandidate.linkedinURL,
                note: updatedCandidate.note,
                isFavorite: updatedCandidate.isFavorite
            )
            
            isEditing = false
            isLoading = false
        } catch {
            handleError(error)
        }
    }
    
    func toggleFavorite() async {
        guard isAdmin else { return }
        
        isLoading = true
        do {
            let updatedCandidate: Candidate = try await networkService.request(.toggleFavorite(id: candidateId))
            profile.isFavorite = updatedCandidate.isFavorite
            editedProfile.isFavorite = updatedCandidate.isFavorite
            isLoading = false
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Editing
    func startEditing() {
        editedProfile = profile
        isEditing = true
    }
    
    func cancelEditing() {
        editedProfile = profile
        isEditing = false
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkService.NetworkError {
            errorMessage = networkError.message
        } else {
            errorMessage = "Une erreur inattendue s'est produite"
        }
        showAlert = true
        isLoading = false
    }
}
