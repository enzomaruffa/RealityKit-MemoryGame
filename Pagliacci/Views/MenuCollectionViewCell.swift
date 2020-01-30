//
//  MenuCollectionViewCell.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 30/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupCell(with card: Card) {
        
        imageView.layer.cornerRadius = 40
        
        if card.revealed {
            print("Using correct asset...")
            imageView.image = UIImage(named: card.assetName)
        } else {
            print("Using default asset...")
            imageView.image = UIImage(named: Card.defaultCardAssetName)
        }
    }
}
