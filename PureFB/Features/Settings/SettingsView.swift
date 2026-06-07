//
//  SettingsView.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//
import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var isQuietTimeEnabled: Bool = false
    @State private var quietTime: Date = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.custom(AppConstants.UI.primaryFont, size: AppConstants.UI.titleFontSize))
                .foregroundColor(.offWhite)
                .padding(.vertical, AppConstants.UI.standardVerticalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppConstants.UI.standardHorizontalPadding)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    SettingsGroup {
                        SettingsRowText(title: "Trạng thái kết nối Facebook", trailing: "[Đã kết nối]")
                    }
                    
                    SettingsGroup {
                        SettingsRowText(title: "Cỡ chữ hiển thị", trailing: "[Tiêu chuẩn]")
                        
                        HStack {
                            Text("Thời gian tĩnh lặng")
                                .font(.system(size: 16))
                                .foregroundColor(.offWhite)
                            Spacer()
                            Toggle("", isOn: $isQuietTimeEnabled)
                                .labelsHidden()
                                .tint(Color.mutedGrey)
                        }
                        .padding(.vertical, 4)
                        
                        if isQuietTimeEnabled {
                            DatePicker("", selection: $quietTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorMultiply(Color.mutedGrey)
                                .frame(height: 120)
                                .clipped()
                        }
                        
                        Button(action: {}) {
                            Text("Xóa bộ nhớ đệm ứng dụng")
                                .font(.system(size: 16))
                                .foregroundColor(.offWhite)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                    }
                    
                    SettingsGroup {
                        Button(action: {}) {
                            Text("Đồng bộ dữ liệu thủ công")
                                .font(.system(size: 16))
                                .foregroundColor(.offWhite)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.UI.standardHorizontalPadding)
                .padding(.bottom, 60)
            }
        }
        .background(Color.pureBlack)
    }
}
