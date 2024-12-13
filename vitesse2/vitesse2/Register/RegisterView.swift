//
//  RegisterView.swift
//  vitesse2
//
//  Created by TLiLi Hamdi on 11/12/2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo ou titre
                    Text("Créer un compte")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical, 30)
                    
                    // Champs de saisie
                    VStack(spacing: 15) {
                        TextField("Prénom", text: $viewModel.firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.words)
                        
                        TextField("Nom", text: $viewModel.lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.words)
                        
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Mot de passe", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirmer le mot de passe", text: $viewModel.confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Bouton d'inscription
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                    
                    // Lien pour revenir à la connexion
                    Button(action: { dismiss() }) {
                        Text("Already have an account? Log in")
                            .foregroundColor(.blue)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .alert("Erreur", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onChange(of: viewModel.isRegistered) { isRegistered in
                if isRegistered {
                    dismiss()
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
