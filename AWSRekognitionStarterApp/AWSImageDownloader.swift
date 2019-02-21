//
//  AWSImageDownloader.swift
//  AWSRekognitionStarterApp
//
//  Created by Sudip Kar on 2/6/19.
//  Copyright © 2019 AWS. All rights reserved.
//

import UIKit
import AWSRekognition
import AWSS3
import AWSCore


class AWSImageDownloader {
    
    init(AccessKey accessKey:String, SecretKey secretKey:String, andRegion region:AWSRegionType = .USEast2) {
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        guard let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider) else {
            debugPrint("Failed to configure")
            return
        }
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    /*
    func downloadImage(Name imageName:String, fromBucket bucketName:String){
        
        let transferManager     = AWSS3.default()
        let getImageRequest     = AWSS3GetObjectRequest()
        getImageRequest?.bucket = bucketName
        getImageRequest?.key    = imageName
        transferManager.getObject(getImageRequest!).continueWith(executor: AWSExecutor.mainThread()) { (anandt) -> Void in
     if anandt.error == nil {
     if let imageData = anandt.result?.body as? Data, let image = UIImage(data: imageData) {
     CelebImageView.image = UIImage(matchedImage)
     successCallback(image)
     } else {
     errorCallback("Download failed")
     }
     } else {
     
     let error = "Error \(anandt.error?.localizedDescription ?? "unknown by dev")"
     errorCallback(error)
     }

    }
 */
}
