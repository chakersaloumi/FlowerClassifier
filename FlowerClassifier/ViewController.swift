//
//  ViewController.swift
//  FlowerClassifier
//
//  Created by Chaker on 8/24/19.
//  Copyright © 2019 Chaker Saloumi. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var imageDisplayed: UIImageView!
    //imageTaken
    let imageTaker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Setting as delegate
        imageTaker.delegate = self
        //using camera
        imageTaker.sourceType = .camera
        //No editing
        imageTaker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageDisplayed.image = userImage
            //convert userImage
            guard let ciimage = CIImage(image: userImage) else {
                fatalError("Error converting Image ")
            }
            
            //feed the image to the detection function
            detectFlower(flowerImage: ciimage)
            
        }
        
        imageTaker.dismiss(animated: true, completion: nil)
        
    }
    
    func detectFlower(flowerImage image: CIImage){
        
        //load model
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results =  request.results as? [VNClassificationObservation] else { // classification analysis processed by the request
                fatalError("Processing model failed ")
            }
            
            if let mostProbableFlower = results.first {
                self.navigationItem.title = mostProbableFlower.identifier.capitalized
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            
            try! handler.perform([request])
            
        } catch {
            
            print(error)
        }
        
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imageTaker, animated: true, completion: nil)
    }
    
}

