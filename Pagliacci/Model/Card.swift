//
//  Card.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 28/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import Foundation

class Card: Codable {
    
    static let defaultCardAssetName = "verso"
    
    var name: String
    var assetName: String
    var text: String
    var shortText: String
    var meta: Bool
    var revealed: Bool
    
    internal init(name: String, assetName: String, text: String, shortText: String, meta: Bool) {
        self.name = name
        self.assetName = assetName
        self.shortText = shortText
        self.text = text
        self.meta = meta
        self.revealed = false
    }
    
}
