//
//  GameViewController.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 24/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit
import RealityKit
import Combine
import ARKit

class GameViewController: UIViewController {
    
    // MARK: Variables
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var goBackContainer: UIView!
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var pairsLabel: UILabel!
    
    private var models: [Card] = CardSingleton.shared.cards
    private var cardsUp: [Entity] = []
    private var cards: [Entity] = []
    private var c: Cancellable?
    
    var scaleFactor: Float?
    
    let baseText = "Pairs: "
    var pairsMade = 0
    
    var baseAnchorEntity: AnchorEntity?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewTransformers.styleButton(view: goBackContainer)
        ViewTransformers.styleButton(view: topBarContainer)
        
        // Scene stuff
        CardComponent.registerComponent()
        
        let boundSize = Float(0.3)
        
        
        // cria aranchor no começp
        let baseAnchor = ARAnchor(transform: self.arView.cameraTransform.matrix)
        print("Base anchor created \(baseAnchor)")
        
        // cria anchorentity com base na aranchor
        let baseAnchorEntity = AnchorEntity(anchor: baseAnchor)
        arView.scene.addAnchor(baseAnchorEntity)
        print("Base anchor entity created \(baseAnchorEntity)")
        
        // cria a anchor de plano
        let planeAnchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [boundSize, boundSize])
        print("Plane anchor entity created \(planeAnchorEntity)")
        
        // adiciona como filha da primeira anchor
        arView.scene.addAnchor(planeAnchorEntity)
        self.baseAnchorEntity = baseAnchorEntity
        
        // calcula posicao dos cards com base na distancia da camera pra primeira ancora e da posicao das cartas em rleacao a primeira ancora
        
//        let planeAnchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [boundSize, boundSize])
//        arView.scene.addAnchor(planeAnchorEntity)
        
        createCards(boundSize, planeAnchorEntity)
        createOcclusionBox(boundSize, planeAnchorEntity)
        updatePairsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        c = arView.scene.subscribe(to: SceneEvents.Update.self) { (event) in
            let cameraPosition = self.arView.cameraTransform.translation
            
            for card in self.cards where card.components[CardComponent.self] != nil {
                let cardComponent = card.components[CardComponent.self] as! CardComponent
                
                if cardComponent.matched {
                    
                    //                    var cardPosition = SIMD3<Float>(card.position.x * 1/self.scaleFactor!,
                    //                                                    card.position.y * 1/self.scaleFactor!,
                    //                                                    card.position.z * 1/self.scaleFactor!)
                    
                    let totalDistance = self.distance(from: cameraPosition, to: card.position(relativeTo: self.baseAnchorEntity!))
                    
                    
                    print(totalDistance)
                    
                    if totalDistance < 0.25 && card.children.isEmpty {
                        self.generateText(cardComponent, card)
                    } else if totalDistance >= 0.25 && !card.children.isEmpty {
                        card.children.removeAll()
                    }
                    
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        c?.cancel()
    }
    
    // MARK: Helpers
    private func distance(from origin: SIMD3<Float>, to end: SIMD3<Float>) -> Float {
        
        print("Calculating distance from \(origin) to \(end)")
        
        let xD = (end.x) - (origin.x)
        let yD = (end.y) - (origin.y)
        let zD = (end.z) - (origin.z)
        
        return sqrt(xD * xD + yD * yD + zD * zD)
    }
    
    // MARK: Creators
    fileprivate func createCards(_ boundSize: Float, _ anchor: AnchorEntity) {
        // Loads cards
        var cardTemplates: [ModelEntity] = []
        
        let cardModels = models
        
        let cardNames = ["time", "apple", "completude", "enzo", "purple", "ufpr"]
        
        scaleFactor = boundSize / sqrt(Float(cardNames.count * 2 + 1))
        print("Scaling cards by \(scaleFactor!)")
        
        for cardModel in cardModels {
            let assetName = "card-" + cardModel.assetName
            let cardTemplate = try! Entity.loadModel(named: assetName)
            
            cardTemplate.setScale(SIMD3<Float>(repeating: scaleFactor!), relativeTo: nil)
            
            cardTemplate.generateCollisionShapes(recursive: true)
            
            cardTemplate.name = assetName
            
            cardTemplate.physicsBody = nil
            cardTemplate.components[CardComponent.self] = CardComponent()
            cardTemplate.components[CardComponent.self]?.card = cardModel
            
            cardTemplates.append(cardTemplate)
        }
        
        
        // Copies final cards
        var cards: [Entity] = []
        
        for cardTemplate in cardTemplates {
            for index in 1...2 {
                let clonedCard = cardTemplate.clone(recursive: true)
                clonedCard.name = clonedCard.name + "-" + index.description
                cards.append(clonedCard)
                
                var rotateTransform = clonedCard.transform
                rotateTransform.rotation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
                clonedCard.transform = rotateTransform
                
                self.cards.append(clonedCard)
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
    }
    
    fileprivate func createOcclusionBox(_ boundSize: Float, _ anchor: AnchorEntity) {
        // Box mesh
        let boxSize: Float = boundSize * 1.5
        let boxMesh = MeshResource.generateBox(size: boxSize)
        
        let material = OcclusionMaterial()
        
        let occlusionBox = ModelEntity(mesh: boxMesh, materials: [material])
        
        occlusionBox.position.y = -boxSize/2 - 0.001
        anchor.addChild(occlusionBox)
    }
    
    fileprivate func generateText(_ cardComponent: CardComponent, _ card: Entity) {
        
        let font = UIFont(name: "PerryGothic", size: 0.15)
        
        let textMesh = MeshResource.generateText(cardComponent.card?.shortText ?? "",
                                                 extrusionDepth: 0.01,
                                                 font: font!,
                                                 containerFrame: CGRect(x: 0, y: 0, width: 1, height: 20),
                                                 alignment: .center,
                                                 lineBreakMode: .byWordWrapping)
        
        let textEntity = ModelEntity(mesh: textMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
        
        var currentTextTransform = textEntity.transform
        currentTextTransform.rotation = simd_quatf(angle: .pi, axis: [0, 0, 1])
        currentTextTransform.rotation *= simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        textEntity.transform = currentTextTransform
        
        textEntity.setPosition(SIMD3<Float>(0, 0, 0.5), relativeTo: nil)
        
        card.addChild(textEntity)
    }
    
    
    // MARK: Functions
    fileprivate func completeMatch() {
        print("Match made!")
        
        self.cardsUp.forEach({
            var cardComponent = $0.components[CardComponent.self] as! CardComponent
            cardComponent.matched = true
            $0.components[CardComponent.self] = cardComponent
        })
        
        pairsMade += 1
        updatePairsLabel()
        
        self.cardsUp.removeAll()
    }
    
    fileprivate func dismissMatch() {
        print("Dismissing!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.cardsUp.forEach({ self.flipDown($0) })
            self.cardsUp.removeAll()
        }
    }
    
    
    private func flipUp(_ card: Entity){
        var flipUpTransform = card.transform
        
        flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [0, 0, 1])
        flipUpTransform.rotation *= simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        _ = card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        
        var cardComponent = card.components[CardComponent.self] as! CardComponent
        cardComponent.flipped = true
        card.components[CardComponent.self] = cardComponent
        
    }
    
    private func flipDown(_ card: Entity){
        var flipDownTransform = card.transform
        
        flipDownTransform.rotation = simd_quatf(angle: 0, axis: [0, 0, 1])
        flipDownTransform.rotation *= simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        _ = card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        
        var cardComponent = card.components[CardComponent.self] as! CardComponent
        cardComponent.flipped = false
        card.components[CardComponent.self] = cardComponent
    }
    
    func updatePairsLabel() {
        pairsLabel.text = baseText + pairsMade.description + "/" + models.count.description
    }
    
    
    // MARK: Outlets
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
                        firstCardComponent.card!.name == secondCardComponent.card!.name {
                        completeMatch()
                    } else {
                        dismissMatch()
                    }
                    
                    // Clears list
                }
            } else if cardComponent.matched {
                generateText(cardComponent, card)
            }
            
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
}

