//
//  Post.swift
//  PureFB
//
//  Created by iOS Engineer on [CURRENT_DATE].
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let author: String
    let content: String
    let imageUrl: String?
    let timestamp: String
}