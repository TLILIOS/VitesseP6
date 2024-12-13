//
//  ProfilView.swift
//  vitesse2
//
//  Created by TLiLi Hamdi on 13/12/2024.
//

import SwiftUI

struct ProfilView: View {
    @StateObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(candidateId: String, isAdmin: Bool) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(candidateId: candidateId, isAdmin: isAdmin))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Section titre et étoile
                    HStack {
                        Text(viewModel.profile.fullName)
                            .font(.title)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if !viewModel.isEditing {
                            if viewModel.isAdmin {
                                // Étoile cliquable pour les admins
                                Button(action: {
                                    Task {
                                        await viewModel.toggleFavorite()
                                    }
                                }) {
                                    Image(systemName: viewModel.profile.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(viewModel.profile.isFavorite ? .yellow : .gray)
                                        .font(.title2)
                                }
                                .disabled(viewModel.isLoading)
                            } else {
                                // Étoile non cliquable pour les non-admins
                                Image(systemName: viewModel.profile.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(viewModel.profile.isFavorite ? .yellow : .gray)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    if viewModel.isEditing {
                        EditionProfilView(profile: $viewModel.editedProfile)
                    } else {
                        LectureProfilView(profile: viewModel.profile)
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if viewModel.isEditing {
                            Button(action: {
                                viewModel.cancelEditing()
                            }) {
                                Text("Annuler")
                            }
                            .disabled(viewModel.isLoading)
                        } else {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if viewModel.isEditing {
                            Button(action: {
                                Task {
                                    await viewModel.saveProfile()
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Text("Terminer")
                                }
                            }
                            .disabled(viewModel.isLoading)
                        } else {
                            Button(action: {
                                viewModel.startEditing()
                            }) {
                                Text("Modifier")
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(true)
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct EditionProfilView: View {
    @Binding var profile: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("Prénom")
                        .font(.headline)
                    TextField("Entrez le prénom", text: $profile.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Nom")
                        .font(.headline)
                    TextField("Entrez le nom", text: $profile.lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Téléphone")
                        .font(.headline)
                    TextField("Entrez le numéro de téléphone", text: $profile.phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                
                Group {
                    Text("Email")
                        .font(.headline)
                    TextField("Entrez l'email", text: $profile.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Text("LinkedIn")
                        .font(.headline)
                    TextField("Entrez l'URL LinkedIn", text: Binding(
                        get: { profile.linkedinURL ?? "" },
                        set: { profile.linkedinURL = $0.isEmpty ? nil : $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: Binding(
                        get: { profile.note ?? "" },
                        set: { profile.note = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LectureProfilView: View {
    let profile: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                InfoRow(title: "Téléphone", value: profile.phone)
                InfoRow(title: "Email", value: profile.email)
                
                if let linkedin = profile.linkedinURL, !linkedin.isEmpty {
                    InfoRow(title: "LinkedIn", value: linkedin)
                }
                
                if let note = profile.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Notes")
                            .font(.headline)
                        Text(note)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// Aperçu
struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView(candidateId: "12345", isAdmin: true)
    }
}
