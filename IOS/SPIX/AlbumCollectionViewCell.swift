//
//  AlbumCollectionViewCell.swift
//  SPIX
//
//  Created by Rodrigo Maicá on 21/06/17.
//  Copyright © 2017 BEASTROX. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var AlbumImage: UIImageView!
    
    var imagem: UIImage? {
        didSet {
            AlbumImage.image = imagem
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imagem = nil
        self.AlbumImage?.image = nil
    }
    
}
