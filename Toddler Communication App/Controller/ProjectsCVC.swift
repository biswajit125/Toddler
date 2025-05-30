//
//  ProjectsCVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 03/04/24.
//

import UIKit

class ProjectsCVC: UICollectionViewCell {
    @IBOutlet weak var vwCellContainer: UIView!
    @IBOutlet weak var lblProjectTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwActionContainer: UIStackView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    override func awakeFromNib() {
        vwCellContainer.layer.cornerRadius = 15
        
        btnAdd.layer.shadowColor = UIColor.black.cgColor
        btnAdd.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnAdd.layer.shadowOpacity = 0.5
        btnAdd.layer.shadowRadius = 2
        
        btnEdit.layer.shadowColor = UIColor.black.cgColor
        btnEdit.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnEdit.layer.shadowOpacity = 0.5
        btnEdit.layer.shadowRadius = 2
        
        btnDelete.layer.shadowColor = UIColor.black.cgColor
        btnDelete.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnDelete.layer.shadowOpacity = 0.5
        btnDelete.layer.shadowRadius = 2
    }
}
