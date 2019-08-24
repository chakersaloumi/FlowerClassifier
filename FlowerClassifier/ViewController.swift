//
//  ViewController.swift
//  FlowerClassifier
//
//  Created by Chaker on 8/24/19.
//  Copyright © 2019 Chaker Saloumi. All rights reserved.
//

import UIKit
import Vision

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
        }
        
        imageTaker.dismiss(animated: true, completion: nil)
        
    }


    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imageTaker, animated: true, completion: nil)
    }
    
}

