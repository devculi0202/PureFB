import SwiftUI
import WebKit

// Lớp bọc WebView để dùng WKWebView trong thế giới SwiftUI
struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Không cần update gì thêm vì WKWebView tự quản lý trạng thái của nó
    }
}

struct ContentView: View {
    // Khởi tạo ViewModel
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Lặp qua danh sách bài viết lấy được và hiển thị
                    ForEach(viewModel.posts, id: \.id) { post in
                        PostCardView(post: post)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("PureFB")
            .navigationBarTitleDisplayMode(.inline)
            // Kéo thả làm mới (Tùy chọn thêm để sau này refresh bảng tin)
            .refreshable {
                viewModel.fetchPosts()
            }
        }
        // Hiện màn hình đăng nhập nếu ViewModel báo needsLogin = true
        .sheet(isPresented: $viewModel.needsLogin) {
            VStack(spacing: 0) {
                // Thanh tiêu đề nhỏ cho màn hình Sheet
                Text("Vui lòng đăng nhập để tiếp tục")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                
                // Hiển thị trình duyệt ngầm lên màn hình
                WebViewWrapper(webView: viewModel.scraperService.webView)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            // Tự động chạy lấy dữ liệu ở lần mở app đầu tiên
            viewModel.fetchPosts()
        }
    }
}

// Mã dành riêng cho Canvas Preview của Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
