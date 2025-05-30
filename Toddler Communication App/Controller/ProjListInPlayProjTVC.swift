//
//  ProjListInPlayProjTVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 19/04/24.
//

import UIKit

class ProjListInPlayProjTVC: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var txtProjNm: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowRadius = 2
        vwContainer.layer.shadowOpacity = 0.3
        vwContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
