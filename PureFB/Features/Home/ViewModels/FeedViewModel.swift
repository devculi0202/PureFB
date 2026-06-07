import Foundation
import Combine
import SwiftData

@MainActor
class FeedViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var posts: [Post] = []
    @Published var needsLogin: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    let scraperService: FacebookScraperService
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(
        scraperService: FacebookScraperService = FacebookScraperService(),
        modelContext: ModelContext
    ) {
        self.scraperService = scraperService
        self.modelContext = modelContext
        
        setupBindings()
        loadCachedPosts() // Load from database on init
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Lắng nghe dữ liệu bài viết từ scraper
        scraperService.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scrapedPosts in
                self?.handleScrapedPosts(scrapedPosts)
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
    
    // MARK: - Load Cached Posts
    
    /// Load posts from SwiftData database
    func loadCachedPosts() {
        let descriptor = FetchDescriptor<StoredPost>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let storedPosts = try modelContext.fetch(descriptor)
            self.posts = storedPosts.map { $0.toPost() }
            
            #if DEBUG
            print("✅ [ViewModel] Loaded \(storedPosts.count) cached posts from database")
            #endif
            
            if storedPosts.isEmpty {
                print("ℹ️ [ViewModel] No cached posts found - database is empty")
            }
            
        } catch {
            errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
            print("❌ [ViewModel] Failed to load cached posts: \(error)")
        }
    }
    
    // MARK: - Handle Scraped Posts
    
    /// Handle new posts from scraper - save to database and update UI
    private func handleScrapedPosts(_ newPosts: [Post]) {
        guard !newPosts.isEmpty else { return }
        
        print("📥 [ViewModel] Received \(newPosts.count) scraped posts")
        
        // Batch check for existing posts (performance optimization)
        let newIDs = newPosts.map { $0.id }
        let existingIDs = PersistenceHelper.existingPostIDs(from: newIDs, in: modelContext)
        
        // Filter out duplicates
        let postsToInsert = newPosts.filter { !existingIDs.contains($0.id) }
        
        if postsToInsert.isEmpty {
            print("ℹ️ [ViewModel] All \(newPosts.count) posts already exist in database (duplicates)")
            return
        }
        
        // Insert new posts
        for post in postsToInsert {
            let storedPost = post.toStoredPost()
            modelContext.insert(storedPost)
        }
        
        // Save to database
        do {
            try modelContext.save()
            print("✅ [ViewModel] Saved \(postsToInsert.count) new posts (skipped \(newPosts.count - postsToInsert.count) duplicates)")
            
            // Reload from database to update UI
            loadCachedPosts()
            
        } catch {
            errorMessage = "Lỗi lưu dữ liệu: \(error.localizedDescription)"
            print("❌ [ViewModel] Failed to save posts: \(error)")
        }
    }
    
    // MARK: - Fetch Posts
    
    /// Trigger scraping from Facebook
    func fetchPosts() {
        isLoading = true
        errorMessage = nil
        
        // Get target URLs (can be from whitelist in future)
        let targetURLs = AppConstants.URLs.defaultTargetURLs
        
        print("🔄 [ViewModel] Starting scraping for \(targetURLs.count) targets...")
        scraperService.startScraping(urls: targetURLs)
        
        // Reset loading after a delay (scraping is async)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
        }
    }
    
    // MARK: - Post Actions
    
    /// Toggle favorite status
    func toggleFavorite(for post: Post) {
        let predicate = #Predicate<StoredPost> { $0.id == post.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            if let storedPost = try modelContext.fetch(descriptor).first {
                storedPost.isFavorite.toggle()
                try modelContext.save()
                
                #if DEBUG
                print("⭐ [ViewModel] Toggled favorite for post: \(post.id)")
                #endif
                
                loadCachedPosts() // Refresh UI
            }
        } catch {
            print("❌ [ViewModel] Failed to toggle favorite: \(error)")
        }
    }
    
    /// Delete a post
    func deletePost(_ post: Post) {
        let predicate = #Predicate<StoredPost> { $0.id == post.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            if let storedPost = try modelContext.fetch(descriptor).first {
                modelContext.delete(storedPost)
                try modelContext.save()
                
                print("🗑️ [ViewModel] Deleted post: \(post.id)")
                
                loadCachedPosts() // Refresh UI
            }
        } catch {
            print("❌ [ViewModel] Failed to delete post: \(error)")
        }
    }
    
    // MARK: - Cleanup
    
    /// Clean up old posts (called on app launch or manually)
    func cleanupOldPosts() {
        PersistenceHelper.cleanupOldPosts(in: modelContext)
        loadCachedPosts() // Refresh after cleanup
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension FeedViewModel {
    /// Print current state for debugging
    func debugPrintState() {
        print("=== 🐛 FeedViewModel State ===")
        print("Posts count: \(posts.count)")
        print("Needs login: \(needsLogin)")
        print("Is loading: \(isLoading)")
        print("Error: \(errorMessage ?? "none")")
        print("==============================")
    }
}
#endif
