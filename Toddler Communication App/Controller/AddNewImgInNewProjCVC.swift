//
//  AddNewImgInNewProjCVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 03/04/24.
//

import UIKit

class AddNewImgInNewProjCVC: UICollectionViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    
    override func awakeFromNib() {
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowRadius = 4
        vwContainer.layer.shadowOpacity = 0.25
        vwContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
