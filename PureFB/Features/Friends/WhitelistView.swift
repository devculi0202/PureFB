//
//  WhitelistView.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//

import SwiftUI

struct WhitelistView: View {
    @State private var searchText: String = ""
    @State private var friends: [Friend] = [
        Friend(name: "Lê Minh Duy", isAdded: true),
        Friend(name: "Nguyễn Văn A", isAdded: true),
        Friend(name: "Trần Thị B", isAdded: false),
        Friend(name: "Nhóm Tin Tức Công Nghệ", isAdded: false)
    ]
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Whitelist")
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.offWhite)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("Tìm kiếm bạn bè...")
                            .foregroundColor(.mutedGrey)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                    }
                    TextField("", text: $searchText)
                        .foregroundColor(.offWhite)
                        .font(.system(size: 16))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                }
                .background(Color.softDarkGrey)
                .cornerRadius(4)
                
                Text("* Hệ thống quét cục bộ trong phạm vi danh sách bạn bè đã đồng bộ.")
                    .font(.system(size: 11))
                    .foregroundColor(.mutedGrey)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    ForEach($friends) { $friend in
                        HStack {
                            Text(friend.name)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.offWhite)
                            
                            Spacer()
                            
                            Button(action: {
                                friend.isAdded.toggle()
                            }) {
                                Text(friend.isAdded ? "[Xóa]" : "[Thêm]")
                                    .font(.system(size: 14))
                                    .foregroundColor(.mutedGrey)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.pureBlack)
    }
}
