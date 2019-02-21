

import UIKit
import SafariServices
import AWSRekognition

class FaceAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var AgeRange: UILabel!
    
    @IBOutlet weak var sad: UILabel!
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var smiling: UILabel!
    
    @IBOutlet weak var disgusted: UILabel!
    @IBOutlet weak var happy: UILabel!
    
    @IBOutlet weak var confused: UILabel!
    
    @IBOutlet weak var angry: UILabel!
    
    @IBOutlet weak var surprised: UILabel!
    @IBOutlet weak var calm: UILabel!
    
    
    
    
    
    @IBOutlet weak var Photo: UIImageView!
    var rekognitionObject:AWSRekognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Button Actions
    
    @IBAction func CameraWork(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true)
    }
    
    @IBAction func PhotoLibrary(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
    
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let myImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
            
        }
        Photo.image = myImage
        let AnzImage:Data = UIImageJPEGRepresentation(myImage, 0.2)!
        //Demo Line
        analyzeImage(AnalyzedImageData: AnzImage)
    }
    
    func analyzeImage(AnalyzedImageData: Data){
        
        rekognitionObject = AWSRekognition.default()
        let ToBeAnalyzedImage = AWSRekognitionImage()
        ToBeAnalyzedImage?.bytes = AnalyzedImageData
        
        let anzRequest = AWSRekognitionDetectFacesRequest()
        anzRequest?.image  = ToBeAnalyzedImage
        anzRequest?.attributes = ["ALL"]
        
        let anzResponse = AWSRekognitionDetectFacesResponse()
        rekognitionObject?.detectFaces(anzRequest!, completionHandler: { (anzResponse, error) in
            
            print("response:\(anzResponse)")
            //print("count:\(anzResponse?.faceDetails?.count)")
            let ageRange = anzResponse?.faceDetails![0].ageRange
            print("Age range: \(ageRange)")

            
            var ageRangeString = "age"
            let ageRangeLow = ageRange?.low?.stringValue
            let ageRangeHigh = ageRange?.high?.stringValue
            ageRangeString = "Age: " + ageRangeLow! + " to " + ageRangeHigh!
            print ("ageRangeString: \(ageRangeString)")
            let gender = anzResponse?.faceDetails![0].gender?.value.rawValue
            var genderName = "Male"
            if gender == 1  {
                 genderName = "Male"
            }
            else {
                 genderName = "Female"
            }
            print ("gender \(genderName)")
            
            let smiling = anzResponse?.faceDetails![0].smile?.value?.boolValue
            var smilingName = "Smiling"
            if smiling == true {
                 smilingName = "Smiling: Yes"
            } else {
                  smilingName = "Smiling: No"
            }
            print("Smiling\(smilingName)")
            
            let emotions = anzResponse?.faceDetails![0].emotions
            var happyName = "Happy"
            var sadName = "Sad"
            var angryName = "Angry"
            var confusedName = "Confused"
            var disgustedName = "Surprised"
            var surprisedName = "Surprised"
            var calmName = "Calm"
            for (index, emotion) in emotions!.enumerated() {
                print ("Emotion is \(emotion)")
                if emotion.types.rawValue == 1 {
                    happyName = (round(emotion.confidence  as! Double)).description + "% Happy"
                } else if emotion.types.rawValue == 2 {
                    sadName = (round(emotion.confidence  as! Double)).description + "% Sad"
                } else if emotion.types.rawValue == 3 {
                    angryName = (round(emotion.confidence  as! Double)).description + "% Angry"
                } else if emotion.types.rawValue == 4 {
                    confusedName = (round(emotion.confidence  as! Double)).description + "% Confused"
                } else if emotion.types.rawValue == 5 {
                    disgustedName = (round(emotion.confidence  as! Double)).description + "% Disgusted"
                } else if emotion.types.rawValue == 6 {
                    surprisedName = (round(emotion.confidence as! Double)).description  + "% Surprised"
                } else if emotion.types.rawValue == 7 {
                    calmName = (round(emotion.confidence as! Double)).description + "% Calm"
                }
                
            }
            DispatchQueue.main.async(execute: {
                // UI Updates
                self.AgeRange.text = ageRangeString
                self.smiling.text = smilingName
                self.gender.text = genderName
                self.happy.text = happyName
                self.confused.text = confusedName
                self.angry.text = angryName
                self.surprised.text = surprisedName
                self.calm.text  = calmName
                self.disgusted.text = disgustedName
                self.sad.text = sadName

                //self.view.bringSubview(toFront: self.ResultLabel)
            })
            
            
        })
        
        
    }
}

