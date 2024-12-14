import SwiftUI

struct CandidateListView: View {
    @StateObject private var viewModel: CandidateListViewModel
    @State private var showingAddSheet = false
    
    init(isAdmin: Bool) {
        _viewModel = StateObject(wrappedValue: CandidateListViewModel(isAdmin: isAdmin))
    }
    
    var body: some View {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                
                CandidateList(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .toolbar {
                // Bouton Edit en haut à gauche
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        // Action pour le bouton Edit
                        print("Edit tapped")
                    }
                }
                
                // Bouton Étoile à droite
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action pour le bouton Étoile
                        print("Étoile tapped")
                    }) {
                        Image(systemName: "star")
                    }
                }
                
                // Bouton "+" à côté du titre
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Candidates")
                            .font(.headline)
                        if viewModel.isAdmin {
                            Button(action: { showingAddSheet = true }) {
                                Image(systemName: "plus")
                            }
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
            .navigationBarBackButtonHidden(true)
        
        .onAppear {
            Task {
                await viewModel.fetchCandidates()
            }
        }
    }
}

struct CandidateListView_Previews: PreviewProvider {
    static var previews: some View {
        CandidateListView(isAdmin: false)
    }
}
