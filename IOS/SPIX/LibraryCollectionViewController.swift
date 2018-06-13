//
//  LibraryCollectionViewController.swift
//  SPIX
//
//  Created by Rodrigo Maicá on 3/27/15.
//  Copyright (c) 2015 BEASTROX. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier2 = "Cell"

class LibraryCollectionViewController: UICollectionViewController {
    
    var key:String?
    
    var indexAtual:Int = 0
    let options = PHFetchOptions()
    var assets = PHFetchResult<AnyObject>()
    
    let socket = SocketIOClient(socketURL: URL(string: "10.1.43.36:3000")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.options.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options) as! PHFetchResult<AnyObject>
        
        self.addHandlers()
        self.socket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandlers() {
        self.socket.on("connect") {data, ack in
            NSLog("socket connected")
            
            // Sending messages
            self.socket.emit("join", self.key!)
        }
        
        self.socket.on("send-client") {[weak self] data, ack in
            NSLog("Chegou algo!")
            NSLog("%s", data)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhoto") {
            let slideCollectionViewController = segue.destination as! SlideCollectionViewController
            slideCollectionViewController.indexSelecionado = self.indexAtual
            slideCollectionViewController.key = self.key
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return assets.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath as IndexPath) as! LibraryCollectionViewCell
    
        // Configure the cell
        let imageAsset:PHAsset = assets[indexPath.row] as AnyObject! as! PHAsset
        
        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: PHImageContentMode.aspectFit, options: nil) { (result, _) in
            
            cell.imageView.image = result
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        self.indexAtual = indexPath.row
        print("Imagem: \(indexPath.row)")
        self.socket.emit("join", indexPath.row)
        
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
