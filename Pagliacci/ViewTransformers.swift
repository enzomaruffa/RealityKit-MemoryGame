//
//  VixewTransformers.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 29/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit

class ViewTransformers {
    
    static func styleButton(view: UIView) {
        view.layer.cornerRadius = 9
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 3
    }
    
    static func styleMessage(view: UIView) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 3
    }
    
}
