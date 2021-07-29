//
//  Ext_Color.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SwiftUI

extension Color {
    func lighter(by percentage: CGFloat) -> Color? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat) -> Color? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat) -> Color? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        let oldColor = NSColor(self)
        oldColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let color: NSColor = NSColor(red: min(red + percentage/100, 1.0),
                                    green: min(green + percentage/100, 1.0),
                                    blue: min(blue + percentage/100, 1.0),
                                    alpha: alpha)
        return Color.init(color)
    }
}
