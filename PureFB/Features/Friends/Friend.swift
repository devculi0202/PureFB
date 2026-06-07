//
//  Friend.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//
import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    var isAdded: Bool
}
