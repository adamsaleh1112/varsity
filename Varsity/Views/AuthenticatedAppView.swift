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
    
    var body: some View {
        TabView {
            VarsityHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            VarsityGamesView()
                .tabItem {
                    Image(systemName: "sportscourt.fill")
                    Text("Games")
                }
            
            VarsityMeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
        }
        .accentColor(.white)
    }
}

#Preview {
    AuthenticatedAppView()
}
