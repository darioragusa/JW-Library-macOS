//
//  Structures.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import Foundation

struct BibleBook {
    var ID: Int
    var shortName: String
    var fullName: String
    var chapters: Int
}

struct UserMark {
    var ID: Int
    var color: Int
}

struct BlockRange {
    var identifier: Int
    var startToken: Int
    var endToken: Int
}

struct Highlight {
    var userMark: UserMark
    var blockRange: BlockRange
}

struct Existing {
    var userMarkId: Int
    var startToken: Int
    var endToken: Int
    var colorIndex: Int
}
