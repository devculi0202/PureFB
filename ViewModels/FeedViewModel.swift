import Foundation
import SwiftUI

// Định nghĩa struct Post để lưu trữ thông tin bài viết
struct Post: Identifiable, Codable {
    let id = UUID()
    var text: String?
    var imageUrl: String?
    var timestamp: String?
}

// Tạo class FeedViewModel tuân thủ ObservableObject
class FeedViewModel: ObservableObject {
    // Khai báo các biến @Published
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    
    // Mảng whitelistURLs chứa các URL trang cá nhân Facebook cần theo dõi
    let whitelistURLs: [String] = [
        "https://www.facebook.com/user1",
        "https://www.facebook.com/user2",
        "https://www.facebook.com/user3"
    ]
    
    // Khai báo đối tượng FacebookScraperService
    private var scraperService: FacebookScraperService
    
    init(scraperService: FacebookScraperService) {
        self.scraperService = scraperService
        fetchPosts()
    }
    
    // Simulate network request
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let jsonData = """
        [
            {
                "text": "This is a sample post with #hashtag.",
                "imageUrl": null,
                "timestamp": "1 hour ago"
            },
            {
                "text": "Another post with more details.",
                "imageUrl": "https://example.com/image.jpg",
                "timestamp": "2 hours ago"
            }
        ]
        """.data(using: .utf8)!
        
        do {
            let decodedPosts = try JSONDecoder().decode([Post].self, from: jsonData)
            self.posts = decodedPosts
            self.isLoading = false
        } catch {
            print("Error decoding posts: \(error)")
            self.isLoading = false
        }
    }
}
