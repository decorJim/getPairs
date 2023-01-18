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
           sendButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
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
       fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
       fetchOptions.fetchLimit = n
      // Rest of the code as before
       let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    
      // Create an array to store the selected images
       var images = [UIImage]()
    
       // Retrieve the image data for each asset
       assets.enumerateObjects { (asset, _, _) in
       let manager = PHImageManager.default()
       let options = PHImageRequestOptions()
       options.isSynchronous = true
       manager.requestImageData(for: asset, options: options) { (imageData, _, _, _) in
              if let data = imageData {
                   if let image = UIImage(data: data) {
                       images.append(image)
                   }
              }
           }
        }
        
        print(images)
        
        images.reverse()
        
        if let firstImage1 = images.first {
            firstImage.image=firstImage1
        }
        
        if let lastImageN = images.last {
           lastImage.image = lastImageN
        }

        print(images)
      }
}






    


