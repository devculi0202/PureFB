import Foundation
import WebKit
import Combine

class FacebookScraperService: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    // Để public để View có thể lấy ra hiển thị lúc đăng nhập
    let webView: WKWebView
    
    let postsPublisher = PassthroughSubject<[Post], Never>()
    
    // Báo cho UI biết có cần hiện màn hình đăng nhập không
    @Published var needsLogin: Bool = false
    
    private var targetURLs: [URL] = []
    private var currentURLIndex = 0
    
    override init() {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        
        contentController.add(self, name: "purefb_bridge")
        self.webView.navigationDelegate = self
        
        // Mở sẵn trang chủ m.facebook.com để kiểm tra trạng thái
        if let url = URL(string: "https://m.facebook.com") {
            webView.load(URLRequest(url: url))
        }
    }
    
    // Theo dõi mọi sự thay đổi URL của WebView
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentURL = webView.url?.absoluteString else { return }
        
        // Nếu bị đẩy ra màn hình login hoặc checkpoint
        if currentURL.contains("login") || currentURL.contains("checkpoint") {
            DispatchQueue.main.async {
                self.needsLogin = true
            }
        }
        // Nếu đang ở trang chủ hoặc trang cá nhân (Đã login thành công)
        else {
            DispatchQueue.main.async {
                if self.needsLogin {
                    self.needsLogin = false // Tắt màn hình đăng nhập
                }
            }
            // Chỉ bắt đầu cào dữ liệu khi KHÔNG ở trang login
            injectJavaScript()
        }
    }
    
    func startScraping(urls: [URL]) {
        guard !urls.isEmpty else { return }
        self.targetURLs = urls
        self.currentURLIndex = 0
        loadNextURL()
    }
    
    private func loadNextURL() {
        guard currentURLIndex < targetURLs.count else { return }
        let request = URLRequest(url: targetURLs[currentURLIndex])
        webView.load(request)
    }
    
    private func injectJavaScript() {
        // ... (Giữ nguyên đoạn mã JavaScript cũ của bạn ở đây) ...
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // ... (Giữ nguyên đoạn parse JSON cũ của bạn ở đây) ...
    }
}
