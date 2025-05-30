//
//  CustomLocalContentOfProjModel.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 17/04/24.
//

import Foundation
import UIKit

struct CustomLocalContentOfProjModel {
    var image: UIImage?
    var title: String = ""
}

//used to brake the images and titles into 4/4 array
struct ArrayOfArrayProjModel {
    var image: Data?
    var title: String = ""
}

//used for editing
struct CustomLocalContentOfProjForEditingModel {
    var hId: UUID?
    var image: UIImage?
    var title: String = ""
}
