//
//  UIViewController+Alert.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 15/04/24.
//

import Foundation
import UIKit

//'Ok' action default alert to show message with no action.
extension UIViewController {
    func showAlert(withMsg: String) {
        let alert = UIAlertController(title: withMsg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func showAlertWithAction(msg: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true)
    }
    
}
