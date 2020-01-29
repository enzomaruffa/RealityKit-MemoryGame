//
//  MenuViewController.swift
//  Pagliacci
//
//  Created by Enzo Maruffa Moreira on 28/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {
    
    // MARK: - Variables
    private var models = CardSingleton.shared.cards
    
    // MARK: - Variable Outlets
    @IBOutlet weak var playContainer: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var descriptionContainer: UIView!
    
    @IBOutlet weak var leftBack: UIImageView!
    @IBOutlet weak var rightBack: UIImageView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Camera Preview
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Constraints
    @IBOutlet weak var descriptionViewHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewTransformers.styleButton(view: playContainer)
        ViewTransformers.styleButton(view: descriptionContainer)
        // Do any additional setup after loading the view.
        
        let defaultTransform = CGAffineTransform(rotationAngle: .pi/2)
        leftBack.transform = defaultTransform
        rightBack.transform = defaultTransform
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
    }
    
    func setupLivePreview() {
        print("Previewing...")
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // MARK: - Outlets
    @IBAction func tapPressed(_ sender: Any) {
        
        let duration = 0.4
        
        if descriptionViewHeight.constant == 0 {
            let transform = CGAffineTransform(rotationAngle: 3 * .pi/2)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.descriptionViewHeight.constant = 120
                self.leftBack.transform = transform
                self.rightBack.transform = transform
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            let transform = CGAffineTransform(rotationAngle: .pi/2)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.descriptionViewHeight.constant = 0
                self.leftBack.transform = transform
                self.rightBack.transform = transform
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    
    // MARK: - Collection View
    
    private func updateDescriptionContainer(title: String, description: String, timeFound: Bool) {
        descriptionTitle.text = timeFound ? title : String(title.shuffled())
        descriptionTextView.text = timeFound ? description : "Find the time card first!\nPlay the game!\n" + String(description.shuffled())
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
