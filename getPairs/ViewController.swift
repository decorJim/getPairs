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
    
    
    override func viewDidLoad() {
           super.viewDidLoad()

           // add trigger when button touched call function buttonTapped
           sendButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
           pingButton.addTarget(self, action:#selector(ping) , for: .touchUpInside)
        
           resultButton.addTarget(self, action: #selector(getResults) , for: .touchUpInside)
        
           deleteImagesButton.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)
        
    }
    
    @objc func ping() {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // ARRAY OF ASSET
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    
        guard let lastAsset = fetchResult.firstObject else {
            print("No recent images found.")
            return
        }
        
        let manager = PHImageManager()
        let options = PHImageRequestOptions()
        
        options.isSynchronous = true
        
        var lastImage = UIImage()
        
        manager.requestImageData(for: lastAsset, options: options) { (imageData, dataUTI, orientation, info) in
                   if let data = imageData {
                        if let image = UIImage(data: data) {
                           lastImage = image
                        }
                   }
        }
    
        var id="2di29j3fdi"
        
        guard let urltoping = URL(string: "http://localhost:8080/image") else {
            return
        }
        var request = URLRequest(url: urltoping)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var data = Data()
        
        if let imageData = lastImage.jpegData(compressionQuality: 1.0) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"\r\n\r\n".data(using: .utf8)!)
            //data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData.base64EncodedData())
            data.append("\r\n".data(using: .utf8)!)
        }
        
        let jsonObj: [String:Any]=["text":"some text sequence"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObj, options: [])
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        data.append(jsonData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
            guard let data = data, error == nil else {
                print(error)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("RESPONSE HTTP")
                print(responseJSON)
            }
        }
        task.resume()
        
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
            let url = URL(string: "http://localhost:8080/results")!
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
        guard let url = URL(string: "http://localhost:8080/delete") else {
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
            }
        }
        task.resume()
    }
    
    func retrieveRecentPhotos(n: Int) {
      // Fetch options to retrieve the n most recent photos
       let fetchOptions = PHFetchOptions()
        
       // defines in what order to fetch in all photos
       fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
       fetchOptions.fetchLimit = n
       
       // Photos Framework to retrieve a collection of assets (i.e., images) from the user's photo library.
       let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    
      // Create an array to store the selected images
       var images = [UIImage]()
    
       // Retrieve the image data for each asset
        
       // iterate through the assets in the assets variable
       // For each asset, the code creates a new PHImageManager object, which is used to retrieve the image data for the asset. The PHImageManager is a class that provides methods to request image and video data for assets.
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
        
        // display first image in subset
        if let firstImage1 = images.first {
            firstImage.image=firstImage1
        }
        
        // display last image in subset
        if let lastImageN = images.last {
           lastImage.image = lastImageN
        }
        
        sendImage(images: images,n: n)
        
    }
    
    func sendImage(images:[UIImage],n: Int) {
        for (index, image) in images.enumerated() {
        guard let url = URL(string: "http://localhost:8080/images") else {
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
            
        let jsonObj: [String:Any]=["limit": String(n)]
        
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


    


