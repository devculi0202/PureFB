import SwiftUI

struct PostCardView: View {
    let post: Post
    
    // Logic tự động nhận diện bài Share dựa trên nội dung
    private var isShared: Bool {
        let text = post.content.lowercased()
        return text.contains("đã chia sẻ") || text.contains("shared a link") || text.contains("shared")
    }
    
    var body: some View {
        if isShared {
            // 🔹 COMPONENT 2: Shared Post Filter Card (Faded/Dashed)
            Text("[\(post.author) đã chia sẻ một liên kết - Bị ẩn nội dung]")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.mutedGrey)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.softDarkGrey.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.mutedGrey.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        } else {
            // 🔹 COMPONENT 1: Original Post Card
            VStack(alignment: .leading, spacing: 16) {
                // Sub-header row: Tiny muted font, side-by-side
                HStack(spacing: 8) {
                    Text(post.author)
                    Text("•")
                    Text(post.timestamp)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.mutedGrey)
                .textCase(.uppercase)
                .tracking(1.0) // Tracked letter spacing
                
                // Body: Clean typography, generous line-height
                Text(post.content)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.offWhite)
                    .lineSpacing(8) // Generous 1.5x line-height
                    .fixedSize(horizontal: false, vertical: true)
                
                // Media Container: Monochrome & slightly rounded
                if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .grayscale(1.0) // Absolute monochrome constraint
                        case .empty:
                            Rectangle()
                                .fill(Color.softDarkGrey)
                                .frame(height: 250)
                                .cornerRadius(4)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
            .background(Color.softDarkGrey)
            .cornerRadius(4)
        }
    }
}
