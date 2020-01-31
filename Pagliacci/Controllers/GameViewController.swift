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
    
    @IBOutlet weak var messagesContainer: UIView!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var messagesContainerTrailing: NSLayoutConstraint!
    
    var isMessagesHidden: Bool {
        messagesContainerTrailing.constant != 0
    }
    var firstClose: Bool = false
    
    private let pairsMessages: [String] = ["Um novo par foi adicionado na coleção!", "Descubra a história da carta no menu :)", "Parabéns!"]
    
    private var models: [Card] = CardSingleton.shared.cards
    private var cardsUp: [Entity] = []
    private var cards: [Entity] = []
    private var c: Cancellable?
    
    var scaleFactor: Float?
    
    let baseText = "Pairs: "
    var pairsMade = 0
    
    var baseAnchorEntity: AnchorEntity?
    var occlusionBox: Entity?
    
    var cheaterFound = false
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewTransformers.styleButton(view: goBackContainer)
        ViewTransformers.styleButton(view: topBarContainer)
        ViewTransformers.styleMessage(view: messagesContainer)
    
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
        
        if !cheaterFound {
           createOcclusionBox(boundSize, planeAnchorEntity)
        }
        
        pairsMade = models.filter({ $0.revealed }).count
        updatePairsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        c = arView.scene.subscribe(to: SceneEvents.Update.self) { (event) in
            let cameraPosition = self.arView.cameraTransform.translation
            
            for card in self.cards where card.components[CardComponent.self] != nil {
                let cardComponent = card.components[CardComponent.self] as! CardComponent
                
                if cardComponent.matched {
                    
                    let totalDistance = self.distance(from: cameraPosition, to: card.position(relativeTo: self.baseAnchorEntity!))
                    
                    if totalDistance < 0.25 && card.children.isEmpty {
                        self.generateText(cardComponent, card)
                    } else if totalDistance >= 0.25 && !card.children.isEmpty {
                        card.children.removeAll()
                    }
                    
                }
            }
            
            if let planeAnchor = self.arView.scene.anchors.filter({ $0 != self.baseAnchorEntity }).first {
                // Connected and firstClose not happened
                if planeAnchor.isAnchored && !self.firstClose {
                    self.hideMessagesContainer()
                    self.firstClose = true
                } else if !planeAnchor.isAnchored && self.isMessagesHidden {
                    self.showMessagesContainer()
                    
                }
            }
            
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        c?.cancel()
    }
    
    // MARK: Helpers
    private func distance(from origin: SIMD3<Float>, to end: SIMD3<Float>) -> Float {
        
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
        
        scaleFactor = boundSize / sqrt(Float(cardModels.count * 2))
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
        
        print("Cloning cards...")
        for cardTemplate in cardTemplates {
            for index in 1...2 {
                let clonedCard = cardTemplate.clone(recursive: true)
                clonedCard.name = clonedCard.name + "-" + index.description
                cards.append(clonedCard)
                
                var rotateTransform = clonedCard.transform
                rotateTransform.rotation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
                clonedCard.transform = rotateTransform
                
                if clonedCard.components[CardComponent.self] != nil {
                    var cardComponent = clonedCard.components[CardComponent.self] as! CardComponent

                    print("Checking if revealed...")
                    if cardComponent.card!.revealed {
                        print("Flipping up card!")
                        flipUp(clonedCard, animated: false)

                        // Updates component
                        cardComponent.matched = true
                        clonedCard.components[CardComponent.self] = cardComponent
                    }
                }
                
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
        
        self.occlusionBox = occlusionBox
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
            
            // Updates Singleton
            CardSingleton.shared.setCardMatched(byCardName: cardComponent.card!.name)
            
            if cardComponent.card!.name == "Cheater" {
                self.occlusionBox?.removeFromParent()
                self.cheaterFound = true
            }
        })
        
        pairsMade += 1
        updatePairsLabel()
        
        if pairsMade == models.count {
            showMessagesContainer(changingTextTo: "E esses são todos os pares! Parabéns :-]")
        } else {
            showMessagesContainer(changingTextTo: pairsMessages.randomElement()!)
        }
        
        self.cardsUp.removeAll()
    }
    
    fileprivate func dismissMatch() {
        print("Dismissing!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.cardsUp.forEach({ self.flipDown($0) })
            self.cardsUp.removeAll()
        }
    }
    
    
    private func flipUp(_ card: Entity, animated: Bool = true){
        var flipUpTransform = card.transform
        
        flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [0, 0, 1])
        flipUpTransform.rotation *= simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        if animated {
            _ = card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        } else {
            card.transform = flipUpTransform
        }
        
        
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
    
    func hideMessagesContainer(duration: TimeInterval = 2) {
        let containerSize = messagesContainer.frame.width
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            self.messagesContainerTrailing.constant = -(containerSize + 30)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showMessagesContainer(duration: TimeInterval = 1) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.messagesContainerTrailing.constant = 0
        }, completion: nil)
    }
    
    func showMessagesContainer(duration: TimeInterval = 1, changingTextTo text:  String) {
        messagesLabel.text = text
        showMessagesContainer()
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
    
    @IBAction func messagesTapped(_ sender: Any) {
        if !isMessagesHidden {
            hideMessagesContainer()
        }
    }
    
    
}

