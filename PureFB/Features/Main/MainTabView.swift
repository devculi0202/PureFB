//
//  MainTabView.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔹 Content Area
            ZStack {
                Color.pureBlack.ignoresSafeArea()
                
                switch selectedTab {
                case 0:
                    // Lưu ý: Đổi tên ContentView() thành FeedView() nếu bạn đã đổi tên file Feed
                    ContentView()
                case 1:
                    WhitelistView()
                case 2:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 🔹 Custom Minimalist Tab Bar (Zero Icons, Thin Line)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.softDarkGrey)
                    .frame(height: 1)
                
                HStack {
                    Spacer()
                    TabButton(title: "FEED", isSelected: selectedTab == 0) { selectedTab = 0 }
                    Spacer()
                    TabButton(title: "FRIENDS", isSelected: selectedTab == 1) { selectedTab = 1 }
                    Spacer()
                    TabButton(title: "SETTINGS", isSelected: selectedTab == 2) { selectedTab = 2 }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.pureBlack)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
