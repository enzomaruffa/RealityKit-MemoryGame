//
//  MenuViewController.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 28/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var playContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playContainer.layer.cornerRadius = 9
        
        playContainer.layer.shadowColor = UIColor.black.cgColor
        playContainer.layer.shadowOpacity = 0.5
        playContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        playContainer.layer.shadowRadius = 2

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
