//
//  Ext_Int.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation

extension Int {
    func leadingZero() -> String {
        return String(format: "%02d", self)
    }
    func monthN() -> String {
        let months = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]
        if self >= 1 && self <= 12 {
            return months[self - 1]
        }
        return ""
    }
}
