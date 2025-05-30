//
//  ViewController.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 01/04/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var vwUsernameContainer: UIView!
    @IBOutlet weak var vwPasswordContainer: UIView!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var vwLoginViewContainer: UIView!
    @IBOutlet weak var vwForgotPsw: UIView!
    @IBOutlet weak var vwForgotEmailField: UIView!
    @IBOutlet weak var btnForgotCancel: UIButton!
    @IBOutlet weak var btnLogin: LoaderButton!
    @IBOutlet weak var btnSubmitForgotPsw: LoaderButton!
    @IBOutlet weak var txtForgotPswEmail: UITextField!
    
    @IBOutlet weak var lblForgotTitle: UILabel!
    @IBOutlet weak var txtForgotValidatePsw: UITextField!
    @IBOutlet weak var txtForgotValidatePin: UITextField!
    @IBOutlet weak var txtForgotNewPin: UITextField!
    @IBOutlet weak var txtForgotNewPsw: UITextField!
    @IBOutlet weak var vwForgotValidatePsw: UIView!
    @IBOutlet weak var vwForgotValidatePin: UIView!
    @IBOutlet weak var vwForgotNewPin: UIView!
    @IBOutlet weak var vwForgotNewPsw: UIView!
    @IBOutlet weak var btnForgotValidatePswEye: UIButton!
    @IBOutlet weak var btnForgotValidatePinEye: UIButton!
    @IBOutlet weak var btnForgotNewPinEye: UIButton!
    @IBOutlet weak var btnForgotNewPswEye: UIButton!
    @IBOutlet weak var btnRememberLoginCheckbox: UIButton!
    
    private var forgotPinOrPsw: ForgotPinOrPsw = .pin
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUiSetup()
        txtUsername.delegate = self
        txtPassword.delegate = self
        txtForgotNewPin.delegate = self
        txtForgotValidatePin.delegate = self
        txtForgotValidatePsw.delegate = self
        txtForgotNewPsw.delegate = self
        txtForgotPswEmail.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
////        var isSavePreUserEmail = isKeyPresentInUserDefaults(key: "prevUserEmail")
////        var isSavePreUserPass = isKeyPresentInUserDefaults
//        
//        if let prevUserEmail = UserDefaults.standard.string(forKey: "prevUserEmail"),
//           let prevUserPass = UserDefaults.standard.string(forKey: "prevUserPass") {
//            print("Retrieved prevUserEmail: \(prevUserEmail)")
//            print("Retrieved prevUserPass: \(prevUserPass)")
//            btnRememberLoginCheckbox.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
//            btnRememberLoginCheckbox.tag = 1
//        } else {
//            btnRememberLoginCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
//            btnRememberLoginCheckbox.tag = 0
//        }
//
//        
//        txtUsername.text = ""
//        txtPassword.text = ""
//        checkForLogin()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "prevUserEmail")
        let password = defaults.string(forKey: "prevUserPass")
        
        let isRemembered = (email != nil && password != nil)
        let checkboxImage = UIImage(systemName: isRemembered ? "checkmark.square" : "square")
        
        btnRememberLoginCheckbox.setImage(checkboxImage, for: .normal)
        btnRememberLoginCheckbox.tag = isRemembered ? 1 : 0
        
        txtUsername.text = ""
        txtPassword.text = ""
        checkForLogin()
    }

    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func checkForLogin() {
        let prevUserEmail = UserDefaults.standard.string(forKey: "prevUserEmail")
        let prevUserPass = UserDefaults.standard.string(forKey: "prevUserPass")
        if let prevUserEmail = prevUserEmail, let prevUserPass = prevUserPass {
            self.login(usrNm: prevUserEmail, pass: prevUserPass, remember: true)
        }
    }

    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwForgotPsw.isHidden = true
        
        btnSignUp.layer.borderColor = UIColor.appPurpleTint.cgColor
        btnSignUp.layer.borderWidth = 1
        
        vwUsernameContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwUsernameContainer.layer.borderWidth = 1
        
        vwPasswordContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwPasswordContainer.layer.borderWidth = 1
        
        vwLoginViewContainer.layer.shadowOpacity = 0.25
        vwLoginViewContainer.layer.shadowRadius = 3
        vwLoginViewContainer.layer.shadowColor = UIColor.black.cgColor
        vwLoginViewContainer.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        btnForgotCancel.layer.borderColor = UIColor.appPurpleTint.cgColor
        btnForgotCancel.layer.borderWidth = 1
        
        vwForgotEmailField.layer.borderColor = UIColor.appBorder.cgColor
        vwForgotEmailField.layer.borderWidth = 1
        
        vwForgotValidatePin.layer.borderColor = UIColor.appBorder.cgColor
        vwForgotValidatePin.layer.borderWidth = 1
        
        vwForgotValidatePsw.layer.borderColor = UIColor.appBorder.cgColor
        vwForgotValidatePsw.layer.borderWidth = 1
        
        vwForgotNewPin.layer.borderColor = UIColor.appBorder.cgColor
        vwForgotNewPin.layer.borderWidth = 1
        
        vwForgotNewPsw.layer.borderColor = UIColor.appBorder.cgColor
        vwForgotNewPsw.layer.borderWidth = 1
    }
    @IBAction func eyeBtnAction(_ sender: UIButton) {
        if txtPassword.isSecureTextEntry {
            txtPassword.isSecureTextEntry = false
            btnEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtPassword.isSecureTextEntry = true
            btnEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        if let signUpVc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
            self.navigationController?.pushViewController(signUpVc, animated: true)
        }
    }
    @IBAction func loginBtnAction(_ sender: UIButton) {
//        if txtUsername.text?.isEmpty == true {
//            self.showAlertWithAction(msg: "Please enter username!") {
//                self.txtUsername.becomeFirstResponder()
//            }
//        } else if txtPassword.text?.isEmpty == true {
//            self.showAlertWithAction(msg: "Please enter password!") {
//                self.txtPassword.becomeFirstResponder()
//            }
//        } else {
//            self.login(usrNm: txtUsername.text, pass: txtPassword.text, remember: btnRememberLoginCheckbox.tag == 1)
//        }
        
        if txtUsername.text?.isEmpty == true {
               self.showAlertWithAction(msg: "Please enter username!") {
                   self.txtUsername.becomeFirstResponder()
               }
           } else if txtPassword.text?.isEmpty == true {
               self.showAlertWithAction(msg: "Please enter password!") {
                   self.txtPassword.becomeFirstResponder()
               }
           } else {
               let usernameLowercased = txtUsername.text?.lowercased() ?? ""
               self.login(usrNm: usernameLowercased, pass: txtPassword.text, remember: btnRememberLoginCheckbox.tag == 1)
           }
    }
    @IBAction func cancelForgotPswBtnAction(_ sender: UIButton) {
        vwForgotPsw.isHidden = true
        txtForgotValidatePin.text = ""
        txtForgotValidatePsw.text = ""
        txtForgotNewPin.text = ""
        txtForgotNewPsw.text = ""
        txtForgotPswEmail.text = ""
    }
    @IBAction func submitForgotPswBtnAction(_ sender: UIButton) {
        if forgotPinOrPsw == .pin {
            if txtForgotPswEmail.text?.isEmpty == true {
                showAlert(withMsg: "Please enter your registered username.")
            } else if txtForgotValidatePsw.text?.isEmpty == true {
                showAlert(withMsg: "Enter your password for verification.")
            } else if txtForgotNewPin.text?.isEmpty == true {
                showAlert(withMsg: "Enter a new Pin.")
            } else if txtForgotNewPin.text?.count != 4 {
                showAlert(withMsg: "Pin must be 4 digits long.")
            } else {
                updatePin(usrEmail: txtForgotPswEmail.text)
            }
        } else if forgotPinOrPsw == .psw {
            if txtForgotPswEmail.text?.isEmpty == true {
                showAlert(withMsg: "Please enter your registered username.")
            } else if txtForgotValidatePin.text?.isEmpty == true {
                showAlert(withMsg: "Enter your app pin for verification.")
            } else if txtForgotNewPsw.text?.isEmpty == true {
                showAlert(withMsg: "Enter a new Password.")
            } else {
                updatePsw(usrEmail: txtForgotPswEmail.text)
            }
        }
    }
    @IBAction func eyeForgotValidatePswBtnAction(_ sender: UIButton) {
        if txtForgotValidatePsw.isSecureTextEntry {
            txtForgotValidatePsw.isSecureTextEntry = false
            btnForgotValidatePswEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtForgotValidatePsw.isSecureTextEntry = true
            btnForgotValidatePswEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func eyeForgotValidatePinBtnAction(_ sender: UIButton) {
        if txtForgotValidatePin.isSecureTextEntry {
            txtForgotValidatePin.isSecureTextEntry = false
            btnForgotValidatePinEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtForgotValidatePin.isSecureTextEntry = true
            btnForgotValidatePinEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func eyeForgotNewPinBtnAction(_ sender: UIButton) {
        if txtForgotNewPin.isSecureTextEntry {
            txtForgotNewPin.isSecureTextEntry = false
            btnForgotNewPinEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtForgotNewPin.isSecureTextEntry = true
            btnForgotNewPinEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func eyeForgotNewPswBtnAction(_ sender: UIButton) {
        if txtForgotNewPsw.isSecureTextEntry {
            txtForgotNewPsw.isSecureTextEntry = false
            btnForgotNewPswEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtForgotNewPsw.isSecureTextEntry = true
            btnForgotNewPswEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func forgotPinBtnAction(_ sender: UIButton) {
        forgotPinOrPsw = .pin
        lblForgotTitle.text = "Forgot Pin"
        vwForgotValidatePsw.isHidden = false
        vwForgotValidatePin.isHidden = true
        vwForgotNewPin.isHidden = false
        vwForgotNewPsw.isHidden = true
        vwForgotPsw.isHidden = false
    }
    @IBAction func forgotPswBtnAction(_ sender: UIButton) {
        forgotPinOrPsw = .psw
        lblForgotTitle.text = "Forgot Password"
        vwForgotValidatePsw.isHidden = true
        vwForgotValidatePin.isHidden = false
        vwForgotNewPin.isHidden = true
        vwForgotNewPsw.isHidden = false
        vwForgotPsw.isHidden = false
    }
    @IBAction func rememberLoginCheckboxBtnAction(_ sender: UIButton) {
        if sender.tag == 1 {
            //not to remember
            btnRememberLoginCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
            btnRememberLoginCheckbox.tag = 0
        } else {
            //remember
            btnRememberLoginCheckbox.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            btnRememberLoginCheckbox.tag = 1
        }
    }
    
    
    func login(usrNm: String?, pass: String?, remember: Bool) {
        let users = UsersDBHelper.instance.loadData()
        
        // Check if there's a user with the provided email and password
        if let user = users.first(where: { $0.email == usrNm && $0.password == pass }) {
            globalAppPin = user.appPin
            globalLoggedInUserId = user.id
            // Successful login
            if remember {
                
                UserDefaults.standard.setValue(usrNm ?? "", forKey: "prevUserEmail")
                UserDefaults.standard.setValue(pass ?? "", forKey: "prevUserPass")
            } else {
                UserDefaults.standard.removeObject(forKey: "prevUserEmail")
                UserDefaults.standard.removeObject(forKey: "prevUserPass")
            }
            
            if user.childName?.isEmpty == true || user.childName == nil  {
                //redirect to add new child
                if let setUpVc = self.storyboard?.instantiateViewController(withIdentifier: "ToddlerSetupVC") as? ToddlerSetupVC {
                    self.navigationController?.pushViewController(setUpVc, animated: true)
                }
            } else {
                globalChildName = user.childName
                globalChildDob = user.childDob
                //redirect to selection page directly
                if let pathVc = self.storyboard?.instantiateViewController(withIdentifier: "ChoosePathVC") as? ChoosePathVC {
                    self.navigationController?.pushViewController(pathVc, animated: true)
                }
            }
        } else {
            // Login failed
            showAlert(withMsg: "Login failed. Invalid username or password.")
        }
    }
    
    func updatePsw(usrEmail: String?) {
        let users = UsersDBHelper.instance.loadData()
        if let user = users.first(where: { $0.email == usrEmail}) {
            if user.appPin == txtForgotValidatePin.text {
                if txtForgotNewPsw.text == user.password {
                    self.showAlert(withMsg: "Password cannot be the same as the previous one.")
                } else {
                    UsersDBHelper.instance.updatePassword(withId: user.id!, password: txtForgotNewPsw.text ?? "")
                    UserDefaults.standard.removeObject(forKey: "prevUserEmail")
                    UserDefaults.standard.removeObject(forKey: "prevUserPass")
                    vwForgotPsw.isHidden = true
                    txtForgotValidatePin.text = ""
                    txtForgotValidatePsw.text = ""
                    txtForgotNewPin.text = ""
                    txtForgotNewPsw.text = ""
                    txtForgotPswEmail.text = ""
                    showAlert(withMsg: "Password updated.")
                }
            } else {
                showAlert(withMsg: "Incorrect app pin.")
            }
        } else {
            showAlert(withMsg: "Entered username id is not registered.")
        }
    }
    
    func updatePin(usrEmail: String?) {
        let users = UsersDBHelper.instance.loadData()
        if let user = users.first(where: { $0.email == usrEmail}) {
            if user.password == txtForgotValidatePsw.text {
                if txtForgotNewPin.text == user.appPin {
                    self.showAlert(withMsg: "App pin cannot be the same as the previous one.")
                } else {
                    UsersDBHelper.instance.updateData(withId: user.id!, appPin: txtForgotNewPin.text ?? "", email: user.email ?? "", password: user.password ?? "")
                    vwForgotPsw.isHidden = true
                    txtForgotValidatePin.text = ""
                    txtForgotValidatePsw.text = ""
                    txtForgotNewPin.text = ""
                    txtForgotNewPsw.text = ""
                    txtForgotPswEmail.text = ""
                    showAlert(withMsg: "App pin updated.")
                }
            } else {
                showAlert(withMsg: "Incorrect password.")
            }
        } else {
            showAlert(withMsg: "Entered username id is not registered.")
        }
    }
}

//Keyboard management
extension ViewController: UIGestureRecognizerDelegate {
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == btnEye {
            return false
        }
        return true
    }
}

//TextField Management
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUsername {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPassword.resignFirstResponder()
            loginBtnAction(btnLogin)
        } else if textField == txtForgotPswEmail {
            if forgotPinOrPsw == .pin {
                txtForgotValidatePsw.becomeFirstResponder()
            } else if forgotPinOrPsw == .psw {
                txtForgotValidatePin.becomeFirstResponder()
            }
        } else if textField == txtForgotValidatePin {
            txtForgotNewPsw.becomeFirstResponder()
        } else if textField == txtForgotValidatePsw {
            txtForgotNewPin.becomeFirstResponder()
        } else if textField == txtForgotNewPin {
            submitForgotPswBtnAction(btnSubmitForgotPsw)
        } else if textField == txtForgotNewPsw {
            submitForgotPswBtnAction(btnSubmitForgotPsw)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //allow if backspace
        if string.isEmpty {
            return true
        }
        if textField == txtForgotValidatePin || textField == txtForgotNewPin {
            //restrict lenth to 4 digits only
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
}

//extension ViewController: UITextFieldDelegate {
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == txtUsername {
//            txtPassword.becomeFirstResponder()
//        } else if textField == txtPassword {
//            txtPassword.resignFirstResponder()
//            loginBtnAction(btnLogin)
//        } else if textField == txtForgotPswEmail {
//            if forgotPinOrPsw == .pin {
//                txtForgotValidatePsw.becomeFirstResponder()
//            } else if forgotPinOrPsw == .psw {
//                txtForgotValidatePin.becomeFirstResponder()
//            }
//        } else if textField == txtForgotValidatePin {
//            txtForgotNewPsw.becomeFirstResponder()
//        } else if textField == txtForgotValidatePsw {
//            txtForgotNewPin.becomeFirstResponder()
//        } else if textField == txtForgotNewPin || textField == txtForgotNewPsw {
//            submitForgotPswBtnAction(btnSubmitForgotPsw)
//        }
//        return true
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Allow backspace
//        if string.isEmpty {
//            return true
//        }
//
//        let currentText = textField.text ?? ""
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//
//        if textField == txtForgotValidatePin || textField == txtForgotNewPin {
//            // Restrict to 4 digits only
//            let maxLength = 4
//            let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
//            
//            return updatedText.count <= maxLength && isNumber
//        }
//        
//        // Apply capitalization only for txtUsername
//        if textField == txtUsername {
//            textField.text = updatedText.capitalized
//            print("Text changed \(textField.tag) : \(textField.text ?? "")")
//            return false
//        }else if  textField == txtForgotPswEmail {
//            textField.text = updatedText.capitalized
//            print("Text changed \(textField.tag) : \(textField.text ?? "")")
//            return false
//        }
//
//        return true
//    }
//}



enum ForgotPinOrPsw {
    case pin
    case psw
}



