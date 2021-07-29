//
//  HighlightManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation

class HighlightManager {
    // L'identifier (almeno nella Bibbia) sarebbe il versetto
    static func addHighlight(color: Int, identifier: Int, startToken: Int, endToken: Int, pubb: String, book: Int, chapter: Int, lang: Int = 4) {
        print("🆘 NUOVA OPERAZIONE 🆘")
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        let existingArray = BlockRangeManager.getExistingBlockRange(blockRange: BlockRange(identifier: identifier, startToken: startToken, endToken: endToken))
        if color > 0 {
            var newStartToken = startToken
            var newEndToken = endToken
            for existing in existingArray {
                newStartToken = existing.startToken < newStartToken ? existing.startToken : newStartToken
                newEndToken = existing.endToken > newEndToken ? existing.endToken : newEndToken
                BlockRangeManager.removeBlockRange(userMarkId: existing.userMarkId)
                UserMarkManager.removeUserMark(userMarkId: existing.userMarkId)
            }
            let locationId = LocationManager.getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
            let markId = UserMarkManager.addUserMark(color: color, locationId: locationId, pubbKey: String(pubbKey))
            BlockRangeManager.addBlockRange(identifier: identifier, startToken: newStartToken, endToken: newEndToken, markId: markId)
            print("Sottolineatura aggiunta ✅")
        } else {
            for existing in existingArray {
                let shouldSplit: Bool = existing.startToken < startToken && existing.endToken > endToken
                if shouldSplit { // Ricuco l'end e creo uno nuovo
                    BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                            startToken: existing.startToken,
                                                            endToken: startToken - 1,
                                                            colorIndex: existing.colorIndex))
                    let locationId = LocationManager.getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
                    let markId = UserMarkManager.addUserMark(color: existing.colorIndex, locationId: locationId, pubbKey: String(pubbKey))
                    BlockRangeManager.addBlockRange(identifier: identifier,
                                                  startToken: endToken + 1,
                                                  endToken: existing.endToken,
                                                  markId: markId)
                } else {
                    if startToken <= existing.startToken && endToken >= existing.startToken && endToken < existing.endToken { // Aumento lo start
                        BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                startToken: endToken + 1,
                                                                endToken: existing.endToken,
                                                                colorIndex: existing.colorIndex))
                    } else if endToken >= existing.endToken && startToken <= existing.endToken  && startToken > existing.startToken { // Riduco l'end
                        BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                startToken: existing.startToken,
                                                                endToken: startToken - 1,
                                                                colorIndex: existing.colorIndex))
                    } else if existing.startToken >= startToken && existing.endToken <= existing.endToken { // Lo elimino?
                        BlockRangeManager.removeBlockRange(userMarkId: existing.userMarkId)
                            UserMarkManager.removeUserMark(userMarkId: existing.userMarkId)
                    }
                }
            }
            print("Sottolineatura rimossa ✅")
        }
    }

    static func getHighlight(pubb: String, book: Int, chapter: Int, lang: Int = 4) -> [Highlight] {
        var highlights: [Highlight] = []
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        let locationId = LocationManager.getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
        let userMarks: [UserMark] = UserMarkManager.getUserMark(locationId: locationId)
        for userMark in userMarks {
            let blockRange = BlockRangeManager.getBlockRange(userMarkId: userMark.ID)
            highlights.append(Highlight(userMark: userMark, blockRange: blockRange))
        }
        print("Found \(highlights.count) userMark ✅")
        return highlights
    }
}
