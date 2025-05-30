//
//  EditProjectsCVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 05/04/24.
//

import UIKit

class EditProjectsCVC: UICollectionViewCell {
    @IBOutlet weak var vwTitleContainer: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var btnEditTitle: UIButton!
    
    override func awakeFromNib() {
        vwTitleContainer.layer.cornerRadius = 22.5
        vwTitleContainer.layer.borderColor = UIColor.lightGray.cgColor
        vwTitleContainer.layer.borderWidth = 1
        
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowRadius = 4
        vwContainer.layer.shadowOpacity = 0.25
        vwContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        btnEdit.layer.cornerRadius = 20
        btnDelete.layer.cornerRadius = 20
    }
    
}
