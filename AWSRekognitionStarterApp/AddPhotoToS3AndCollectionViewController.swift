//
//  AddPhotoToS3AndCollectionViewController.swift
//  AWSRekognitionStarterApp
//
//  Created by Shreyas Kar on 2/6/19.
//  Copyright © 2019 AWS. All rights reserved.
//

import UIKit
import SafariServices
import AWSRekognition
import AWSS3
import AWSCore
import AWSDynamoDB



    class AddPhotoToS3AndCollectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
        
        @IBOutlet weak var EmailAddress: UITextField!
        
        @IBOutlet weak var PhoneNumber: UITextField!
        @IBOutlet weak var StatusLabel: UILabel!
        @IBOutlet weak var progressView: UIProgressView!
        @IBOutlet weak var PhotoToBeAdded: UIImageView!
        @IBOutlet weak var NameToBeAdded: UITextField!
        var progressBlock: AWSS3TransferUtilityProgressBlock?
        var infoLinksMap: [Int:String] = [1000:""]
        var rekognitionObject:AWSRekognition?
        var photoName = "SomeName"
        var imageURL : URL?
        override func viewDidLoad() {
            super.viewDidLoad()
            self.progressView.progress = 0.0;
            self.StatusLabel.text = "Ready"
            // self.imagePicker.delegate = self
            
            self.progressBlock = {(task, progress) in
                DispatchQueue.main.async(execute: {
                    if (self.progressView.progress < Float(progress.fractionCompleted)) {
                        self.progressView.progress = Float(progress.fractionCompleted)
                    }
                })
                
            
        }
            self.hideKeyboardWhenTappedAround()
            
    }
       /* func dismissKeyboard() {
            //Causes the view (or one of its embedded text fields) to resign the first responder status.
            view.endEditing(true)
        }
      */
            
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        
        //MARK: - Button Actions
        @IBAction func Camera(_ sender: Any) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.cameraCaptureMode = .photo
            present(pickerController, animated: true)
        }
       
        
        @IBAction func PhotoLib(_ sender: Any) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .savedPhotosAlbum
            present(pickerController, animated: true)
        }
     
        @IBAction func AddPhoto(_ sender: Any) {
           let imageTobeAdded:Data = UIImageJPEGRepresentation(self.PhotoToBeAdded.image!, 0.2)!
            
            var errorStr = false
           
            let alert = UIAlertView()
            if NameToBeAdded.text == "" {
                alert.title = "Enter a Name"
                alert.message = "Name cannot be blank"
                alert.addButton(withTitle: "Ok")
                alert.show()
                errorStr = true
            }
            if EmailAddress.text == "" {
                alert.title = "Enter Email"
                alert.message = "Email cannot be blank"
                alert.addButton(withTitle: "Ok")
                alert.show()
                errorStr = true
            }
            if PhoneNumber.text == "" {
                alert.title = "Enter Phone"
                alert.message = "Phone Number cannot be blank"
                alert.addButton(withTitle: "Ok")
                alert.show()
                errorStr = true
            }
            if errorStr == false {
                let formatter = DateFormatter()
                // initially set the format based on your datepicker date / server String
                formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                
                let myString = formatter.string(from: Date()) // string purpose I add here
                
                photoName = self.NameToBeAdded.text! + myString + ".jpg"
                
                sendImageToRekognition(celebImageData: imageTobeAdded)
                
               // createPersonalInfo()
            }
        }
        
        // MARK: - UIImagePickerControllerDelegate
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            dismiss(animated: true)
            
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                fatalError("couldn't load image from Photos")
            }
         
            PhotoToBeAdded.image = image
            
            let celebImage:Data = UIImageJPEGRepresentation(image, 0.2)!
            
            //Demo Line

           // sendImageToRekognition(celebImageData: celebImage)
        }
        
        
        
        
        //MARK: - AWS Methods
        func sendImageToRekognition(celebImageData: Data){
            //self.Message.text = "Adding to Database"
            //Delete older labels or buttons
            /* DispatchQueue.main.async {
             [weak self] in
             for subView in (self?.CelebImageView.subviews)! {
             subView.removeFromSuperview()
             }
             }
 
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let myString = formatter.string(from: Date()) // string purpose I add here
            // convert your string to date
            let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "dd-MMM-yyyy"
            // again convert your date to string
            let myStringafd = formatter.string(from: yourDate!)
            
            print(myStringafd)
 
            photoName = self.NameToBeAdded.text! + myString + ".jpg"
  */
            print ("Photo just after entering func \(photoName)")
            rekognitionObject = AWSRekognition.default()
            let celebImageAWS = AWSRekognitionImage()
            celebImageAWS?.bytes = celebImageData
           
                    
            let transferManager     = AWSS3TransferUtility.default()
            let configuration = AWSS3TransferUtilityConfiguration()
            configuration.bucket = "shreyascompareimages"
            
           // uploadRequest?.body = imageURL as! URL
           // uploadRequest!.key = photoName
           // uploadRequest!.bucket = "shreyascompareimages"
           // uploadRequest!.contentType = "image/jpg"
          //  uploadRequest!.acl = .publicRead
            let uploadExpression = AWSS3TransferUtilityUploadExpression()
            uploadExpression.progressBlock = self.progressBlock
            var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
            var progressBlock: AWSS3TransferUtilityProgressBlock?
            
            DispatchQueue.main.async(execute: {
                self.StatusLabel.text = ""
                self.progressView.progress = 0
            })
            transferManager.uploadData(celebImageData, bucket: "shreyascompareimages", key: photoName, contentType: "image/jpg", expression: uploadExpression, completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        self.StatusLabel.text = "Failed"
                    }
                }
                
                if let _ = task.result {
                    
                    DispatchQueue.main.async {
                        self.StatusLabel.text = "Uploading..."
                        print("Upload Starting!")
                    }
                    
                    // Do something with uploadTask.
                }
                print ("self.photoName\(self.photoName)")
                let indexFaceRequest = AWSRekognitionIndexFacesRequest()
                indexFaceRequest?.collectionId = "MissingPersons"
                indexFaceRequest?.externalImageId = self.photoName
                indexFaceRequest?.image = celebImageAWS
                //let responseIndexFace = AWSRekognitionSearchFacesResponse()
                self.rekognitionObject?.indexFaces(indexFaceRequest!, completionHandler: { (responseIndexFace, error) in
                    //Code for completionHandler
                    if error != nil {
                        print ("Index Error: \(error) photoName is \(self.photoName)")
                    } else {
                        print ("Indexed \(self.photoName)")
                        self.createPersonalInfo()
                    }
                })
                return nil;
            }
        }


                

           
            
            

        
        @objc func handleTap(sender:UIButton){
            print("tap recognized")
            let celebURL = URL(string: self.infoLinksMap[sender.tag]!)
            let safariController = SFSafariViewController(url: celebURL!)
            safariController.delegate = self
            self.present(safariController, animated:true)
        }
        
        func createPersonalInfo() {
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            //let obj = AWSDynamoDB.default()
            
            
            // Create data object using data models you downloaded from Mobile Hub
            let personalInfoItem: PersonDetails  = PersonDetails()
            
            // personalInfoItem.userId = AWSIdentityManager.default().identityId
            
            personalInfoItem._name = NameToBeAdded.text
            personalInfoItem._email = EmailAddress.text
            personalInfoItem._phone = PhoneNumber.text
            personalInfoItem._iDNumber = photoName
            //  newsItem.creationDate = NSDate().timeIntervalSince1970 as NSNumber
            
            //Save a new item
            /*  dynamoDbObjectMapper.save(personalInfoItem).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
             if let error = task.error as? NSError {
             print("The request failed. Error: \(error)")
             } else {
             // Do something with task.result or perform other operations.
             }
             return 1
             })
             
             */
            dynamoDbObjectMapper.save(personalInfoItem, completionHandler: {
                (error: Error?) -> Void in
                
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                }
                print("An item was saved.")
            })
        }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


    
}

