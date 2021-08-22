//
//  HighlightManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation

class HighlightManager {
    static func addHighlight(color: Int, newBlockRange: BlockRange, pub: Publication, documentID: Int? = nil) {
        print("🆘 NUOVA OPERAZIONE 🆘")
        let locationId = LocationManager.getLocation(pub: pub, documentId: documentID)
        let existingArray = BlockRangeManager.getExistingBlockRange(blockRange: newBlockRange, locationId: locationId)
        if color > 0 { //
            var newStartToken = newBlockRange.startToken
            var newEndToken = newBlockRange.endToken
            for existing in existingArray {
                newStartToken = existing.startToken < newStartToken ? existing.startToken : newStartToken
                newEndToken = existing.endToken > newEndToken ? existing.endToken : newEndToken
                BlockRangeManager.removeBlockRange(userMarkId: existing.userMarkId)
                UserMarkManager.removeUserMark(userMarkId: existing.userMarkId)
            }
            let markId = UserMarkManager.addUserMark(color: color, locationId: locationId)
            BlockRangeManager.addBlockRange(pub: pub, identifier: newBlockRange.identifier, startToken: newStartToken, endToken: newEndToken, markId: markId)
            print("Sottolineatura aggiunta ✍🏻")
        } else {
            for existing in existingArray {
                let shouldSplit: Bool = existing.startToken < newBlockRange.startToken && existing.endToken > newBlockRange.endToken
                if shouldSplit { // Ricuco l'end e creo uno nuovo
                    BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                          startToken: existing.startToken,
                                                                          endToken: newBlockRange.startToken - 1,
                                                                          colorIndex: existing.colorIndex))
                    let markId = UserMarkManager.addUserMark(color: existing.colorIndex, locationId: locationId)
                    BlockRangeManager.addBlockRange(pub: pub,
                                                    identifier: newBlockRange.identifier,
                                                    startToken: newBlockRange.endToken + 1,
                                                    endToken: existing.endToken,
                                                    markId: markId)
                } else {
                    if newBlockRange.startToken <= existing.startToken && newBlockRange.endToken >= existing.startToken && newBlockRange.endToken < existing.endToken { // Aumento lo start
                        BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                              startToken: newBlockRange.endToken + 1,
                                                                              endToken: existing.endToken,
                                                                              colorIndex: existing.colorIndex))
                    } else if newBlockRange.endToken >= existing.endToken && newBlockRange.startToken <= existing.endToken  && newBlockRange.startToken > existing.startToken { // Riduco l'end
                        BlockRangeManager.updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                              startToken: existing.startToken,
                                                                              endToken: newBlockRange.startToken - 1,
                                                                              colorIndex: existing.colorIndex))
                    } else if existing.startToken >= newBlockRange.startToken && existing.endToken <= newBlockRange.endToken { // Lo elimino?
                        BlockRangeManager.removeBlockRange(userMarkId: existing.userMarkId)
                            UserMarkManager.removeUserMark(userMarkId: existing.userMarkId)
                    }
                }
            }
            print("Sottolineatura rimossa 🚮")
        }
        BackupManager.storeDataInDB()
    }

    static func getHighlight(pub: Publication, documentID: Int? = nil) -> [Highlight] {
        var highlights: [Highlight] = []
        let locationId = LocationManager.getLocation(pub: pub, documentId: documentID)
        let userMarks: [UserMark] = UserMarkManager.getUserMark(locationId: locationId)
        for userMark in userMarks {
            let blockRange = BlockRangeManager.getBlockRange(userMarkId: userMark.ID)
            highlights.append(Highlight(userMark: userMark, blockRange: blockRange))
        }
        print("Found \(highlights.count) userMark 🕵🏻‍♂️")
        return highlights
    }
}
