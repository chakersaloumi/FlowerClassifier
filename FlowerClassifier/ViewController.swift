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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //constants for API requests
    let WIKI_URL = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet var imageDisplayed: UIImageView!
    //imageTaken
    let imageTaker = UIImagePickerController()
    //Information Field
    @IBOutlet var flowerInfoField: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Setting as delegate
        imageTaker.delegate = self
        //using camera
        imageTaker.sourceType = .camera
        //Allow editing
        imageTaker.allowsEditing = true
        
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
        
        //dismiss camera after taking picture
        imageTaker.dismiss(animated: true, completion: nil)
        
    }
    
    func detectFlower(flowerImage image: CIImage){
        
        //load model
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading model failed")
        }
        
        //create a request to the model
        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results =  request.results as? [VNClassificationObservation] else { // classification analysis processed by the request
                fatalError("Processing model failed ")
            }
            
            if let mostProbableFlower = results.first {
                self.navigationItem.title = mostProbableFlower.identifier.capitalized
                let parameters : [String:String] = [
                    "format" : "json",
                    "action" : "query",
                    "prop" : "extracts",
                    "exintro" : "",
                    "explaintext" : "",
                    "titles" : mostProbableFlower.identifier,
                    "indexpageids": "",
                    "redirects" : "1"]
                
                self.getFlowerInfo(url: self.WIKI_URL, parameters: parameters)
                
            }
        }
        
        //do a request to the model by feeding him a request
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
    
    //MARK: - Networking
    
    func getFlowerInfo(url: String, parameters: [String:String]){
        
        //HTTP Request
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess{
                
                print("Request Successful")
                let flowerInfoJSON : JSON = JSON(response.result.value!)
                self.parseJSONfile(JSONinfo: flowerInfoJSON)
            } else {
                print ("Error \(String(describing: response.result.error))")
                print("connection issues")
            }
        }
        
    }
    
    func parseJSONfile(JSONinfo: JSON){
        //parsing the JSON file
        if let pageID = JSONinfo["query"]["pageids"][0].int {
            flowerInfoField.text = JSONinfo["query"]["pages"][String(pageID)]["extract"].stringValue
        }else {
            flowerInfoField.text="Flower information Unavailable"
            print("Page ID is nil")
        }
        
    }
    
}

