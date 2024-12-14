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


