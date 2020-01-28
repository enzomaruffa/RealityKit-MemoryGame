//
//  CardSingleton.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 28/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import Foundation

class CardSingleton {
    static let shared = CardSingleton()
    var cards: [Card] = []
    
    private init () {
        let cardNames = ["time", "apple", "completude", "enzo", "purple", "ufpr"]
        
        var card = Card(name: "Tempo", assetName: "time", text: "Metacarta do tempo. Ordena as palavras :)", meta: true)
        cards.append(card)
        
        card = Card(name: "Apple", assetName: "apple", text: "Apple Developer Academy. O lugar onde eu estudo e ocasionalmente trabalho. Ensino e aprendo todos os dias", meta: false)
        cards.append(card)
        
        card = Card(name: "Completude", assetName: "completude", text: "Que as cartas possam ter paz após sumir!", meta: true)
        cards.append(card)
        
        card = Card(name: "Enzo", assetName: "enzo", text: "Enzo Maruffa Moreira. Nascido em 06/07/1999. Gosta um pouco de tudo e demais de algumas coisas, como tons de roxo e MMs", meta: true)
        cards.append(card)
        
        card = Card(name: "Roxo", assetName: "purple", text: "Metacarta do tempo. Ordena as palavras :)", meta: true)
        cards.append(card)
        
        card = Card(name: "UFPR", assetName: "ufpr", text: "Metacarta do tempo. Ordena as palavras :)", meta: true)
        cards.append(card)
        
    }
}
