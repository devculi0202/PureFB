//
//  PersistenceHelpers.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//  📍 Location: Core/Persistence/
//  🎯 Purpose: Helper utilities for SwiftData operations
//

import Foundation
import SwiftData

// MARK: - Persistence Helper

enum PersistenceHelper {
    
    // MARK: - Batch Operations
    
    /// Check if posts exist in database by IDs (batch operation)
    static func existingPostIDs(
        from ids: [String],
        in context: ModelContext
    ) -> Set<String> {
        let predicate = #Predicate<StoredPost> { post in
            ids.contains(post.id)
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let posts = try context.fetch(descriptor)
            return Set(posts.map { $0.id })
        } catch {
            print("❌ [Persistence] Error fetching existing IDs: \(error)")
            return []
        }
    }
    
    /// Fetch all whitelisted friends
    static func fetchWhitelistedFriends(
        from context: ModelContext
    ) -> [StoredFriend] {
        let predicate = #Predicate<StoredFriend> { friend in
            friend.isWhitelisted == true
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ [Persistence] Error fetching whitelisted friends: \(error)")
            return []
        }
    }
    
    // MARK: - Cleanup Operations
    
    /// Delete old posts beyond retention days
    static func cleanupOldPosts(
        olderThanDays days: Int = AppConstants.Storage.maxPostRetentionDays,
        in context: ModelContext
    ) {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        ) ?? Date()
        
        let predicate = #Predicate<StoredPost> { post in
            post.createdAt < cutoffDate && post.isFavorite == false
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let oldPosts = try context.fetch(descriptor)
            
            for post in oldPosts {
                context.delete(post)
            }
            
            try context.save()
            
            if !oldPosts.isEmpty {
                print("🧹 [Persistence] Cleaned up \(oldPosts.count) old posts")
            }
        } catch {
            print("❌ [Persistence] Cleanup error: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    /// Get total stored posts count
    static func totalPostsCount(in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<StoredPost>()
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("❌ [Persistence] Error counting posts: \(error)")
            return 0
        }
    }
    
    /// Get favorites count
    static func favoritesCount(in context: ModelContext) -> Int {
        let predicate = #Predicate<StoredPost> { post in
            post.isFavorite == true
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("❌ [Persistence] Error counting favorites: \(error)")
            return 0
        }
    }
}

// MARK: - ModelContext Extensions

extension ModelContext {
    /// Safe save with error handling
    func safeSave() {
        do {
            try self.save()
            #if DEBUG
            print("✅ [Persistence] Context saved successfully")
            #endif
        } catch {
            print("❌ [Persistence] Save failed: \(error)")
        }
    }
    
    /// Delete all posts (for testing/debugging)
    func deleteAllPosts() {
        #if DEBUG
        let descriptor = FetchDescriptor<StoredPost>()
        
        do {
            let allPosts = try fetch(descriptor)
            for post in allPosts {
                delete(post)
            }
            try save()
            print("🗑️ [Persistence] Deleted all posts (\(allPosts.count))")
        } catch {
            print("❌ [Persistence] Delete all failed: \(error)")
        }
        #endif
    }
}
