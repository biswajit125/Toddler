//
//  ProjectsVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 02/04/24.
//

import UIKit

class ProjectsVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vwProjectsContainer: UIView!
    @IBOutlet weak var cvProjectsCollection: UICollectionView!
    @IBOutlet weak var lblChildName: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var btnCreateNewProj: UIButton!
    @IBOutlet weak var vwPinPopup: UIView!
    @IBOutlet weak var txtAppPin: UITextField!
    @IBOutlet weak var vwPinTxtContainer: UIView!
    @IBOutlet weak var btnEyePin: UIButton!
    @IBOutlet weak var btnSubmitAppPin: UIButton!
    
    var accessType: AccessType = .child
    var allProjects: [ProjectsDB] = []
    
    private var colorSet = [UIColor.projColor1, UIColor.projColor2, UIColor.projColor3, UIColor.projColor4, UIColor.projColor5, UIColor.projColor6, UIColor.projColor7, UIColor.projColor8, UIColor.projColor9, UIColor.projColor10]
    private var lstColorPicked: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvProjectsCollection.delegate = self
        cvProjectsCollection.dataSource = self
        txtAppPin.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        initialUiSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        lblChildName.text = globalChildName ?? ""
        lblDob.text = "DOB: \(globalChildDob ?? "")"
        
        allProjects = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
        cvProjectsCollection.reloadData()
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwPinPopup.isHidden = true
        
        vwProjectsContainer.layer.borderWidth = 5
        vwProjectsContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwProjectsContainer.layer.shadowOpacity = 0.35
        vwProjectsContainer.layer.shadowRadius = 3
        vwProjectsContainer.layer.shadowColor = UIColor.black.cgColor
        vwProjectsContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        vwPinTxtContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwPinTxtContainer.layer.borderWidth = 1
        
        if accessType == .parent {
            btnCreateNewProj.isHidden = false
        } else {
            btnCreateNewProj.isHidden = true
        }
        
    }
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        //now btn changed to back
        if accessType == .child {
            UIView.animate(withDuration: 0.1) {
                self.vwPinPopup.alpha = 1.0
                self.vwPinPopup.isHidden = false
            } completion: { _ in
                self.vwPinPopup.isHidden = false
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func createBtnAction(_ sender: UIButton) {
        if let newProjVc = self.storyboard?.instantiateViewController(withIdentifier: "NewProjVC") as? NewProjVC {
            self.navigationController?.pushViewController(newProjVc, animated: true)
        }
    }
    @IBAction func profileBtnAction(_ sender: UIButton) {
        if accessType == .parent {
            if let profileVc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                self.navigationController?.pushViewController(profileVc, animated: true)
            }
        }
    }
    @IBAction func closeAppPinPopup(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.vwPinPopup.alpha = 0.0
        } completion: { _ in
            self.vwPinPopup.isHidden = true
        }
    }
    @IBAction func submitAppPinAction(_ sender: UIButton) {
        if txtAppPin.text?.isEmpty == true {
            self.showAlert(withMsg: "Please enter the app pin.")
        } else if globalAppPin != txtAppPin.text {
            self.showAlert(withMsg: "Entered pin is incorrect.")
        } else {
            txtAppPin.resignFirstResponder()
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func eyePinBtnAction(_ sender: UIButton) {
        if txtAppPin.isSecureTextEntry {
            txtAppPin.isSecureTextEntry = false
            btnEyePin.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtAppPin.isSecureTextEntry = true
            btnEyePin.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //allow if backspace
        if string.isEmpty {
            return true
        }
        if textField == txtAppPin {
            //restrict to 4 numbers
            let maxLength = 4
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            //restrict to only numbers
            var isNumber = false
            if let _ = Int(string) {
                isNumber = true
            }
            return (newString.count <= maxLength && isNumber)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtAppPin {
            submitAppPinAction(btnSubmitAppPin)
        }
        return true
    }
}

//Collection view delegate and datasource
extension ProjectsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if allProjects.count == 0 {
            collectionView.setEmptyView(title: "No Projects Found.", message: "")
        } else {
            collectionView.restore()
        }
        return allProjects.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectsCVC", for: indexPath) as? ProjectsCVC {
            let availableColors = colorSet.filter({$0 != lstColorPicked})
            print(availableColors.count)
            lstColorPicked = availableColors.randomElement()
            cell.vwCellContainer.backgroundColor = lstColorPicked
            //add btn functionality
            cell.btnAdd.tag = indexPath.item
            cell.btnAdd.addTarget(self, action: #selector(addNewImgCvBtnACtion(_ :)), for: .touchUpInside)
            //edit btn functionality
            cell.btnEdit.tag = indexPath.item
            cell.btnEdit.addTarget(self, action: #selector(editProjectCvBtnACtion(_ :)), for: .touchUpInside)
            //delete btn functionality
            cell.btnDelete.tag = indexPath.item
            cell.btnDelete.addTarget(self, action: #selector(deleteProjCvBtnAction(_ :)), for: .touchUpInside)
            
            if accessType == .parent {
                cell.vwActionContainer.isHidden = false
                cell.vwActionContainer.isHidden = (allProjects[indexPath.item].isEditable != true)
            } else {
                cell.vwActionContainer.isHidden = true
            }
            cell.lblProjectTitle.text = allProjects[indexPath.item].name ?? "Untitled"
            if let thumbnailData = allProjects[indexPath.item].thumbnail, let thumbnailImg = UIImage(data: thumbnailData) {
                cell.imgThumbnail.image = thumbnailImg
            } else {
                cell.imgThumbnail.image = nil
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        if let playVc = self.storyboard?.instantiateViewController(withIdentifier: "PlayProjectVC") as? PlayProjectVC {
            playVc.currentProjID = self.allProjects[indexPath.item].id
            playVc.allProj = self.allProjects
            playVc.accessType = self.accessType
            self.navigationController?.pushViewController(playVc, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 230, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    //add btn action
    @objc func addNewImgCvBtnACtion(_ sender: UIButton) {
        print("point 2.0 --> ", sender.tag)
        if let addImgVc = self.storyboard?.instantiateViewController(withIdentifier: "AddImageVC") as? AddImageVC {
            addImgVc.existingProj = allProjects[sender.tag]
            addImgVc.projHid = allProjects[sender.tag].id
            self.navigationController?.pushViewController(addImgVc, animated: true)
        }
    }
    
    //edit proj btn action
    @objc func editProjectCvBtnACtion(_ sender: UIButton) {
        print("point 2.1 --> ", sender.tag)
        if let editVc = self.storyboard?.instantiateViewController(withIdentifier: "EditProjectVC") as? EditProjectVC {
            editVc.existingProj = allProjects[sender.tag]
            editVc.projHid = allProjects[sender.tag].id
            self.navigationController?.pushViewController(editVc, animated: true)
        }
    }
    
    //delete proj btn action
    @objc func deleteProjCvBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure you want to Delete the project?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            let id = self.allProjects[sender.tag].id
            ProjectsDBHelper.instance.deleteData(withId: id!)
            ProjectsDetailsDBHelper.instance.deleteUsingProjId(withProjId: id!)
            self.allProjects = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
            self.cvProjectsCollection.reloadData()
            self.showAlert(withMsg: "Project deleted successfully.")
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(alert, animated: true)
    }
}
