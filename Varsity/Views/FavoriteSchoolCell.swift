import SwiftUI

struct FavoriteSchoolCell: View {
    let school: School
    
    private var logoURL: URL? {
        SportsDataService().publicImageURL(bucket: "school-assets", path: school.logoPath)
    }
    
    var body: some View {
        VStack(spacing: 7) {
            // School Logo
            AsyncImage(url: logoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: school.primaryColor ?? "333333") ?? Color.gray)
                    .overlay(
                        Text(school.shortName ?? String(school.name.prefix(2)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.top, 4)
            
            // School Abbreviation and State
            HStack(spacing: 4) {
                Text(school.shortName ?? String(school.name.prefix(3)).uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(school.state ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.bottom, 6)
        }
        .frame(width: 80, height: 80)
        .background(Color(hex: "18181B") ?? Color.gray)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "28282B") ?? Color.gray, lineWidth: 1)
        )
    }
}

#Preview {
    // Preview requires actual School data from database
    FavoriteSchoolCell(school: School(
        id: UUID(),
        name: "",
        shortName: "",
        city: "",
        state: "",
        mascot: "",
        primaryColor: nil,
        secondaryColor: nil,
        logoPath: nil
    ))
}
