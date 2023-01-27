//
//  ViewController.swift
//  getPairs
//
//  Created by Victor Kim on 2023-01-17.
//  Copyright © 2023 Victor Kim. All rights reserved.
//

import Photos
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pingButton: UIButton!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var lastImage: UIImageView!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var deleteImagesButton: UIButton!
   var baseurl: String = "http://localhost:8080/" //"https://serverimage.onrender.com/"
    
    override func viewDidLoad() {
           super.viewDidLoad()

           // add trigger when button touched call function buttonTapped
           sendButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
           pingButton.addTarget(self, action:#selector(ping) , for: .touchUpInside)
        
           resultButton.addTarget(self, action: #selector(getResults) , for: .touchUpInside)
        
           deleteImagesButton.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)
        
    }
    
    @objc func ping() {
        guard let text = textInput.text, let n = Int(text) else {
                      // Show an error message or return
                      return
                  }
        
        let fetchOptions = PHFetchOptions()

        // Defines in what order to fetch all photos
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = n

        // Photos Framework to retrieve a collection of assets (i.e., images) from the user's photo library.
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var images = [UIImage]()
        
           assets.enumerateObjects { (asset, _, _) in
               let manager = PHImageManager.default()
               let options = PHImageRequestOptions()
               options.isSynchronous = true
               // imageData: an optional Data object containing the image data, or nil if the request failed.
               // sequence of bytes that represents the image.
               manager.requestImageData(for: asset, options: options) { (imageData, _, _, _) in
                    if let data = imageData {
                         if let image = UIImage(data: data) {
                             images.append(image)
                         }
                    }
                  }
            }
            
            
            // image are stored from newest to oldest for n images
            // reverse the order
            images.reverse()
        
            self.sendImage(images: images, n: n)
            
            // display first image in subset
            if let firstImage1 = images.first {
                firstImage.image=firstImage1
            }
            
            // display last image in subset
            if let lastImageN = images.last {
               lastImage.image = lastImageN
            }
    }
    
    // function that extracts text input given by user
    @objc func buttonTapped() {
            guard let text = textInput.text, let n = Int(text) else {
                // Show an error message or return
                return
            }
            retrieveRecentPhotos(n: n)
    }
    
    @objc func getResults() {
            // Make a GET request to the server to get the array of images
            let url = URL(string: baseurl+"results")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard let data = data else {
                    print("No data received")
                    return
                }
                do {
                    // Decode the received data as an array of images
                    let images = try JSONDecoder().decode([String].self, from: data)
                    for image in images {
                        // Decode the image data
                        let imageData = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!
                        // Create a UIImage from the decoded data
                        let uiImage = UIImage(data: imageData)
                        // Save the image to the Photos app
                        UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
    }
    
    @objc func deleteImages() {
        guard let url = URL(string: baseurl+"delete") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle response and error
            guard let data = data, error == nil else {
                print(error)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("RESPONSE HTTP")
                print(responseJSON)
                if(responseJSON["msg"] as? String == "deleted sucess !") {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Title", message: "all images images deleted !", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        task.resume()
    }
    
    func retrieveRecentPhotos(n: Int) {
     // Fetch options to retrieve the n most recent photos
     let fetchOptions = PHFetchOptions()

     // Defines in what order to fetch all photos
     fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
     fetchOptions.fetchLimit = n

     // Photos Framework to retrieve a collection of assets (i.e., images) from the user's photo library.
     let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

     var i = 0
     while i < assets.count {
         let asset1 = assets.object(at: i)
         let manager = PHImageManager.default()
         let options = PHImageRequestOptions()
         options.isSynchronous = true
         var firstImage: UIImage?
         manager.requestImage(for: asset1, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, _) in
             firstImage = image
         }

         i += 1
         if i >= assets.count {
             break
         }

         let asset2 = assets.object(at: i)
         var secondImage: UIImage?
         manager.requestImage(for: asset2, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, _) in
             secondImage = image
         }

         if let firstImage = firstImage, let secondImage = secondImage {
             let newImageSize = CGSize(width: firstImage.size.width + secondImage.size.width, height: max(firstImage.size.height, secondImage.size.height))
             UIGraphicsBeginImageContextWithOptions(newImageSize, false, 0.0)
             let firstImageRect = CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height)
             firstImage.draw(in: firstImageRect)
             let secondImageRect = CGRect(x: firstImage.size.width, y: 0, width: secondImage.size.width, height: secondImage.size.height)
             secondImage.draw(in: secondImageRect)
             let symmetricImage = UIGraphicsGetImageFromCurrentImageContext()
             UIImageWriteToSavedPhotosAlbum(symmetricImage!, nil, nil, nil)
             UIGraphicsEndImageContext()
             Thread.sleep(forTimeInterval: 5)
         }
         i += 1
     }

     // display first image in subset
     if let firstImage1 = firstImage {
         firstImage = firstImage1
     }

     // display last image in subset
     if let lastImageN = lastImage {
        lastImage = lastImageN
     }

    
    }
    
    func sendImage(images:[UIImage],n: Int) {
        for (index, image) in images.enumerated() {
        guard let url = URL(string: baseurl+"images") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"\r\n\r\n".data(using: .utf8)!)
            data.append(imageData.base64EncodedData())
            data.append("\r\n".data(using: .utf8)!)
        }
            
            let jsonObj: [String:Any]=["limit": String(n),"i":String(index)]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObj, options: [])
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        data.append(jsonData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle response and error
            guard let data = data, error ==  nil else {
                print(error)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("RESPONSE HTTP")
                print(responseJSON)
                if(responseJSON["msg"] as? Int == n) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Title", message: "all images uploaded !", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        task.resume()
        Thread.sleep(forTimeInterval: 0.5)
      }
      
    }
    

}


    


