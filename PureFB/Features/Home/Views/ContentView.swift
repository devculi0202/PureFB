import SwiftUI
import WebKit


// MARK: - Lớp bọc WKWebView
struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView { return webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Màn hình chính
struct ContentView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var isSyncing: Bool = false
    
    var body: some View {
        ZStack {
            // Background gốc của app
            Color.pureBlack.ignoresSafeArea()
            
            // 🌟 1. Giao diện Feed Tối Giản
            VStack(spacing: 0) {
                // Navigation Header: Ultra-slim, Black, Serif Font
                HStack(alignment: .bottom) {
                    Text("PureFB")
                        .font(.custom("Georgia", size: 22))
                        .foregroundColor(.offWhite)
                    
                    Spacer()
                    
                    // Syncing Indicator Dot
                    Circle()
                        .fill(Color.mutedGrey)
                        .frame(width: 5, height: 5)
                        .opacity(isSyncing ? 0.1 : 1.0)
                        .padding(.bottom, 6)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                                isSyncing.toggle()
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(Color.pureBlack)
                
                // Feed Structure: Clean, single-column scrollable
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.posts, id: \.id) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
                .refreshable {
                    viewModel.fetchPosts()
                }
            }
            
            // 🌟 2. Giao diện Đăng nhập & WebView ngầm
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("PureFB Authentication")
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(.offWhite)
                    Text("Vui lòng đăng nhập để đồng bộ dữ liệu")
                        .font(.system(size: 14))
                        .foregroundColor(.mutedGrey)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.softDarkGrey)
                
                WebViewWrapper(webView: viewModel.scraperService.webView)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color.pureBlack)
            // Logic tàng hình
            .frame(
                width: viewModel.needsLogin ? nil : 1,
                height: viewModel.needsLogin ? nil : 1
            )
            .opacity(viewModel.needsLogin ? 1 : 0)
            .offset(y: viewModel.needsLogin ? 0 : UIScreen.main.bounds.height)
            .allowsHitTesting(viewModel.needsLogin)
            .animation(.easeInOut(duration: 0.4), value: viewModel.needsLogin)
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
