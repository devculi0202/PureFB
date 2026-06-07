import Foundation
import Foundation
import WebKit
import Combine

class FacebookScraperService: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    // MARK: - Core Components
    let webView: WKWebView
    
    // Đường ống truyền dữ liệu mảng [Post] về ViewModel dựa trên struct Post bạn đã define
    let postsPublisher = PassthroughSubject<[Post], Never>()
    
    @Published var needsLogin: Bool = false
    
    // MARK: - Biến lưu trữ hàng đợi URL
    private var targetURLs: [URL] = []
    private var currentURLIndex = 0
    
    // MARK: - Initializer
    override init() {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        super.init()
        
        // Cấu hình Delegate và đăng ký cầu nối tin nhắn giữa JavaScript và Swift
        contentController.add(self, name: AppConstants.JavaScript.bridgeName)
        self.webView.navigationDelegate = self
        
        // Giả dạng User Agent của iPhone Safari để ép Facebook trả về đúng cấu trúc SPA di động
        self.webView.customUserAgent = AppConstants.JavaScript.userAgent
        
        // Nạp trang chủ Facebook di động để kiểm tra trạng thái Session/Cookie
        if let url = URL(string: AppConstants.URLs.facebookMobile) {
            let request = URLRequest(url: url)
            webView.load(request)
            print("🚀 [Service] Khởi tạo WebView thành công với User-Agent cải trang.")
        }
    }
    
    // MARK: - 🔄 URL Queue Management (Điều phối vòng lặp gọi từ ViewModel)
    func startScraping(urls: [URL]) {
        guard !urls.isEmpty else { return }
        self.targetURLs = urls
        self.currentURLIndex = 0
        loadNextURL()
    }
    
    private func loadNextURL() {
        guard currentURLIndex < targetURLs.count else {
            print("🏁 [Service] Đã duyệt qua toàn bộ danh sách URL mục tiêu.")
            return
        }
        let request = URLRequest(url: targetURLs[currentURLIndex])
        webView.load(request)
        print("🔄 [Service] WebView đang tải URL mục tiêu (\(currentURLIndex + 1)/\(targetURLs.count)): \(targetURLs[currentURLIndex].absoluteString)")
    }
    
    // MARK: - WKNavigationDelegate
    // MARK: - WKNavigationDelegate
    // MARK: - WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let urlString = webView.url?.absoluteString else { return }
            print("🔍 [DEBUG] WebView tải xong cấu trúc URL: \(urlString)")
            
            // Trì hoãn để chờ nội dung trang web render ổn định
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Scraping.pageLoadDelay) { [weak self] in
                guard let self = self else { return }
                
                let checkLoginJS = """
                (function() {
                    // 1. Kiểm tra dấu hiệu bắt buộc của trang Đăng nhập (Có ô nhập Password)
                    let hasPassInput = document.querySelector('input[name="pass"], input[type="password"]') != null;
                    
                    // 2. Kiểm tra dấu hiệu trang chặn Checkpoint danh tính hoặc 2FA thực sự
                    let isCheckpoint = window.location.href.includes("checkpoint") || 
                                       window.location.href.includes("/two_factor") ||
                                       window.location.href.includes("/co/checkpoint");
                                       
                    let hasOtpField = document.querySelector('input[name="approvals_code"]') != null;

                    // 🌟 SỬA SAI: Loại bỏ hoàn toàn điều kiện '!hasNewsFeed'. 
                    // Chỉ bắt bật màn hình đăng nhập khi thực sự đụng hàng rào mật khẩu hoặc checkpoint bảo mật.
                    if (hasPassInput || isCheckpoint || hasOtpField) {
                        return "IS_LOGIN_PAGE"; 
                    } else {
                        return "LOGGED_IN"; // Các trang Fanpage công khai hoặc dòng thời gian đều coi là hợp lệ
                    }
                })();
                """
                
                self.webView.evaluateJavaScript(checkLoginJS) { (result, error) in
                    DispatchQueue.main.async {
                        let resString = (result as? String) ?? ""
                        if resString == "IS_LOGIN_PAGE" {
                            print("🚨 [DEBUG] Đụng hàng rào bảo mật thực tế -> Bật màn hình WebView bắt buộc người dùng tương tác.")
                            self.needsLogin = true
                        } else {
                            print("✅ [DEBUG] Vượt qua trạm kiểm soát -> Tiến hành ẩn WebView và thả radar bắt bài viết.")
                            self.needsLogin = false
                            self.injectGraphQLRadar() // Kích hoạt mũi khoan đánh chặn luồng mạng
                        }
                    }
                }
            }
        }
    
    // MARK: - JavaScript Network Radar Interception
    private func injectGraphQLRadar() {
        // Prepare constants for JS injection
        let logPrefix = AppConstants.JavaScript.logPrefix
        let dataPrefix = AppConstants.JavaScript.dataPrefix
        let minContentLength = AppConstants.Scraping.minContentLength
        let maxContentPreview = AppConstants.Scraping.maxContentPreview
        let autoScrollCount = AppConstants.Scraping.autoScrollCount
        let scrollInterval = Int(AppConstants.Scraping.scrollInterval * 1000) // Convert to milliseconds
        let domScanDelay = Int(AppConstants.Scraping.domScanDelay * 1000)
        let initialScanDelay = AppConstants.Scraping.initialScanDelay
        
        // Build filter keywords array for JavaScript
        let filterKeywordsJS = AppConstants.ContentFilter.filterOutKeywords
            .map { "'\($0)'" }
            .joined(separator: ", ")
        
        // Post selectors
        let postSelectors = AppConstants.ContentFilter.postSelectors
        let fallbackSelector = AppConstants.ContentFilter.fallbackPostSelector
        
        // Post metadata
        let domAuthor = AppConstants.Post.defaultDOMAuthor
        let gqlAuthor = AppConstants.Post.defaultGraphQLAuthor
        let freshTimestamp = AppConstants.Post.freshTimestamp
        let updatedTimestamp = AppConstants.Post.updatedTimestamp
        let domIDPrefix = AppConstants.Post.domIDPrefix
        let gqlIDPrefix = AppConstants.Post.graphQLIDPrefix
        
        let jsCode = """
        (function() {
            function sendLog(msg) {
                window.webkit?.messageHandlers?.purefb_bridge?.postMessage("\(logPrefix)" + msg);
            }
            function sendData(data) {
                window.webkit?.messageHandlers?.purefb_bridge?.postMessage("\(dataPrefix)" + data);
            }

            if (window.pureFBRadarInjected) {
                sendLog("⚠️ Radar đã hoạt động trên trang này, bỏ qua lượt tiêm.");
                return;
            }
            window.pureFBRadarInjected = true;

            sendLog("📡 KÍCH HOẠT RADAR TOÀN DIỆN (Fetch Hook + Auto-Scroll + DOM Fallback)...");

            // --- CONSTANTS ---
            const MIN_CONTENT_LENGTH = \(minContentLength);
            const MAX_CONTENT_PREVIEW = \(maxContentPreview);
            const FILTER_KEYWORDS = [\(filterKeywordsJS)];
            const POST_SELECTORS = "\(postSelectors)";
            const FALLBACK_SELECTOR = "\(fallbackSelector)";
            const DOM_AUTHOR = "\(domAuthor)";
            const GQL_AUTHOR = "\(gqlAuthor)";
            const FRESH_TIMESTAMP = "\(freshTimestamp)";
            const UPDATED_TIMESTAMP = "\(updatedTimestamp)";
            const DOM_ID_PREFIX = "\(domIDPrefix)";
            const GQL_ID_PREFIX = "\(gqlIDPrefix)";
            
            // --- TRẠM 1: BỘ QUÉT DỮ LIỆU DOM ---
            function scanExistingDOM() {
                try {
                    let postsFound = [];
                    let elements = document.querySelectorAll(POST_SELECTORS);
                    
                    if (elements.length === 0) {
                        elements = document.querySelectorAll(FALLBACK_SELECTOR);
                    }
                    
                    elements.forEach((el) => {
                        let textContent = el.innerText || "";
                        if (textContent.length > MIN_CONTENT_LENGTH) {
                            let shouldFilter = false;
                            FILTER_KEYWORDS.forEach(keyword => {
                                if (textContent.includes(keyword)) shouldFilter = true;
                            });
                            
                            if (!shouldFilter) {
                                let cleanContent = textContent.trim().substring(0, MAX_CONTENT_PREVIEW);
                                postsFound.push({
                                    "id": DOM_ID_PREFIX + Math.random().toString(36).substr(2, 9),
                                    "author": DOM_AUTHOR,
                                    "content": cleanContent,
                                    "imageUrl": null,
                                    "timestamp": FRESH_TIMESTAMP
                                });
                            }
                        }
                    });

                    if (postsFound.length > 0) {
                        sendLog("📊 [DOM Scan] Thu hoạch được " + postsFound.length + " bài viết!");
                        sendData(JSON.stringify(postsFound));
                    }
                } catch (e) {
                    sendLog("❌ Lỗi quét DOM: " + e.message);
                }
            }

            // Chạy quét ngay lập tức
            setTimeout(scanExistingDOM, \(initialScanDelay));

            // --- TRẠM 2: ĐÁNH CHẶN GRAPHQL ---
            function parseFacebookGraphQL(rawText) {
                try {
                    let postsFound = [];
                    let cleanText = rawText.replace(/\\n/g, " ");
                    let matches = cleanText.match(/"message":\\s*{"text":\\s*"([^"]+)"}/g);
                    
                    if (matches) {
                        matches.forEach((item) => {
                            let textMatch = item.match(/"text":\\s*"([^"]+)"/);
                            if (textMatch && textMatch[1]) {
                                let rawContent = textMatch[1];
                                let cleanContent = rawContent
                                    .replace(/\\\\u003C/g, "<")
                                    .replace(/\\\\u003E/g, ">")
                                    .replace(/\\\\/g, "");
                                    
                                postsFound.push({
                                    "id": GQL_ID_PREFIX + Math.random().toString(36).substr(2, 9),
                                    "author": GQL_AUTHOR,
                                    "content": cleanContent,
                                    "imageUrl": null,
                                    "timestamp": UPDATED_TIMESTAMP
                                });
                            }
                        });
                    }
                    return postsFound;
                } catch(e) {
                    return [];
                }
            }

            // Đánh chặn Fetch API
            const originalFetch = window.fetch;
            window.fetch = async function(...args) {
                const response = await originalFetch.apply(this, args);
                const url = args[0];
                
                if (typeof url === 'string' && (url.includes('graphql') || url.includes('api') || url.includes('bz'))) {
                    response.clone().text().then(text => {
                        let parsed = parseFacebookGraphQL(text);
                        if (parsed.length > 0) {
                            sendLog("📥 [Fetch Hook] Lọc được " + parsed.length + " bài viết GraphQL!");
                            sendData(JSON.stringify(parsed));
                        }
                    }).catch(err => {});
                }
                return response;
            };

            // --- TRẠM 3: AUTO-SCROLL ---
            const AUTO_SCROLL_COUNT = \(autoScrollCount);
            const SCROLL_INTERVAL = \(scrollInterval);
            const DOM_SCAN_DELAY = \(domScanDelay);
            
            let scrollCount = 0;
            let scrollInterval = setInterval(function() {
                if (scrollCount >= AUTO_SCROLL_COUNT) {
                    clearInterval(scrollInterval);
                    sendLog("🏁 [Auto-Scroll] Hoàn thành chu kỳ cuộn trang.");
                    return;
                }
                
                window.scrollTo(0, document.body.scrollHeight);
                scrollCount++;
                sendLog("🔄 [Auto-Scroll] Lần " + scrollCount + "/" + AUTO_SCROLL_COUNT);
                setTimeout(scanExistingDOM, DOM_SCAN_DELAY);
            }, SCROLL_INTERVAL);

        })();
        """
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }
    
    // MARK: - WKScriptMessageHandler (Trạm tiếp nhận và xử lý dữ liệu từ JS đổ bộ về Swift)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? String else { return }
        
        if messageBody.hasPrefix(AppConstants.JavaScript.logPrefix) {
            let log = messageBody.replacingOccurrences(of: AppConstants.JavaScript.logPrefix, with: "")
            print("🌐 [JS Radar Log]: \(log)")
        }
        else if messageBody.hasPrefix(AppConstants.JavaScript.dataPrefix) {
            let jsonString = messageBody.replacingOccurrences(of: AppConstants.JavaScript.dataPrefix, with: "")
            print("📥 [Swift Core]: Tiếp nhận gói bài viết từ JavaScript.")
            
            // 🛠️ SỬA LỖI CHÍ MẠNG: Chuyển đổi chuỗi thành Data và dùng đúng cú pháp decode(_:from:)
            guard let data = jsonString.data(using: .utf8) else {
                print("❌ [Lỗi]: Không thể convert chuỗi JSON sang đối tượng Data.")
                return
            }
            
            do {
                // Sửa chính xác từ (..., family: nil) thành (..., from: data)
                let incomingPosts = try JSONDecoder().decode([Post].self, from: data)
                
                if !incomingPosts.isEmpty {
                    print("🚀 [Swift Core]: Giải mã thành công \(incomingPosts.count) bài viết. Tiến hành bơm dữ liệu về ViewModel!")
                    // Phát tín hiệu truyền mảng bài viết sang cho FeedViewModel hiển thị
                    self.postsPublisher.send(incomingPosts)
                }
            } catch {
                print("❌ [Lỗi giải mã JSON]: \(error.localizedDescription)")
                // In thêm dòng này để dễ debug cấu trúc nếu Facebook thay đổi trường dữ liệu
                print("📌 JSON lỗi nhận được: \(jsonString)")
            }
            
            // Tịnh tiến hàng đợi để tự động chuyển sang cào URL tiếp theo trong danh sách Whitelist
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentURLIndex += 1
                self.loadNextURL()
            }
        }
    }
}
