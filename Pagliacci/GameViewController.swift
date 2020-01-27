//
//  GameViewController.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 24/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit
import RealityKit

class GameViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    private var cardsUp: [Entity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardComponent.registerComponent()
        
        let boundSize = Float(0.3)
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [boundSize, boundSize])
        arView.scene.addAnchor(anchor)
        
        // Loads cards
        var cardTemplates: [ModelEntity] = []
        
        let cardNames = ["time", "apple", "completude", "enzo", "purple", "ufpr"]
        
        for cardName in cardNames {
            let assetName = "card-" + cardName
            let cardTemplate = try! Entity.loadModel(named: assetName)
            cardTemplate.setScale(SIMD3<Float>(repeating: boundSize / Float(cardNames.count)), relativeTo: nil)
            
            cardTemplate.generateCollisionShapes(recursive: true)
            
            cardTemplate.name = assetName
            
            cardTemplate.physicsBody = nil
            cardTemplate.components[CardComponent.self] = CardComponent()
            cardTemplate.components[CardComponent.self]?.name = cardName
            
            cardTemplates.append(cardTemplate)
        }
        
        
        // Copies final cards
        var cards: [Entity] = []
        
        for cardTemplate in cardTemplates {
            for index in 1...2 {
                let clonedCard = cardTemplate.clone(recursive: true)
                clonedCard.name = clonedCard.name + "-" + index.description
                cards.append(clonedCard)
            }
        }
        
        // Card placement
        cards.shuffle()
        
        let rowSize = Int(sqrt(Double(cards.count)))
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % rowSize) - 2
            let z = Float(index / rowSize) - 2
            
            card.position = [x * 0.1, 0, z * 0.1]
            
            anchor.addChild(card)
        }
        
        // Box mesh
        let boxSize: Float = boundSize * 1.1
        let boxMesh = MeshResource.generateBox(size: boxSize)
        
        let material = OcclusionMaterial()
        
        let occlusionBox = ModelEntity(mesh: boxMesh, materials: [material])
        
        occlusionBox.position.y = -boxSize/2 - 0.001
        anchor.addChild(occlusionBox)
        
    }
    
    fileprivate func completeMatch() {
        print("Match made!")
        
        self.cardsUp.forEach({
            var cardComponent = $0.components[CardComponent.self] as! CardComponent
            cardComponent.matched = true
            $0.components[CardComponent.self] = cardComponent
        })

        self.cardsUp.removeAll()
    }
    
    fileprivate func dismissMatch() {
        print("Dismissing!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.cardsUp.forEach({ self.flipDown($0) })
            self.cardsUp.removeAll()
        }
    }
    
    @IBAction func viewPressed(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        
        if let card = arView.entity(at: tapLocation),
            let cardComponent = card.components[CardComponent.self] as?
            CardComponent {
            print(card.name)
            
            // Interaction
            print(cardComponent.matched)
            print(cardsUp.count)
            
            // Tap on not matched card
            if !cardComponent.matched && cardsUp.count < 2 {
                
                // Flip down
                if cardComponent.flipped {
                    flipDown(card)
                    cardsUp.removeAll(where: {$0.name == card.name})
                } else {
                    // Flip up
                    flipUp(card)
                    cardsUp.append(card)
                }
                
                if cardsUp.count >= 2 {
                    // check match
                    if let firstCard = cardsUp.first,
                        let lastCard = cardsUp.last,
                        let firstCardComponent = firstCard.components[CardComponent.self] as? CardComponent,
                        let secondCardComponent = lastCard.components[CardComponent.self] as? CardComponent,
                        firstCardComponent.name == secondCardComponent.name {
                        completeMatch()
                    } else {
                        dismissMatch()
                    }
                    
                    // Clears list
                }
            }
            
        }
    }
    
    private func flipUp(_ card: Entity){
        var flipUpTransform = card.transform
        
        flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
        
        _ = card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        
        var cardComponent = card.components[CardComponent.self] as! CardComponent
        cardComponent.flipped = true
        card.components[CardComponent.self] = cardComponent
    }
    
    private func flipDown(_ card: Entity){
        var flipDownTransform = card.transform
        
        flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
        
        var cardComponent = card.components[CardComponent.self] as! CardComponent
        cardComponent.flipped = false
        card.components[CardComponent.self] = cardComponent
        
        _ = card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
    }
}

