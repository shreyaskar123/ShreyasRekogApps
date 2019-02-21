/*
 * Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
import UIKit
import SafariServices
import AWSRekognition

class CompareTwoPicsTaken: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
    var whichCamera = "top"

    
    @IBOutlet weak var ResultLabel: UILabel!
    
    @IBOutlet weak var Image1: UIImageView!
    
    @IBOutlet weak var Image2: UIImageView!
    
    var infoLinksMap: [Int:String] = [1000:""]
    var rekognitionObject:AWSRekognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ResultLabel.text = "Let's match"
        
        // Do any additional setup after loading the view, typically from a nib.
        //let Image1:Data = UIImageJPEGRepresentation(self.Image1.image!, 0.2)!
     //   sendImageToRekognition(celebImageData: celebImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Button Actions
    
    @IBAction func Camera1(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true)
        whichCamera = "Top"
    }
    
    @IBAction func PhotoLib1(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
        whichCamera = "Top"
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let myImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }

        if (whichCamera == "Top") {
            Image1.image = myImage
        } else if (whichCamera == "Bottom") {
            Image2.image = myImage
        }
         //Demo Line
        //sendImageToRekognition(celebImageData: celebImage)
    }
    
    @IBAction func Camera2(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true)
        whichCamera = "Bottom"
    }
    
    @IBAction func PhotoLib2(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
        whichCamera = "Bottom"
    }
    
    @IBAction func ComparePics(_ sender: Any) {
        let compImage1:Data = UIImageJPEGRepresentation(self.Image1.image!, 0.2)!
        let compImage2:Data = UIImageJPEGRepresentation(self.Image2.image!, 0.2)!

         compareImagesUsingRekognition(celebImageData1: compImage1, celebImageData2: compImage2)
    }
    
    
    
   /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let bottomImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        Image2.image = bottomImage
        
        let celebImage:Data = UIImageJPEGRepresentation(bottomImage, 0.2)!
        
        //Demo Line
        //sendImageToRekognition(celebImageData: celebImage)
    }
    */
    //MARK: - AWS Methods

     
     
     func compareImagesUsingRekognition(celebImageData1: Data, celebImageData2: Data){
     //Delete older labels or buttons
     /* DispatchQueue.main.async {
     [weak self] in
     for subView in (self?.CelebImageView.subviews)! {
     subView.removeFromSuperview()
     }
     }
     */
     rekognitionObject = AWSRekognition.default()
     let celebImageAWS1 = AWSRekognitionImage()
     let celebImageAWS2 = AWSRekognitionImage()
     celebImageAWS1?.bytes = celebImageData1
     celebImageAWS2?.bytes = celebImageData2
     let compareRequest = AWSRekognitionCompareFacesRequest()
     compareRequest?.sourceImage = celebImageAWS1
     compareRequest?.targetImage = celebImageAWS2
     compareRequest?.similarityThreshold = 1
     var returnValue : Int = 0
     
        rekognitionObject?.compareFaces(compareRequest!, completionHandler: { (responseFace, error) in
            let matchedFaces = responseFace?.faceMatches
            if error != nil {
                print ("Error is \(error)")
                returnValue = 0
                return
            }
            print ("matchedFaces?.count \(matchedFaces?.count)")
            if (matchedFaces?.count)! < 1 {
                print("Not matched")
                returnValue = 0
                return
                
            } else {
                
                print ("Matched: \(matchedFaces?.first?.similarity)")
                
            
                returnValue = (matchedFaces?.first?.similarity?.intValue)!
                
                DispatchQueue.main.async(execute: {
                    // UI Updates
                    self.ResultLabel.text = String(returnValue) + " % Matched"
                    self.view.bringSubview(toFront: self.ResultLabel)
                })
                
                
                return
               /* for (index, face) in matchedFaces!.enumerated() {
                    print("Item \(index): \(face.similarity) Pct")
                    
                    
                }*/
            }
            
            
            
        })
        
     
     }
}


