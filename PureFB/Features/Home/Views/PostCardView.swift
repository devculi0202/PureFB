import SwiftUI

struct PostCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Metadata: Phân cấp rõ ràng bằng System Colors
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(post.author)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(post.timestamp)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            // Body Text: Kéo giãn để tạo khoảng không gian thở
            Text(post.content)
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(7) // Tạo độ giãn dòng chuẩn tạp chí
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Media Container: Bo góc mịn đồng điệu phần cứng iPhone
            if let imageUrl = post.imageUrl {
                Image(imageUrl) // Sẽ gọi ảnh thật trong asset
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
    }
}
