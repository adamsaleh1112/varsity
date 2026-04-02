import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    
    enum SearchCategory: String, CaseIterable {
        case all = "All"
        case schools = "Schools"
        case teams = "Teams"
        case games = "Games"
        case players = "Players"
    }
    
    var body: some View {
        ZStack {
            Color(hex: "17171B").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Custom Search Bar (always visible, static)
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 17))
                        
                        TextField("", text: $searchText, prompt: Text("Search").foregroundColor(.gray.opacity(0.6)))
                            .font(.body)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "28282B"), lineWidth: 1)
                    )
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SearchCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedCategory == category
                                            ? Color.white
                                            : Color(hex: "28282B")
                                        )
                                        .foregroundColor(
                                            selectedCategory == category
                                            ? Color(hex: "17171B")
                                            : .white
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Recent Searches
                    if searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Recent Searches")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Clear") {
                                    // Clear recent searches
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            
                            // Placeholder recent searches
                            ForEach(["American Heritage", "St. Thomas Aquinas", "Football"], id: \.self) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.gray)
                                    
                                    Text(item)
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Trending Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Trending")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(["Championship Game", "Top Ranked Teams", "This Week's Schedule"], id: \.self) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(Color(hex: "6e27e8"))
                                        
                                        Text(item)
                                            .font(.body)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "28282B"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.top, 32)
                    } else {
                        // Search Results Placeholder
                        VStack(spacing: 40) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Searching for \"\(searchText)\" in \(selectedCategory.rawValue)...")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 0)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
