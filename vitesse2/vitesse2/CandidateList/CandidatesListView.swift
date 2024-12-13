import SwiftUI

struct CandidateListView: View {
    @StateObject private var viewModel: CandidateListViewModel
    @State private var showingAddSheet = false
    
    init(isAdmin: Bool) {
        _viewModel = StateObject(wrappedValue: CandidateListViewModel(isAdmin: isAdmin))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                
                CandidateList(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Candidates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isAdmin {
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCandidateView(isPresented: $showingAddSheet)
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCandidates()
            }
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .disableAutocorrection(true)
    }
}

struct CandidateList: View {
    @ObservedObject var viewModel: CandidateListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.filteredCandidates) { candidate in
                NavigationLink(destination: ProfilView(candidateId: candidate.id, isAdmin: viewModel.isAdmin)) {
                    CandidateRowView(candidate: candidate, viewModel: viewModel)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct CandidateRowView: View {
    let candidate: Candidate
    @ObservedObject var viewModel: CandidateListViewModel
    
    var body: some View {
        HStack {
            if viewModel.isEditing {
                Circle()
                    .fill(viewModel.selectedCandidates.contains(candidate.id) ? Color.blue : Color.gray)
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading) {
                Text("\(candidate.firstName) \(candidate.lastName)")
                    .font(.headline)
                Text(candidate.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !viewModel.isEditing && viewModel.isAdmin {
                Image(systemName: candidate.isFavorite ? "star.fill" : "star")
                    .foregroundColor(candidate.isFavorite ? .yellow : .gray)
                    .onTapGesture {
                        Task {
                            await viewModel.toggleFavorite(for: candidate)
                        }
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isEditing {
                viewModel.toggleSelection(for: candidate)
            }
        }
    }
}

struct AddCandidateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddCandidateViewModel()
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("LinkedIn URL", text: $viewModel.linkedinURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextEditor(text: $viewModel.note)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Candidate")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    Task {
                        if await viewModel.saveCandidate() {
                            isPresented = false
                        }
                    }
                }
            )
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

@MainActor
class AddCandidateViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var linkedinURL: String = ""
    @Published var note: String = ""
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    private let networkService = NetworkService.shared
    
    func saveCandidate() async -> Bool {
        guard isValidInput else {
            errorMessage = "Please fill in all required fields"
            showAlert = true
            return false
        }
        
        let candidate = CandidateRequest(
            email: email,
            note: note.isEmpty ? nil : note,
            linkedinURL: linkedinURL.isEmpty ? nil : linkedinURL,
            firstName: firstName,
            lastName: lastName,
            phone: phone.isEmpty ? nil : phone
        )
        
        do {
            let _: Candidate = try await networkService.request(.createCandidate(candidate))
            return true
        } catch {
            if let networkError = error as? NetworkService.NetworkError {
                errorMessage = networkError.message
            } else {
                errorMessage = "An unexpected error occurred"
            }
            showAlert = true
            return false
        }
    }
    
    private var isValidInput: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct CandidateListView_Previews: PreviewProvider {
    static var previews: some View {
        CandidateListView(isAdmin: true)
    }
}
