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
import AWSS3
import AWSDynamoDB

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var CelebImageView: UIImageView!
    
    @IBOutlet weak var MatchedPhone: UILabel!
    @IBOutlet weak var MatchedEmail: UILabel!
    @IBOutlet weak var MatchedName: UILabel!
    @IBOutlet weak var FoundPhoto: UIImageView!
    @IBOutlet weak var CelebLabel: UILabel!
    var infoLinksMap: [Int:String] = [1000:""]
    var rekognitionObject:AWSRekognition?
    var imageIDNumber : String = "NotMatched"
    var numberToCall : String = "5029997799"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let celebImage:Data = UIImageJPEGRepresentation(CelebImageView.image!, 0.2)!
        //sendImageToRekognition(celebImageData: celebImage)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Actions
    @IBAction func CameraOpen(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true)
    }
    
    @IBAction func PhotoLibraryOpen(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        CelebImageView.image = image

        let celebImage:Data = UIImageJPEGRepresentation(image, 0.2)!
        
        //Demo Line
        sendImageToRekognition(celebImageData: celebImage)
    }
    
    
    //MARK: - AWS Methods
    func sendImageToRekognition(celebImageData: Data){
        self.CelebLabel.text = "Searching Database"
        
        rekognitionObject = AWSRekognition.default()
        let celebImageAWS = AWSRekognitionImage()
        celebImageAWS?.bytes = celebImageData
       
        let imageSearchRequest = AWSRekognitionSearchFacesByImageRequest()
        imageSearchRequest?.collectionId = "MissingPersons"
        imageSearchRequest?.faceMatchThreshold = 89.52
        imageSearchRequest?.image = celebImageAWS
        _ = AWSRekognitionSearchFacesResponse()
        rekognitionObject?.searchFaces(byImage: imageSearchRequest!, completionHandler: { (responseSearchFace, error) in
                let matchedFaces = responseSearchFace?.faceMatches
            if matchedFaces?.count == 0 {
                 self.CelebLabel.text = "Not a match"
                print("Not matched")
                DispatchQueue.main.async(execute: {
                    self.FoundPhoto.image = UIImage(named: "NotMatched.jpg")
                    self.CelebLabel.text = "Not Matched"
                })
                // successCallback(image)
            }

             else {
                
           //     for (index, face) in matchedFaces!.enumerated() {
                self.imageIDNumber = (matchedFaces?[0].face?.externalImageId)!
                self.readPerson()
                print("Item: \(matchedFaces![0].similarity) Pct")
                    DispatchQueue.main.async(execute: {
                        
                        self.CelebLabel.text = "Matched "  + (self.imageIDNumber) + " " + (matchedFaces![0].similarity?.stringValue)! + " Pct"
                       print(matchedFaces?[0].face?.externalImageId)
                        self.view.bringSubview(toFront: self.CelebLabel)
                     })
                        

                    let transferManager     = AWSS3.default()
                    let getImageRequest     = AWSS3GetObjectRequest()
                
                    getImageRequest?.bucket = "shreyascompareimages"
                    getImageRequest?.key    = self.imageIDNumber
                
                transferManager.getObject(getImageRequest!).continueWith(executor: AWSExecutor.mainThread()) { (anandt) -> Void in
                        
                        if anandt.error == nil {
                            if let imageData = anandt.result?.body as? Data, let image = UIImage(data: imageData) {
                                DispatchQueue.main.async(execute: {
                                self.FoundPhoto.image = UIImage(data:imageData )
                                })
                               // successCallback(image)
                            } else {
                                print("Download failed")
                            }
                        } else {
                            
                            let error = "Error \(anandt.error?.localizedDescription ?? "unknown by dev")"
                            print (error)
                            //errorCallback(error)
                        }
                    
                    }
                       
                    
                //}
                    
                
                }
           
           
            })
        
     
    }
   /*
    @objc func handleTap(sender:UIButton){
        print("tap recognized")
        let celebURL = URL(string: self.infoLinksMap[sender.tag]!)
        let safariController = SFSafariViewController(url: celebURL!)
        safariController.delegate = self
        self.present(safariController, animated:true)
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        print ("It came inside")
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
 */
    
    
    func readPerson() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let personItem: PersonDetails = PersonDetails();
       // personItem.userId = AWSIdentityManager.default().identityId
        print("ID Number: \(self.imageIDNumber)")
        
        
        
        
        dynamoDbObjectMapper.load(PersonDetails.self, hashKey: self.imageIDNumber, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultPerson = task.result as? PersonDetails {
                // Do something with task.result.
                
                
                DispatchQueue.main.async(execute: {
                    
                    self.MatchedName.text = resultPerson._name
                    self.MatchedEmail.text = resultPerson._email!
                    self.MatchedPhone.text = resultPerson._phone
                    //self.MatchedPhone.text = resultPerson._phone!
                    
                 /*
                    let attributedString = NSMutableAttributedString(string: resultPerson._phone!)
                    let url = URL(string: urlPhone)
                    
                    // Set the 'click here' substring to be the link
                    attributedString.setAttributes([.link: url], range: NSMakeRange(1, 16))
                    
                    self.MatchedPhone.attributedText = attributedString
                    
                    self.MatchedPhone.isUserInteractionEnabled = true
                    // self.TextDisplay. = true
                    
                    // Set how links should appear: blue and underlined
                   // self.MatchedPhone.textColor.cgColor = GL_BLUE
                    
                   */
                
                })
            } else {
                print ("Nothing returned")
            }
            return nil
        })
        
        /*
        dynamoDbObjectMapper.load(
            PersonDetails.self,
            hashKey: self.imageIDNumber,
            rangeKey: nil,
            completionHandler: {
                (objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Read Error: \(error)")
                    print("Name \(personItem._name)")

                    return
                }
                 self.MatchedName.text = personItem._name
                 self.MatchedEmail.text = personItem._email
                 self.MatchedPhone.text = dialNumber(personItem._phone)
                print("Name \(personItem._name)")
                print("An item was read.")
        })*/
    }
    
    
    
}
func dialNumber(number : String) {
    
    if let url = URL(string: "tel://\(number)"),
        UIApplication.shared.canOpenURL(url) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    } else {
        // add error message here
    }
    
}
