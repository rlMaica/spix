//
//  SlideCollectionViewController.swift
//  SPIX
//
//  Created by Rodrigo Maicá on 3/27/15.
//  Copyright (c) 2015 BEASTROX. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifierImage = "CellImage"

class SlideCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var key:String?
    
    var indexSelecionado:Int = 0
    let options = PHFetchOptions()
    var assets = PHFetchResult<AnyObject>()
    
    var largura:CGFloat = UIScreen.main.bounds.width
    var altura:CGFloat = UIScreen.main.bounds.height
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let socket = SocketIOClient(socketURL: URL(string: "10.1.43.36:3000")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.options.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options) as! PHFetchResult<AnyObject>
        
        self.addHandlers()
        self.socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.scrollToItem(at: NSIndexPath.init(index: self.indexSelecionado) as IndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addHandlers() {
        self.socket.on("connect") {data, ack in
            print("socket connected")
            
            // Sending messages
            self.socket.emit("join", self.key!)
            self.photoStart()
//            self.socket.emit("send-server", "{key: \(self.key!) }")
        }
        
        self.socket.on("send-client") {[weak self] data, ack in
            print("Chegou algo!")
            print(data)
        }
    }
    
    func photoStart() -> Void {
        let imagemBase64:String = self.getPhoto(index: self.indexSelecionado)
        let json:Dictionary<String,AnyObject> = ["key":self.key! as AnyObject, "index": self.indexSelecionado as AnyObject, "image": imagemBase64 as AnyObject]
        
        self.socket.emit("send-server", json)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierImage, for: indexPath as IndexPath) as! SlideCollectionViewCell
    
        // Configure the cell
        let imageAsset:PHAsset = assets[indexPath.row] as AnyObject? as! PHAsset
        
        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize(width: largura, height: altura), contentMode: PHImageContentMode.aspectFit, options: nil) { (result, _) in
            
            cell.slideImage.image = result
            cell.slideImage.bounds = CGRect(x: 0, y: 0, width: self.largura, height: self.altura)
            cell.slideImage.center = collectionView.center
            cell.slideImage.contentMode = UIViewContentMode.scaleAspectFit
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.largura, height: self.altura)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("Foto: \(indexPath.row)")
    }
    
    func getPhoto(index:Int) -> String {
        var imagem:UIImage!
        let imageAsset:PHAsset = assets[index] as AnyObject? as! PHAsset
        let opt:PHImageRequestOptions = PHImageRequestOptions()
        opt.isSynchronous = true
        
        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize(width: largura, height: altura),
                                              contentMode: PHImageContentMode.aspectFit, options: opt) { (result, _) in
            
            imagem = result! as UIImage
        }
        
        let imageData = UIImageJPEGRepresentation(ImageResize.Resize(image: imagem, targetSize: CGSize(width: 1024, height: 768)), CGFloat(0.6))
        NSLog("Tamanho %ld", imageData!.count)
        
        let base64String:String = imageData!.base64EncodedString()
    
        return base64String
    }

}
