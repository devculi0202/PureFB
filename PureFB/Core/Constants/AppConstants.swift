//
//  AppConstants.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//

import Foundation
import SwiftUI

// MARK: - Application Constants
public enum AppConstants {
    
    // MARK: - URLs
    public enum URLs {
        static let facebookMobile = "https://m.facebook.com"
        static let facebookCheckpoint = "https://m.facebook.com/checkpoint"
        
        /// Default target URLs khi chưa có whitelist
        static let defaultTargets: [String] = [
            "https://m.facebook.com/vietnamnet.vn",
            "https://m.facebook.com/tinhte"
        ]
        
        /// Convert string array to URL array
        static func urlsFromStrings(_ strings: [String]) -> [URL] {
            strings.compactMap { URL(string: $0) }
        }
        
        /// Get default target URLs as URL objects
        static var defaultTargetURLs: [URL] {
            urlsFromStrings(defaultTargets)
        }
    }
    
    // MARK: - Scraping Configuration
    enum Scraping {
        /// Số lần auto-scroll để kích thích Facebook tải thêm content
        static let autoScrollCount: Int = 6
        
        /// Thời gian chờ giữa mỗi lần scroll (seconds)
        static let scrollInterval: TimeInterval = 2.0
        
        /// Thời gian chờ sau khi page load xong để render (seconds)
        static let pageLoadDelay: TimeInterval = 3.0
        
        /// Thời gian chờ giữa mỗi lần quét DOM (seconds)
        static let domScanDelay: TimeInterval = 0.8
        
        /// Độ dài tối thiểu của content để coi là bài viết hợp lệ
        static let minContentLength: Int = 30
        
        /// Độ dài tối đa của content preview (characters)
        static let maxContentPreview: Int = 500
        
        /// Thời gian timeout cho initial DOM scan (milliseconds)
        static let initialScanDelay: Int = 1000
    }
    
    // MARK: - UI Configuration
    enum UI {
        /// Font chữ chính của app
        static let primaryFont: String = "Georgia"
        
        /// Font size cho title
        static let titleFontSize: CGFloat = 24
        
        /// Font size cho header
        static let headerFontSize: CGFloat = 22
        
        /// Font size cho body text
        static let bodyFontSize: CGFloat = 16
        
        /// Font size cho secondary text
        static let secondaryFontSize: CGFloat = 14
        
        /// Font size cho caption/metadata
        static let captionFontSize: CGFloat = 11
        
        /// Font size cho small text
        static let smallFontSize: CGFloat = 12
        
        /// Animation duration cho transitions
        static let animationDuration: TimeInterval = 0.4
        
        /// Line spacing cho post content
        static let contentLineSpacing: CGFloat = 8
        
        /// Letter tracking cho tab buttons
        static let tabButtonTracking: CGFloat = 1.5
        
        /// Letter tracking cho metadata
        static let metadataTracking: CGFloat = 1.0
        
        /// Corner radius cho cards
        static let cardCornerRadius: CGFloat = 4
        
        /// Padding horizontal chuẩn
        static let standardHorizontalPadding: CGFloat = 20
        
        /// Padding vertical chuẩn
        static let standardVerticalPadding: CGFloat = 16
        
        /// Spacing giữa các posts
        static let postSpacing: CGFloat = 24
        
        /// Syncing dot size
        static let syncDotSize: CGFloat = 5
    }
    
    // MARK: - JavaScript Bridge
    enum JavaScript {
        /// Tên message handler để JS giao tiếp với Swift
        static let bridgeName: String = "purefb_bridge"
        
        /// Prefix cho log messages từ JS
        static let logPrefix: String = "LOG: "
        
        /// Prefix cho data messages từ JS
        static let dataPrefix: String = "DATA: "
        
        /// User Agent giả dạng iPhone Safari
        static let userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
        
        /// Flag name to check if radar is already injected
        static let radarInjectedFlag: String = "pureFBRadarInjected"
    }
    
    // MARK: - Login Detection Keywords
    enum LoginDetection {
        /// Các từ khóa để phát hiện trang đăng nhập
        static let loginKeywords: [String] = [
            "đăng nhập",
            "log in",
            "sign in"
        ]
        
        /// Các URL patterns cho checkpoint/2FA
        static let checkpointPatterns: [String] = [
            "checkpoint",
            "/two_factor",
            "/co/checkpoint"
        ]
        
        /// Input field selectors for login detection
        static let passwordInputSelectors: [String] = [
            "input[name=\"pass\"]",
            "input[type=\"password\"]"
        ]
        
        /// OTP field selector
        static let otpInputSelector: String = "input[name=\"approvals_code\"]"
    }
    
    // MARK: - Content Filtering
    enum ContentFilter {
        /// Các từ khóa để nhận diện bài viết shared
        static let sharedPostKeywords: [String] = [
            "đã chia sẻ",
            "shared a link",
            "shared",
            "chia sẻ"
        ]
        
        /// Các từ cần filter ra khỏi nội dung
        static let filterOutKeywords: [String] = [
            "Vui lòng đăng nhập",
            "Please log in"
        ]
        
        /// DOM selectors for post elements
        static let postSelectors: String = "article, [data-ft], [data-story-id]"
        
        /// Fallback selector for posts
        static let fallbackPostSelector: String = "div > div > span"
        
        /// GraphQL API patterns
        static let graphQLPatterns: [String] = ["graphql", "api", "bz"]
    }
    
    // MARK: - Cache & Storage
    enum Storage {
        /// Key cho UserDefaults
        static let userDefaultsKey: String = "purefb_settings"
        
        /// Key cho Keychain cookies
        static let cookiesKeychainKey: String = "facebook_cookies"
        
        /// Số ngày tối đa lưu posts (để cleanup)
        static let maxPostRetentionDays: Int = 30
        
        /// SwiftData container name
        static let containerName: String = "PureFBModel"
    }
    
    // MARK: - Post Metadata
    enum Post {
        /// Default author khi không xác định được
        static let defaultDOMAuthor: String = "Facebook Publisher"
        static let defaultGraphQLAuthor: String = "Chính chủ Facebook"
        
        /// Timestamp labels
        static let freshTimestamp: String = "Tin mới nhận"
        static let updatedTimestamp: String = "Vừa cập nhật"
        
        /// ID prefixes
        static let domIDPrefix: String = "dom_"
        static let graphQLIDPrefix: String = "gql_"
    }
}

// MARK: - Debug Configuration
#if DEBUG
extension AppConstants {
    enum Debug {
        static let enableVerboseLogging: Bool = true
        static let enableJavaScriptConsole: Bool = true
        static let mockDataEnabled: Bool = false
        
        /// Print all constants on app launch
        static func printAllConstants() {
            print("=== 🔧 AppConstants Debug Info ===")
            print("📍 URLs:")
            print("  - Facebook Mobile: \(URLs.facebookMobile)")
            print("  - Default Targets: \(URLs.defaultTargets.count) URLs")
            
            print("\n🔍 Scraping:")
            print("  - Auto Scroll Count: \(Scraping.autoScrollCount)")
            print("  - Scroll Interval: \(Scraping.scrollInterval)s")
            print("  - Page Load Delay: \(Scraping.pageLoadDelay)s")
            
            print("\n🎨 UI:")
            print("  - Primary Font: \(UI.primaryFont)")
            print("  - Title Size: \(UI.titleFontSize)")
            print("  - Animation Duration: \(UI.animationDuration)s")
            
            print("\n🌉 JavaScript:")
            print("  - Bridge Name: \(JavaScript.bridgeName)")
            print("  - Log Prefix: '\(JavaScript.logPrefix)'")
            
            print("\n🔎 Content Filter:")
            print("  - Shared Keywords: \(ContentFilter.sharedPostKeywords.count) items")
            print("  - Filter Keywords: \(ContentFilter.filterOutKeywords.count) items")
            
            print("=================================\n")
        }
    }
}
#endif

// MARK: - Convenience Extensions
extension AppConstants {
    /// Helper to get all JavaScript constants as a dictionary for injection
    static func javascriptConstants() -> [String: Any] {
        return [
            "MIN_CONTENT_LENGTH": Scraping.minContentLength,
            "MAX_CONTENT_PREVIEW": Scraping.maxContentPreview,
            "AUTO_SCROLL_COUNT": Scraping.autoScrollCount,
            "SCROLL_INTERVAL": Int(Scraping.scrollInterval * 1000),
            "DOM_SCAN_DELAY": Int(Scraping.domScanDelay * 1000),
            "INITIAL_SCAN_DELAY": Scraping.initialScanDelay,
            "FILTER_KEYWORDS": ContentFilter.filterOutKeywords,
            "POST_SELECTORS": ContentFilter.postSelectors,
            "FALLBACK_SELECTOR": ContentFilter.fallbackPostSelector
        ]
    }
}
