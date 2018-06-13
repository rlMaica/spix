//
//  AlbumCollectionViewController.swift
//  SPIX
//
//  Created by Rodrigo Maicá on 07/06/17.
//  Copyright © 2017 BEASTROX. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class AlbumCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var key:String?
    var photos = [UIImage]()
    let picker = UIImagePickerController()
    
    let socket = SocketIOClient(socketURL: URL(string: "http://172.27.2.174:3000")!, config: [.log(true), .forcePolling(true)])

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = false
        
        addHandlers()
        self.socket.connect()
        self.socket.emit("join", self.key!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Suma infeliz!")
        self.socket.emit("disconnect", self.key!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandlers() {
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            
            // Sending messages
            self.socket.emit("join", self.key!)
            self.socket.emit("send-connected", self.key!)
        }
        
        socket.on("send-client") {data, ack in
            NSLog("Chegou algo!")
            NSLog("%s", data)
        }
//
//        
//        
//        self.socket.on("connect") {data, ack in
//            NSLog("socket connected")
//            
//            // Sending messages
//            self.socket.emit("join", self.key!)
//        }
//        
//        self.socket.on("send-client") {[weak self] data, ack in
//            NSLog("Chegou algo!")
//            NSLog("%s", data)
//        }
    }
    
    @IBAction func btnPhotos(_ sender: UIBarButtonItem) {
//        picker.allowsEditing = false
//        picker.sourceType = .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        NSLog("Chegou a imagem");
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        myImageView.contentMode = .scaleAspectFit //3
//        myImageView.image = chosenImage //4
        photos.append(chosenImage)
        self.collectionView?.reloadData()
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        NSLog("Cancelou...");
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celula = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = celula as? AlbumCollectionViewCell {
            // Configure the cell
            let imagem: UIImage? = photos[indexPath.row]
            cell.imagem = imagem
            
            return cell
        }
        return celula
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("Cliquei em uma foto")
        let json:Dictionary<String,AnyObject> = self.getPhoto(index: indexPath.row)
        
        self.socket.emit("send-server", json)
        
        return true
    }
    
    func getPhoto(index:Int) -> Dictionary<String,AnyObject> {
//        var imagem:UIImage!
//        let imageAsset:PHAsset = assets[index] as AnyObject! as! PHAsset
//        let opt:PHImageRequestOptions = PHImageRequestOptions()
//        opt.isSynchronous = true
//        
//        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize(width: largura, height: altura), contentMode: PHImageContentMode.aspectFit, options: opt) { (result, _) in
//            
//            imagem = result! as UIImage
//        }
        
        let imageData = UIImageJPEGRepresentation(ImageResize.Resize(image: self.photos[index], targetSize: CGSize(width: 1024, height: 768)), CGFloat(0.6))
        let imgData: NSData = NSData(data: imageData!)
        let tamanho:Int = imgData.length
        NSLog("Tamanho %ld", tamanho)
        
        let base64String:String = imageData!.base64EncodedString()
        
        let json:Dictionary<String,AnyObject> = ["key":self.key! as AnyObject, "index": index as AnyObject, "image": base64String as AnyObject, "size": String(tamanho) as AnyObject]
        
        return json
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
