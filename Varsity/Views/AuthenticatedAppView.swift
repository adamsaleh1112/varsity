import SwiftUI

struct AuthenticatedAppView: View {
    @StateObject private var authManager = SimpleAuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainAppView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            // SimpleAuthManager doesn't need checkAuthenticationStatus - it starts unauthenticated
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Games", systemImage: "sportscourt.fill") {
                GamesView()
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
            }
            
            // Dedicated Search Tab (separate on the right)
            Tab(role: .search) {
                NavigationStack {
                    SearchView()
                }
            }
        }
        .accentColor(.white)
    }
}

#Preview {
    AuthenticatedAppView()
}
