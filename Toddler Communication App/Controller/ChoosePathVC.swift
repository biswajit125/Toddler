//
//  ChoosePathVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 15/04/24.
//

import UIKit

class ChoosePathVC: UIViewController {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwParent: UIView!
    @IBOutlet weak var vwChild: UIView!
    @IBOutlet weak var lblChildName: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUiSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lblChildName.text = globalChildName ?? ""
        lblDob.text = "DOB: \(globalChildDob ?? "")"
    }

    @IBAction func parentBtnAction(_ sender: UIButton) {
        if let projVc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectsVC") as? ProjectsVC {
            projVc.accessType = .parent
            self.navigationController?.pushViewController(projVc, animated: true)
        }
    }
    @IBAction func childBtnAction(_ sender: UIButton) {
        if let projVc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectsVC") as? ProjectsVC {
            projVc.accessType = .child
            self.navigationController?.pushViewController(projVc, animated: true)
        }
    }
    @IBAction func profileBtnAction(_ sender: UIButton) {
        if let profileVc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            self.navigationController?.pushViewController(profileVc, animated: true)
        }
    }
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwContainer.layer.borderWidth = 5
        vwContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwContainer.layer.shadowOpacity = 0.35
        vwContainer.layer.shadowRadius = 3
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        vwParent.layer.shadowOpacity = 0.35
        vwParent.layer.shadowRadius = 3
        vwParent.layer.shadowColor = UIColor.black.cgColor
        vwParent.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        vwChild.layer.shadowOpacity = 0.35
        vwChild.layer.shadowRadius = 3
        vwChild.layer.shadowColor = UIColor.black.cgColor
        vwChild.layer.shadowOffset = CGSize(width: 10, height: 10)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "prevUserEmail")
        UserDefaults.standard.removeObject(forKey: "prevUserPass")
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is ViewController {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
}
