//
//  SeeImgInNewProjCVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 03/04/24.
//

import UIKit

class SeeImgInNewProjCVC: UICollectionViewCell {
    @IBOutlet weak var txtTitleField: UITextField!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwTitleContainer: UIView!
    @IBOutlet weak var imgImageView: UIImageView!
    
    override func awakeFromNib() {
        vwTitleContainer.layer.cornerRadius = 22.5
        vwTitleContainer.layer.borderColor = UIColor.lightGray.cgColor
        vwTitleContainer.layer.borderWidth = 1
        
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowRadius = 4
        vwContainer.layer.shadowOpacity = 0.25
        vwContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
}
