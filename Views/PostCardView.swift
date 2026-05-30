import SwiftUI

struct PostCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                
                Text(post.author)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()

                Text(post.timePosted)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(post.content)
                .font(.body)
            if let imageUrl = post.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(post: Post(author: "John Doe", timePosted: "1 hour ago", content: "This is a sample post with #hashtag.", imageUrl: nil))
    }
}
