//
//  Generals.swift
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

struct Note {
    var ID: Int
    var title: String
    var content: String
}

struct Publication {
    var ID: Int
    var keySymbol: String
    var year: Int
    var mepsLanguageId: Int
    var publicationTypeId: Int
    var issueTagNumber: Int
    var title: String
    var issueTitle: String?
    // Only Bible
    var isBible: Bool = false
    var book: Int?
    var chapter: Int?
}

struct Document {
    var documentId: Int
    var title: String
}
