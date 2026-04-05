import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var selectedTab: TabItem = .home
    @Published var selectedGameForDetail: GameCardData? = nil
}

enum TabItem: String, CaseIterable {
    case home = "Home"
    case games = "Games"
    case profile = "Profile"
    case search = "Search"
}
