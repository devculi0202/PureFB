//
//  StoredFriend.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//  📍 Location: Core/Persistence/
//  🎯 Purpose: SwiftData model for persisting whitelisted friends/pages
//

import Foundation
import SwiftData

// MARK: - StoredFriend Model
@Model
final class StoredFriend {
    // MARK: - Properties
    
    /// Unique identifier
    @Attribute(.unique) var id: UUID
    
    /// Friend/Page name
    var name: String
    
    /// Facebook URL
    var facebookURL: String
    
    /// Whether this friend is currently in whitelist
    var isWhitelisted: Bool
    
    /// Date when friend was added
    var addedAt: Date
    
    /// Last time posts were scraped from this source
    var lastScrapedAt: Date?
    
    /// Number of posts scraped from this source
    var postsCount: Int
    
    // MARK: - Initializer
    
    init(
        name: String,
        facebookURL: String,
        isWhitelisted: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.facebookURL = facebookURL
        self.isWhitelisted = isWhitelisted
        self.addedAt = Date()
        self.lastScrapedAt = nil
        self.postsCount = 0
    }
}

// MARK: - Conversion to Friend (UI Model)

extension StoredFriend {
    /// Convert SwiftData model to UI struct
    func toFriend() -> Friend {
        Friend(
            name: self.name,
            isAdded: self.isWhitelisted
        )
    }
}

// MARK: - Conversion from Friend

extension Friend {
    /// Convert UI struct to SwiftData model
    /// Note: Requires Facebook URL which Friend struct doesn't have yet
    func toStoredFriend(facebookURL: String) -> StoredFriend {
        StoredFriend(
            name: self.name,
            facebookURL: facebookURL,
            isWhitelisted: self.isAdded
        )
    }
}

// MARK: - Helper Methods

extension StoredFriend {
    /// Update last scraped timestamp
    func markAsScraped(postsFound: Int = 0) {
        self.lastScrapedAt = Date()
        self.postsCount += postsFound
    }
    
    /// Check if scraping is needed (based on time since last scrape)
    func needsScraping(intervalHours: Int = 1) -> Bool {
        guard let lastScraped = lastScrapedAt else {
            return true // Never scraped
        }
        
        let hoursSinceLastScrape = Calendar.current.dateComponents(
            [.hour],
            from: lastScraped,
            to: Date()
        ).hour ?? 0
        
        return hoursSinceLastScrape >= intervalHours
    }
}

// MARK: - Computed Properties

extension StoredFriend {
    /// Check if this is a Facebook page (URL contains specific patterns)
    var isPage: Bool {
        facebookURL.contains("/pages/") || !facebookURL.contains("/profile.php")
    }
    
    /// Days since added to whitelist
    var daysSinceAdded: Int {
        Calendar.current.dateComponents([.day], from: addedAt, to: Date()).day ?? 0
    }
}

// MARK: - Debug Description

#if DEBUG
extension StoredFriend {
    var debugDescription: String {
        """
        StoredFriend(
            name: \(name)
            url: \(facebookURL)
            whitelisted: \(isWhitelisted)
            posts: \(postsCount)
            lastScraped: \(lastScrapedAt?.description ?? "never")
        )
        """
    }
}
#endif
