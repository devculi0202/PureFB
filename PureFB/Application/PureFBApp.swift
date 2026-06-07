//
//  PureFBApp.swift
//  PureFB
//
//  Created by Duy Le on 31/5/26.
//  Updated: 7/6/26 - Added SwiftData persistence
//

import SwiftUI
import SwiftData

@main
struct PureFBApp: App {
    
    // MARK: - SwiftData ModelContainer
    
    let modelContainer: ModelContainer
    
    // MARK: - Initializer
    
    init() {
        do {
            // Define schema with all persistent models
            let schema = Schema([
                StoredPost.self,
                StoredFriend.self
            ])
            
            // Configure persistent storage
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,  // Use persistent storage
                allowsSave: true,
                cloudKitDatabase: .none       // No iCloud sync for now
            )
            
            // Create ModelContainer
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            #if DEBUG
            print("✅ [SwiftData] ModelContainer initialized successfully")
            print("📍 [SwiftData] Store location: \(configuration.url)")
            #endif
            
        } catch {
            // FALLBACK: If persistent storage fails, use in-memory
            print("⚠️ [SwiftData] Persistent storage failed: \(error)")
            print("🔄 [SwiftData] Falling back to in-memory storage")
            
            do {
                let schema = Schema([
                    StoredPost.self,
                    StoredFriend.self
                ])
                
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true  // In-memory fallback
                )
                
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfig]
                )
                
                print("✅ [SwiftData] In-memory container created")
                
            } catch {
                // CRITICAL: Both persistent and in-memory failed
                fatalError("❌ [SwiftData] Failed to create ModelContainer: \(error)")
            }
        }
    }
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)  // Inject container into environment
    }
}
