import SwiftUI

struct VarsityMeView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var showingEditProfile = false
    @State private var showingTeamSelection = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(hex: "17171B").ignoresSafeArea()
                    
                    // Subtle pink/blue gradient at top
                    VStack {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.blue.opacity(0.2), location: 0.0),
                                .init(color: Color.pink.opacity(0.2), location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 180)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Me")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .fontWidth(.expanded)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack {
                                Text("District")
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Profile Content
                        ScrollView {
                            VStack(spacing: 24) {
                                // Profile Header
                                VStack(spacing: 16) {
                                    // Profile Picture
                                    AsyncImage(url: URL(string: authManager.currentUser?.avatarUrl ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    
                                    // User Info
                                    VStack(spacing: 8) {
                                        Text(authManager.currentUser?.displayName ?? authManager.currentUser?.username ?? "User")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text("@\(authManager.currentUser?.username ?? "")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        if let bio = authManager.currentUser?.bio, !bio.isEmpty {
                                            Text(bio)
                                                .font(.body)
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 20)
                                        }
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Action Buttons
                                VStack(spacing: 12) {
                                    // Side by side buttons
                                    HStack(spacing: 12) {
                                        // Edit Profile Button
                                        Button(action: {
                                            showingEditProfile = true
                                        }) {
                                            HStack {
                                                Image(systemName: "person.crop.circle")
                                                Text("Edit Profile")
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(Color(hex: "6e27e8"))
                                            .cornerRadius(12)
                                        }
                                        
                                        // Manage Teams Button
                                        Button(action: {
                                            showingTeamSelection = true
                                        }) {
                                            HStack {
                                                Image(systemName: "graduationcap")
                                                Text("Schools")
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(Color(hex: "28282B"))
                                            .cornerRadius(12)
                                        }
                                    }
                                    
                                    // Sign Out Button
                                    Button(action: {
                                        Task {
                                            await authManager.signOut()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                            Text("Sign Out")
                                        }
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                Spacer(minLength: 100)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingTeamSelection) {
            TeamSelectionView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    VarsityMeView()
}

