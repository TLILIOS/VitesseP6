//
//  ProfilView.swift
//  vitesse2
//
//  Created by TLiLi Hamdi on 13/12/2024.
//

import SwiftUI

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
 

