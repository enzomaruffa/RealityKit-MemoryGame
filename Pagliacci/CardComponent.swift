//
//  CardComponent.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 27/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import RealityKit

struct CardComponent: Component, Codable {
    var matched = false
    var flipped = false
    var card: Card?
}
