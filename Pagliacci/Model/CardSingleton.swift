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
        var card = Card(name: "Tempo", assetName: "time", text: "A magia da cronologia", shortText: "Que as palavras se ordenem!", meta: true)
        cards.append(card)
        
        card = Card(name: "Apple", assetName: "apple", text: "Apple Developer Academy. O lugar onde eu estudo e ocasionalmente trabalho. Ensino e aprendo todos os dias", shortText: " S2 ", meta: false)
        cards.append(card)
        
        card = Card(name: "Completude", assetName: "completude", text: "Essa carta era pras outras sumirem. Mas agora não é mais. É só pra falar que alquimia é legal.", shortText: "Essa ficou só de bonito", meta: true)
        cards.append(card)
        
        card = Card(name: "Enzo", assetName: "enzo", text: "Enzo Maruffa Moreira. Nascido em 06/07/1999. Gosta um pouco de tudo e demais de algumas coisas, como tons de roxo e MMs", shortText: "Enzolitos: versão carta", meta: false)
        cards.append(card)
        
        card = Card(name: "Roxo", assetName: "purple", text: "Sim, agora além de ter cabelo, calça, cachecol e quase tudo roxo, tenho uma carta em AR roxa.", shortText: "Roxo é bonito né", meta: false)
        cards.append(card)
        
        card = Card(name: "UFPR", assetName: "ufpr", text: "Estudo Ciência da Computação nesse lugar aí. É bem legal, mas um tanto cansativo.",  shortText: "E o semestre recomeça...", meta: false)
        cards.append(card)
        
        card = Card(name: "Cheater", assetName: "cheater", text: "E o trapaceiro aparece. Como quando eu criança usava Cheat Engine nos jogos do Orkut",  shortText: "Cheats 'n tricks", meta: true)
        cards.append(card)
        
        card = Card(name: "Tchuca", assetName: "tchuca", text: "O cachorro mais fofo de planeta Terra e região. Quer dizer, universo e região. Ou multiverso?",  shortText: "Au au au au", meta: false)
        cards.append(card)
    }
    
    func setCardMatched(byCardName cardName: String) {
        cards.filter({ $0.name == cardName }).first?.revealed = true
    }
    func setCardMatched(byAssetName assetName: String) {
        cards.filter({ $0.assetName == assetName }).first?.revealed = true
    }
}
