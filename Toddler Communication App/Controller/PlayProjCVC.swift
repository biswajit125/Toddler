//
//  PlayProjCVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 08/04/24.
//

import UIKit

class PlayProjCVC: UICollectionViewCell {
    @IBOutlet weak var imgOne: UIImageView!
    @IBOutlet weak var imgTwo: UIImageView!
    @IBOutlet weak var imgThree: UIImageView!
    @IBOutlet weak var imgFour: UIImageView!
    @IBOutlet weak var lblTitleOne: UILabel!
    @IBOutlet weak var lblTitleTwo: UILabel!
    @IBOutlet weak var lblTitleThree: UILabel!
    @IBOutlet weak var lblTitleFour: UILabel!
    @IBOutlet weak var readBtnOne: CustomBtnToPlayImage!
    @IBOutlet weak var readBtnTwo: CustomBtnToPlayImage!
    @IBOutlet weak var readBtnThree: CustomBtnToPlayImage!
    @IBOutlet weak var readBtnFour: CustomBtnToPlayImage!
    
    override func awakeFromNib() {
        lblTitleOne.isHidden = true
        lblTitleTwo.isHidden = true
        lblTitleThree.isHidden = true
        lblTitleFour.isHidden = true
    }
}
