//
//  StoredPost.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//  📍 Location: Core/Persistence/
//  🎯 Purpose: SwiftData model for persisting Facebook posts
//

import Foundation
import SwiftData

// MARK: - StoredPost Model
@Model
final class StoredPost {
    // MARK: - Properties
    
    /// Unique identifier (same as Post.id from scraping)
    @Attribute(.unique) var id: String
    
    /// Post author name
    var author: String
    
    /// Post content/text
    var content: String
    
    /// Optional image URL
    var imageUrl: String?
    
    /// Timestamp string from Facebook
    var timestamp: String
    
    /// Date when this post was saved to local database
    var createdAt: Date
    
    /// User favorite flag for future features
    var isFavorite: Bool
    
    /// Source of the post (for filtering/analytics)
    var source: String // "dom" or "graphql"
    
    // MARK: - Initializer
    
    init(
        id: String,
        author: String,
        content: String,
        imageUrl: String? = nil,
        timestamp: String,
        source: String = "unknown",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.source = source
        self.createdAt = Date()
        self.isFavorite = isFavorite
    }
}

// MARK: - Conversion to Post (UI Model)

extension StoredPost {
    /// Convert SwiftData model to UI struct
    func toPost() -> Post {
        Post(
            id: self.id,
            author: self.author,
            content: self.content,
            imageUrl: self.imageUrl,
            timestamp: self.timestamp
        )
    }
}

// MARK: - Conversion from Post

extension Post {
    /// Convert UI struct to SwiftData model
    func toStoredPost() -> StoredPost {
        // Detect source from ID prefix
        let source: String
        if self.id.hasPrefix(AppConstants.Post.domIDPrefix) {
            source = "dom"
        } else if self.id.hasPrefix(AppConstants.Post.graphQLIDPrefix) {
            source = "graphql"
        } else {
            source = "unknown"
        }
        
        return StoredPost(
            id: self.id,
            author: self.author,
            content: self.content,
            imageUrl: self.imageUrl,
            timestamp: self.timestamp,
            source: source,
            isFavorite: false
        )
    }
}

// MARK: - Computed Properties

extension StoredPost {
    /// Check if this is a DOM-scraped post
    var isDOMPost: Bool {
        source == "dom"
    }
    
    /// Check if this is a GraphQL-scraped post
    var isGraphQLPost: Bool {
        source == "graphql"
    }
    
    /// Age of the post in days since saved
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
}

// MARK: - Debug Description

#if DEBUG
extension StoredPost {
    var debugDescription: String {
        """
        StoredPost(
            id: \(id)
            author: \(author)
            content: \(content.prefix(50))...
            source: \(source)
            favorite: \(isFavorite)
            age: \(ageInDays) days
        )
        """
    }
}
#endif
