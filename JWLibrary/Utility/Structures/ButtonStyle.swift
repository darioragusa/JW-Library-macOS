//
//  ButtonStyle.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SwiftUI

struct BibleButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? color.lighter(by: 30): color)
            .cornerRadius(6.0)
    }
}

struct TransparentButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(color)
            .cornerRadius(6.0)
    }
}
