//
//  ProfilView.swift
//  vitesse2
//
//  Created by TLiLi Hamdi on 13/12/2024.
//

import SwiftUI

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
        