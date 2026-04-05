import SwiftUI

struct GameDetailView: View {
    let gameCard: GameCardData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                // Gradient from top using both schools' colors
                VStack {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: gameCard.homeTeam.primaryColor).opacity(0.5), location: 0.0),
                            .init(color: Color(hex: gameCard.awayTeam.primaryColor).opacity(0.5), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 280)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Game Header with teams and scores - Reference image style
                        HStack(alignment: .center, spacing: 0) {
                            // Home Team (Left)
                            VStack(spacing: 12) {
                                AsyncImage(url: gameCard.homeTeam.logoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                } placeholder: {
                                    Circle()
                                        .fill(Color(hex: gameCard.homeTeam.primaryColor) ?? Color.gray)
                                        .frame(width: 80, height: 80)
                                }
                                
                                // Abbreviation with state greyed out
                                HStack(spacing: 4) {
                                    Text(gameCard.homeTeam.abbreviation)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if let state = gameCard.homeTeam.state {
                                        Text(state)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Score section (Center)
                            VStack(spacing: 8) {
                                if gameCard.isCompleted {
                                    HStack(spacing: 16) {
                                        Text("\(gameCard.homeScore ?? 0)")
                                            .font(.system(size: 60))
                                            .fontWeight(.heavy)
                                            .fontWidth(.compressed)
                                            .foregroundColor(homeTeamScoreColor())
                                        
                                        Text("-")
                                            .font(.system(size: 40))
                                            .fontWeight(.heavy)
                                            .foregroundColor(.gray)
                                        
                                        Text("\(gameCard.awayScore ?? 0)")
                                            .font(.system(size: 60))
                                            .fontWeight(.heavy)
                                            .fontWidth(.compressed)
                                            .foregroundColor(awayTeamScoreColor())
                                    }
                                } else {
                                    Text("VS")
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.gray)
                                        .fontWidth(.compressed)
                                }
                                
                                // FINAL at bottom (expanded, greyed out)
                                if gameCard.isCompleted {
                                    Text("FINAL")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontWidth(.expanded)
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .layoutPriority(1)
                            
                            // Away Team (Right)
                            VStack(spacing: 12) {
                                AsyncImage(url: gameCard.awayTeam.logoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                } placeholder: {
                                    Circle()
                                        .fill(Color(hex: gameCard.awayTeam.primaryColor) ?? Color.gray)
                                        .frame(width: 80, height: 80)
                                }
                                
                                // Abbreviation with state greyed out
                                HStack(spacing: 4) {
                                    Text(gameCard.awayTeam.abbreviation)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if let state = gameCard.awayTeam.state {
                                        Text(state)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Game Info Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(hex: "ffffff"))
                                Text(gameCard.gameDate)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "sportscourt")
                                    .foregroundColor(Color(hex: "ffffff"))
                                Text(gameCard.sport)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "28282B"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        
                        // Placeholder for more stats
                        VStack(spacing: 12) {
                            Text("Game Stats")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Detailed stats coming soon...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Game Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func homeTeamScoreColor() -> Color {
        guard gameCard.isCompleted,
              let homeScore = gameCard.homeScore,
              let awayScore = gameCard.awayScore else {
            return .white
        }
        
        if homeScore < awayScore {
            return .gray
        }
        return .white
    }
    
    private func awayTeamScoreColor() -> Color {
        guard gameCard.isCompleted,
              let homeScore = gameCard.homeScore,
              let awayScore = gameCard.awayScore else {
            return .white
        }
        
        if awayScore < homeScore {
            return .gray
        }
        return .white
    }
}
