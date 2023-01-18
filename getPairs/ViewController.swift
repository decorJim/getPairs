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

    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    @IBOutlet weak var firstImage: UIImageView!
    
    @IBOutlet weak var lastImage: UIImageView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           // add trigger when button touched call function buttonTapped
           sendButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // function that extracts text input given by user
    @objc func buttonTapped() {
            guard let text = textInput.text, let n = Int(text) else {
                // Show an error message or return
                return
            }
            retrieveRecentPhotos(n: n)
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
        
        
        print(images)
        
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

        print(images)
      }
}






    


