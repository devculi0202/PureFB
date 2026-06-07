import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    // Thêm biến này để làm trạm trung chuyển báo cho View
    @Published var needsLogin: Bool = false
    
    let scraperService: FacebookScraperService // Bỏ chữ private đi nếu có
    private var cancellables = Set<AnyCancellable>()
    
    init(scraperService: FacebookScraperService = FacebookScraperService()) {
        self.scraperService = scraperService
        setupBindings()
    }
    
    private func setupBindings() {
        // Lắng nghe dữ liệu bài viết
        scraperService.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scrapedPosts in
                self?.posts = scrapedPosts
            }
            .store(in: &cancellables)
            
        // Lắng nghe yêu cầu đăng nhập từ Service
        scraperService.$needsLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoginRequired in
                self?.needsLogin = isLoginRequired
            }
            .store(in: &cancellables)
    }
    
    func fetchPosts() {
            // 🌟 Nạp danh sách các URL trang cá nhân bạn muốn lấy bài viết vào đây
            // Tránh nạp m.facebook.com trống vì nó không sinh luồng GraphQL bài viết cá nhân ổn định
            let targetURLs = [
                URL(string: "https://m.facebook.com/vietnamnet.vn")!, // Ví dụ trang tin tức sử dụng m.fb
                URL(string: "https://m.facebook.com/tinhte")!
            ]
            print("🔄 [ViewModel] Bắt đầu kích hoạt chuỗi cào dữ liệu cho \(targetURLs.count) mục tiêu...")
            scraperService.startScraping(urls: targetURLs)
        }
}
