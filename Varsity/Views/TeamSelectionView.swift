import SwiftUI

struct TeamSelectionView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var followedTeams: Set<UUID> = []
    @State private var availableSchools: [School] = []
    @State private var filteredSchools: [School] = []
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search schools...", text: $searchText)
                            .foregroundColor(.white)
                            .onChange(of: searchText) {
                                filterSchools()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                filterSchools()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "28282B"))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Schools List
                    if isLoading {
                        ProgressView("Loading schools...")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredSchools.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Schools Found")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Try adjusting your search terms.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if availableSchools.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "graduationcap")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Schools Available")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Schools will appear here once they're added to the system.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredSchools) { school in
                                    TeamRowView(
                                        school: school,
                                        isFollowed: followedTeams.contains(school.id),
                                        onToggle: {
                                            toggleTeamFollow(school: school)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationTitle("Manage Following")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                loadTeamsAndFollowing()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func loadTeamsAndFollowing() {
        isLoading = true
        
        Task {
            await loadSchoolsFromDatabase()
            await loadFollowedSchools()
        }
    }
    
    private func loadSchoolsFromDatabase() async {
        // Use mock data for now
        await MainActor.run {
            availableSchools = [
                School(id: UUID(), name: "University of California", shortName: "UC Berkeley", city: "Berkeley", state: "CA", mascot: "Golden Bears", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "Stanford University", shortName: "Stanford", city: "Stanford", state: "CA", mascot: "Cardinal", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "UCLA", shortName: "UCLA", city: "Los Angeles", state: "CA", mascot: "Bruins", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "USC", shortName: "USC", city: "Los Angeles", state: "CA", mascot: "Trojans", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "San Jose State", shortName: "SJSU", city: "San Jose", state: "CA", mascot: "Spartans", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "California State University", shortName: "Cal State", city: "Sacramento", state: "CA", mascot: "Hornets", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none),
                School(id: UUID(), name: "University of Southern California", shortName: "USC", city: "Los Angeles", state: "CA", mascot: "Trojans", primaryColor: Optional<String>.none, secondaryColor: Optional<String>.none, logoPath: Optional<String>.none)
            ]
            filteredSchools = availableSchools
            isLoading = false
        }
    }
    
    private func loadFollowedSchools() async {
        // Mock followed schools - first school is followed by default
        await MainActor.run {
            followedTeams = Set([availableSchools.first?.id].compactMap { $0 })
        }
    }
    
    private func filterSchools() {
        if searchText.isEmpty {
            filteredSchools = availableSchools
        } else {
            filteredSchools = availableSchools.filter { school in
                school.name.localizedCaseInsensitiveContains(searchText) ||
                (school.city?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (school.state?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (school.shortName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    private func toggleTeamFollow(school: School) {
        // Simple toggle for mock data
        if followedTeams.contains(school.id) {
            followedTeams.remove(school.id)
        } else {
            followedTeams.insert(school.id)
        }
    }
}

struct TeamRowView: View {
    let school: School
    let isFollowed: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // School Logo
            AsyncImage(url: URL(string: school.logoPath ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(String(school.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // School Info
            VStack(alignment: .leading, spacing: 4) {
                Text(school.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(school.city ?? ""), \(school.state ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Follow Button
            Button(action: onToggle) {
                Text(isFollowed ? "Following" : "Follow")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isFollowed ? .white : Color(hex: "6e27e8"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isFollowed ? Color(hex: "6e27e8") : Color.clear)
                            .stroke(Color(hex: "6e27e8"), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color(hex: "28282B"))
        .cornerRadius(12)
    }
}

// Using existing School model from Models/School.swift

#Preview {
    TeamSelectionView()
}
