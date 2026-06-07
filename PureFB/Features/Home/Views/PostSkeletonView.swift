//
//  PostSkeletonView.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//
// Thêm view này vào thư mục Features/Home/Views/
import SwiftUI

struct PostSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)).frame(width: 150, height: 16)
            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)).frame(height: 100)
        }
        .padding(.horizontal, 24)
        .redacted(reason: .placeholder) // SwiftUI hỗ trợ sẵn
    }
}

