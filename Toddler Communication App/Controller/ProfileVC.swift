//
//  ProfileVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 16/04/24.
//

import UIKit

class ProfileVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vwProfileContainer: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtChildNm: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var btnChangePsw: LoaderButton!
    @IBOutlet weak var btnSaveDetails: LoaderButton!
    @IBOutlet weak var vwChangePswPopupContainer: UIView!
    @IBOutlet weak var vwOldPswContainer: UIView!
    @IBOutlet weak var vwNewPswContainer: UIView!
    @IBOutlet weak var vwConfirmPswContainer: UIView!
    @IBOutlet weak var txtOldPsw: UITextField!
    @IBOutlet weak var txtNewPsw: UITextField!
    @IBOutlet weak var txtConfrmPsw: UITextField!
    @IBOutlet weak var btnEyeOldPsw: UIButton!
    @IBOutlet weak var btnEyeNewPsw: UIButton!
    @IBOutlet weak var btnEyeConfirmPsw: UIButton!
    @IBOutlet weak var btnUpdatePsw: LoaderButton!
    
    private let dobDatePicker = UIDatePicker()
    private var dobPickedDate: Date!
    
    private var cDob = globalChildDob ?? ""
    private var cNm = globalChildName ?? ""
    private var existingUsers: [UsersDB] = []
    
    var dateFormatterOnlyDate: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        txtDob.delegate = self
        txtChildNm.delegate = self
        txtOldPsw.delegate = self
        txtNewPsw.delegate = self
        txtConfrmPsw.delegate = self
        initialUiSetup()
        addInputViewDatePicker()
        existingUsers = UsersDBHelper.instance.loadData()
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func childNmEditBtnAction(_ sender: UIButton) {
        txtChildNm.isEnabled = true
        txtChildNm.backgroundColor = UIColor.white
        checkSaveBtnActive()
        txtChildNm.becomeFirstResponder()
    }
    @IBAction func dobEditBtnAction(_ sender: UIButton) {
        txtDob.isEnabled = true
        txtDob.backgroundColor = UIColor.white
        checkSaveBtnActive()
        txtDob.becomeFirstResponder()
    }
    @IBAction func saveDetailsBtnAction(_ sender: UIButton) {
        updateChildInfo()
    }
    @IBAction func changePswBtnAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.vwChangePswPopupContainer.alpha = 1.0
            self.vwChangePswPopupContainer.isHidden = false
        } completion: { _ in
            self.vwChangePswPopupContainer.isHidden = false
        }
        
    }
    @IBAction func closePswPopupBtnAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.vwChangePswPopupContainer.alpha = 0.0
        } completion: { _ in
            self.vwChangePswPopupContainer.isHidden = true
            self.txtOldPsw.text = ""
            self.txtNewPsw.text = ""
            self.txtConfrmPsw.text = ""
        }
    }
    @IBAction func oldPswEyeAction(_ sender: Any) {
        if txtOldPsw.isSecureTextEntry {
            txtOldPsw.isSecureTextEntry = false
            btnEyeOldPsw.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtOldPsw.isSecureTextEntry = true
            btnEyeOldPsw.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func newPswEyeAction(_ sender: UIButton) {
        if txtNewPsw.isSecureTextEntry {
            txtNewPsw.isSecureTextEntry = false
            btnEyeNewPsw.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtNewPsw.isSecureTextEntry = true
            btnEyeNewPsw.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func confirmPswEyeAction(_ sender: UIButton) {
        if txtConfrmPsw.isSecureTextEntry {
            txtConfrmPsw.isSecureTextEntry = false
            btnEyeConfirmPsw.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtConfrmPsw.isSecureTextEntry = true
            btnEyeConfirmPsw.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func updatePswBtnAction(_ sender: UIButton) {
        if txtOldPsw.text?.isEmpty == true {
            self.showAlert(withMsg: "Please enter old password.")
        } else if txtNewPsw.text?.isEmpty == true {
            self.showAlert(withMsg: "Please enter a new password.")
        } else  if !isValidPassword(txtNewPsw.text ?? "") {
            self.showAlert(withMsg: "Password must contain at least one lowercase letter, one uppercase letter, one digit, one special character, and be at least 8 characters long.")
        } else if txtConfrmPsw.text?.isEmpty == true {
            self.showAlert(withMsg: "Please confirm the new password.")
        } else if txtNewPsw.text != txtConfrmPsw.text {
            self.showAlert(withMsg: "The new password and confirm password fields do not match.")
        } else {
            updatePsw()
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
    
    @IBAction func deleteAccountBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            if let userId = globalLoggedInUserId {
                UsersDBHelper.instance.deleteData(withId: userId)
                UserDefaults.standard.removeObject(forKey: "prevUserEmail")
                UserDefaults.standard.removeObject(forKey: "prevUserPass")
                self.showAlertWithAction(msg: "Account deleted successfully.") {
                    self.logout()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwChangePswPopupContainer.isHidden = true
        vwChangePswPopupContainer.alpha = 0.0
        
        btnBack.layer.borderWidth = 1
        btnBack.layer.borderColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.00).cgColor
        
        vwProfileContainer.layer.borderWidth = 5
        vwProfileContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwProfileContainer.layer.shadowOpacity = 0.35
        vwProfileContainer.layer.shadowRadius = 3
        vwProfileContainer.layer.shadowColor = UIColor.black.cgColor
        vwProfileContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        txtChildNm.layer.borderColor = UIColor.app272727.cgColor
        txtChildNm.layer.borderWidth = 1
        
        txtDob.layer.borderColor = UIColor.app272727.cgColor
        txtDob.layer.borderWidth = 1
        
        txtDob.text = cDob
        txtChildNm.text = cNm
        
        txtDob.isEnabled = false
        txtChildNm.isEnabled = false
        
        txtDob.backgroundColor = UIColor.systemGray5
        txtChildNm.backgroundColor = UIColor.systemGray5
        
        vwOldPswContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwOldPswContainer.layer.borderWidth = 1
        vwNewPswContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwNewPswContainer.layer.borderWidth = 1
        vwConfirmPswContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwConfirmPswContainer.layer.borderWidth = 1
        
        checkSaveBtnActive()
        
        if let dob = dateFormatterOnlyDate.date(from: cDob) {
            dobDatePicker.date = dob
            dobPickedDate = dob
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func checkSaveBtnActive() {
        if txtChildNm.text != cNm || txtDob.text != cDob {
            btnSaveDetails.isEnabled = true
        } else {
            btnSaveDetails.isEnabled = false
        }
    }
    
    //add date pickers for date of birth
    func addInputViewDatePicker() {
        //Add Tool Bar as input AccessoryView
        let screenWidth = UIScreen.main.bounds.width
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(pickerDonePressed))
        toolBar.setItems([flexibleSpace, doneBarButton], animated: false)
        
        //Add DatePicker as inputView for dob date
        dobDatePicker.maximumDate = Date()
        dobDatePicker.datePickerMode = .date
        dobDatePicker.addTarget(self, action: #selector(dobDatePicked(sender:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            dobDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        self.txtDob.inputView = dobDatePicker
        self.txtDob.inputAccessoryView = toolBar
    }
    
    @objc func pickerDonePressed() {
        if txtDob.isFirstResponder {
            self.txtDob.resignFirstResponder()
            if dobPickedDate == nil {
                self.dobPickedDate = Date()
            }
            let pickedDateStr = dateFormatterOnlyDate.string(from: dobPickedDate)
            self.txtDob.text = pickedDateStr
        }
    }
    
    @objc func dobDatePicked(sender: UIDatePicker) {
        self.dobPickedDate = sender.date
        let pickedDateStr = dateFormatterOnlyDate.string(from: dobPickedDate)
        self.txtDob.text = pickedDateStr
    }
    
    func logout() {
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is ViewController {
                    UserDefaults.standard.removeObject(forKey: "prevUserEmail")
                    UserDefaults.standard.removeObject(forKey: "prevUserPass")
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
    
    //change password
    func updatePsw() {
        if let userId = globalLoggedInUserId, let currentUser = existingUsers.first(where: {$0.id == userId}) {
            if txtOldPsw.text == currentUser.password {
                txtConfrmPsw.resignFirstResponder()
                UsersDBHelper.instance.updatePassword(withId: userId, password: txtNewPsw.text ?? "")
                UserDefaults.standard.setValue(txtNewPsw.text ?? "", forKey: "prevUserPass")
                self.showAlertWithAction(msg:"Password Updated successfully.") {
                    self.txtOldPsw.text = ""
                    self.txtNewPsw.text = ""
                    self.txtConfrmPsw.text = ""
                    UIView.animate(withDuration: 0.3) {
                        self.vwChangePswPopupContainer.alpha = 0.0
                    } completion: { _ in
                        self.vwChangePswPopupContainer.isHidden = true
                    }
                }
            } else {
                self.showAlert(withMsg: "Old password is wrong.")
            }
        } else {
            showAlert(withMsg: "Can't update password. Please try again.")
        }

    }
    
    //update child information in userdefaults
    func updateChildInfo() {
        if let userId = globalLoggedInUserId {
            UsersDBHelper.instance.updateChildDetails(withId: userId, childName: txtChildNm.text ?? "", childDob: txtDob.text ?? "")
            globalChildName = txtChildNm.text ?? ""
            globalChildDob = txtDob.text ?? ""
            self.showAlert(withMsg: "Child information successfully updated.")
            self.btnSaveDetails.isEnabled = false
            self.cDob = self.txtDob.text ?? ""
            self.cNm = self.txtChildNm.text ?? ""
            self.initialUiSetup()
        } else {
            showAlert(withMsg: "Unable to child info. Please try again.")
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkSaveBtnActive()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkSaveBtnActive()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtOldPsw {
            txtNewPsw.becomeFirstResponder()
        } else if textField == txtNewPsw {
            txtConfrmPsw.becomeFirstResponder()
        } else if textField == txtConfrmPsw {
            updatePswBtnAction(btnUpdatePsw)
        }
        return true
    }
}
