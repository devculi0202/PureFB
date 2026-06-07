//
//  SettingsComponents.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//
import SwiftUI

// Lớp Wrapper để giả lập "Grouped List"
struct SettingsGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            content
        }
        .padding(20)
        .background(Color.softDarkGrey)
        .cornerRadius(4)
    }
}

// Lớp Row hiển thị văn bản tĩnh
struct SettingsRowText: View {
    let title: String
    let trailing: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.offWhite)
            Spacer()
            Text(trailing)
                .font(.system(size: 14))
                .foregroundColor(.mutedGrey)
        }
        .padding(.vertical, 4)
    }
}
