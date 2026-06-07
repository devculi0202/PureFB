import Foundation
import SwiftUI
import WebKit

// MARK: - Màn hình chính
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: FeedViewModel?
    @State private var isSyncing: Bool = false
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                ContentViewInternal(viewModel: viewModel, isSyncing: $isSyncing)
            } else {
                // Loading state while ViewModel is being created
                ZStack {
                    Color.pureBlack.ignoresSafeArea()
                    VStack {
                        ProgressView()
                            .tint(.offWhite)
                        Text("Đang khởi tạo...")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedGrey)
                            .padding(.top, 8)
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                // Initialize ViewModel with ModelContext
                viewModel = FeedViewModel(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Internal View (with ViewModel)
private struct ContentViewInternal: View {
    @ObservedObject var viewModel: FeedViewModel
    @Binding var isSyncing: Bool
    
    var body: some View {
        ZStack {
            // Background gốc của app
            Color.pureBlack.ignoresSafeArea()
            
            // 🌟 1. Giao diện Feed Tối Giản
            VStack(spacing: 0) {
                // Navigation Header: Ultra-slim, Black, Serif Font
                HStack(alignment: .bottom) {
                    Text("PureFB")
                        .font(.custom(AppConstants.UI.primaryFont, size: AppConstants.UI.headerFontSize))
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
                .padding(.horizontal, AppConstants.UI.standardHorizontalPadding)
                .padding(.top, 10)
                .padding(.bottom, AppConstants.UI.standardVerticalPadding)
                .background(Color.pureBlack)
                
                // Feed Structure: Clean, single-column scrollable
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    // Loading skeleton
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 24) {
                            ForEach(0..<3, id: \.self) { _ in
                                PostSkeletonView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                } else if let error = viewModel.errorMessage {
                    // Error state
                    VStack(spacing: 16) {
                        Text("⚠️")
                            .font(.system(size: 48))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.mutedGrey)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Thử lại") {
                            viewModel.fetchPosts()
                        }
                        .foregroundColor(.offWhite)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.softDarkGrey)
                        .cornerRadius(AppConstants.UI.cardCornerRadius)
                    }
                    .frame(maxHeight: .infinity)
                } else if viewModel.posts.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Text("📭")
                            .font(.system(size: 48))
                        Text("Chưa có bài viết")
                            .font(.system(size: 16))
                            .foregroundColor(.offWhite)
                        Text("Kéo xuống để tải bài viết mới")
                            .font(.system(size: 14))
                            .foregroundColor(.mutedGrey)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Posts list
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
            }
            
            // 🌟 2. Giao diện Đăng nhập & WebView ngầm
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("PureFB Authentication")
                        .font(.custom(AppConstants.UI.primaryFont, size: 20))
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
            .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: viewModel.needsLogin)
        }
        .onAppear {
            #if DEBUG
            print("📱 [ContentView] Appeared - Posts count: \(viewModel.posts.count)")
            #endif
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
