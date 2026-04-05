import SwiftUI

struct MiniGameCard: View {
    let gameData: GameCardData
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(spacing: 0) {
                // Centered date header
                HStack {
                    Spacer()
                    Text(gameData.displayDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 14)
                
                // Teams stacked vertically
                VStack(spacing: 4) {
                    // Away team row
                    HStack(spacing: 12) {
                        if let logoURL = gameData.awayTeam.logoURL {
                            AsyncImage(url: logoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            } placeholder: {
                                Circle()
                                    .fill(Color(hex: gameData.awayTeam.primaryColor) ?? Color.gray)
                                    .frame(width: 24, height: 24)
                            }
                        } else {
                            Circle()
                                .fill(Color(hex: gameData.awayTeam.primaryColor) ?? Color.gray)
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(gameData.awayTeam.abbreviation)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(gameData.awayScore != nil ? "\(gameData.awayScore!)" : "-")
                            .font(.title)
                            .fontWeight(.heavy)
                            .fontWidth(.compressed)
                            .foregroundColor(awayTeamScoreColor)
                    }
                    
                    // Home team row
                    HStack(spacing: 12) {
                        if let logoURL = gameData.homeTeam.logoURL {
                            AsyncImage(url: logoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            } placeholder: {
                                Circle()
                                    .fill(Color(hex: gameData.homeTeam.primaryColor) ?? Color.gray)
                                    .frame(width: 24, height: 24)
                            }
                        } else {
                            Circle()
                                .fill(Color(hex: gameData.homeTeam.primaryColor) ?? Color.gray)
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(gameData.homeTeam.abbreviation)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(gameData.homeScore != nil ? "\(gameData.homeScore!)" : "-")
                            .font(.title)
                            .fontWeight(.heavy)
                            .fontWidth(.compressed)
                            .foregroundColor(homeTeamScoreColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Sport tag
                HStack {
                    Spacer()
                    Text(gameData.sport.uppercased())
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .fontWidth(.compressed)
                        .foregroundColor(Color(hex: "17171B") ?? Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: UIScreen.main.bounds.width * 0.5 - 28, height: 164)
        .background(Color(hex: "28282B") ?? Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .clipped()
    }
    
    private var homeTeamScoreColor: Color {
        guard gameData.isCompleted,
              let homeScore = gameData.homeScore,
              let awayScore = gameData.awayScore else {
            return .white
        }
        return homeScore < awayScore ? .gray : .white
    }
    
    private var awayTeamScoreColor: Color {
        guard gameData.isCompleted,
              let homeScore = gameData.homeScore,
              let awayScore = gameData.awayScore else {
            return .white
        }
        return awayScore < homeScore ? .gray : .white
    }
}

#Preview {
    MiniGameCard(gameData: GameCardData(
        id: UUID(),
        homeTeam: TeamInfo(
            id: UUID(),
            name: "Home Team",
            abbreviation: "HOME",
            logoURL: nil,
            primaryColor: "6e27e8",
            sport: "Football",
            state: "CA"
        ),
        awayTeam: TeamInfo(
            id: UUID(),
            name: "Away Team",
            abbreviation: "AWAY",
            logoURL: nil,
            primaryColor: "e8276e",
            sport: "Football",
            state: "NY"
        ),
        gameDate: "Today",
        startTime: nil,
        homeScore: 21,
        awayScore: 14,
        sport: "Football",
        isCompleted: true
    ))
}
