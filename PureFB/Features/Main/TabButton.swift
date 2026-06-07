//
//  TabButton.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//
import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                .tracking(1.5) // Giãn chữ
                .foregroundColor(isSelected ? .offWhite : .mutedGrey)
                .padding(.vertical, 8)
        }
    }
}
