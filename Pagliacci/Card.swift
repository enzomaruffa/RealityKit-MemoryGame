//
//  Card.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 28/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import Foundation

class Card: Codable {
    
    var name: String
    var assetName: String
    var text: String
    var meta: Bool
    
    internal init(name: String, assetName: String, text: String, meta: Bool) {
        self.name = name
        self.assetName = assetName
        self.text = text
        self.meta = meta
    }
    
}
