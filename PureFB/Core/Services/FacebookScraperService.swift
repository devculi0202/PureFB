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
        contentController.add(self, name: "purefb_bridge")
        self.webView.navigationDelegate = self
        
        // Giả dạng User Agent của iPhone Safari để ép Facebook trả về đúng cấu trúc SPA di động
        self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
        
        // Nạp trang chủ Facebook di động để kiểm tra trạng thái Session/Cookie
        if let url = URL(string: "https://m.facebook.com") {
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
            
            // Trì hoãn 3 giây chờ nội dung trang web render ổn định
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
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
            let jsCode = """
            (function() {
                function sendLog(msg) {
                    window.webkit?.messageHandlers?.purefb_bridge?.postMessage("LOG: " + msg);
                }
                function sendData(data) {
                    window.webkit?.messageHandlers?.purefb_bridge?.postMessage("DATA: " + data);
                }

                if (window.pureFBRadarInjected) {
                    sendLog("⚠️ Radar đã hoạt động trên trang này, bỏ qua lượt tiêm.");
                    return;
                }
                window.pureFBRadarInjected = true;

                sendLog("📡 KÍCH HOẠT LÕIRadar TOÀN DIỆN (Fetch Hook + Auto-Scroll + DOM Fallback)...");

                // --- TRẠM 1: BỘ QUÉT CẠN DỮ LIỆU CÓ SẴN TRÊN TRANG (DOM FALLBACK) ---
                // Giúp lấy ngay dữ liệu trang đầu tiên mà không cần chờ request mạng phát sinh
                function scanExistingDOM() {
                    try {
                        let postsFound = [];
                        // Trên m.facebook.com, các bài viết thường nằm trong các thẻ article hoặc thẻ div có thuộc tính data-ft
                        let elements = document.querySelectorAll('article, [data-ft], [data-story-id]');
                        
                        if (elements.length === 0) {
                            // Lưới quét dự phòng nếu Facebook đổi thẻ: quét tất cả các block text lớn
                            elements = document.querySelectorAll('div > div > span');
                        }

                        elements.forEach((el) => {
                            let textContent = el.innerText || "";
                            if (textContent.length > 30 && !textContent.includes("Vui lòng đăng nhập")) {
                                // Lọc bỏ rác, lấy nội dung text sạch
                                let cleanContent = textContent.trim().substring(0, 500);
                                postsFound.push({
                                    "id": "dom_" + Math.random().toString(36).substr(2, 9),
                                    "author": "Facebook Publisher",
                                    "content": cleanContent,
                                    "imageUrl": null,
                                    "timestamp": "Tin mới nhận"
                                });
                            }
                        });

                        if (postsFound.length > 0) {
                            sendLog("📊 [DOM Scan] Thu hoạch sớm được " + postsFound.length + " bài viết tĩnh!");
                            sendData(JSON.stringify(postsFound));
                        }
                    } catch (e) {
                        sendLog("❌ Lỗi quét DOM Tĩnh: " + e.message);
                    }
                }

                // Chạy quét thử ngay lập tức một lần
                setTimeout(scanExistingDOM, 1000);

                // --- TRẠM 2: ĐÁNH CHẶN LUỒNG MẠNG GRAPHQL VÀ SƠ CẤP HÓA CẤU TRÚC JSON ---
                function parseFacebookGraphQL(rawText) {
                    try {
                        let postsFound = [];
                        let cleanText = rawText.replace(/\\n/g, " ");
                        
                        // Regex vây bắt trường text bài viết đặc trưng trong luồng JSON GraphQL
                        let matches = cleanText.match(/"message":\\s*{"text":\\s*"([^"]+)"}/g);
                        if (matches) {
                            matches.forEach((item) => {
                                let textMatch = item.match(/"text":\\s*"([^"]+)"/);
                                if (textMatch && textMatch[1]) {
                                    let rawContent = textMatch[1];
                                    // Giải mã ký tự unicode tránh lỗi hiển thị tiếng Việt
                                    let cleanContent = rawContent
                                        .replace(/\\\\u003C/g, "<")
                                        .replace(/\\\\u003E/g, ">")
                                        .replace(/\\\\/g, "");
                                        
                                    postsFound.push({
                                        "id": "gql_" + Math.random().toString(36).substr(2, 9),
                                        "author": "Chính chủ Facebook",
                                        "content": cleanContent,
                                        "imageUrl": null,
                                        "timestamp": "Vừa cập nhật"
                                    });
                                }
                            });
                        }
                        return postsFound;
                    } catch(e) {
                        return [];
                    }
                }

                // Đánh chặn luồng Fetch API gốc
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

                // --- TRẠM 3: HỆ THỐNG KÍCH HOẠT AUTO-SCROLL NGẦM TỰ ĐỘNG ---
                // Vòng lặp kích thích Facebook liên tục tải dữ liệu mới
                let scrollCount = 0;
                let scrollInterval = setInterval(function() {
                    if (scrollCount >= 6) { // Quét tự động cuộn 6 lần liên tục để lấy đủ bài rồi dừng để tránh quá tải
                        clearInterval(scrollInterval);
                        sendLog("🏁 [Auto-Scroll] Hoàn thành chu kỳ cuộn trang kích thích mạng.");
                        return;
                    }
                    
                    // Cuộn xuống đáy trang hiện tại
                    window.scrollTo(0, document.body.scrollHeight);
                    scrollCount++;
                    sendLog("🔄 [Auto-Scroll] Đang cuộn trình duyệt ngầm lần thứ (" + scrollCount + "/6)...");
                    
                    // Sau khi cuộn, quét lại DOM tĩnh đề phòng
                    setTimeout(scanExistingDOM, 800);
                }, 2000); // Cứ mỗi 2 giây cuộn một lần

            })();
            """
            webView.evaluateJavaScript(jsCode, completionHandler: nil)
        }
    
    // MARK: - WKScriptMessageHandler (Trạm tiếp nhận và xử lý dữ liệu từ JS đổ bộ về Swift)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? String else { return }
        
        if messageBody.hasPrefix("LOG: ") {
            let log = messageBody.replacingOccurrences(of: "LOG: ", with: "")
            print("🌐 [JS Radar Log]: \(log)")
        }
        else if messageBody.hasPrefix("DATA: ") {
            let jsonString = messageBody.replacingOccurrences(of: "DATA: ", with: "")
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
