//
//  SignUpVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 01/04/24.
//

import UIKit
import WebKit

class SignUpVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vwEmailContainer: UIView!
    @IBOutlet weak var vwPasswordContainer: UIView!
    @IBOutlet weak var vwConfirmPassContainer: UIView!
    @IBOutlet weak var btnPassEye: UIButton!
    @IBOutlet weak var btnConfirmPassEye: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var btnTnCCheckbox: UIButton!
    @IBOutlet weak var vwPinContainer: UIView!
    @IBOutlet weak var btnSubmitSignUp: LoaderButton!
    @IBOutlet weak var txtAppPin: UITextField!
    @IBOutlet weak var btnPinEye: UIButton!
    @IBOutlet weak var vwTnCPopup: UIView!
    @IBOutlet weak var webViewTnC: WKWebView!
    
    private var existingUsers: [UsersDB] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        initialUiSetup()
        existingUsers = UsersDBHelper.instance.loadData()
        loadTnCPdf()
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        txtAppPin.delegate = self
        txtEmail.delegate = self //1
        txtPass.delegate = self
        txtConfirmPass.delegate = self
        
        vwEmailContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwEmailContainer.layer.borderWidth = 1
        
        vwPasswordContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwPasswordContainer.layer.borderWidth = 1
        
        vwConfirmPassContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwConfirmPassContainer.layer.borderWidth = 1
        
        vwPinContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwPinContainer.layer.borderWidth = 1
        
        btnTnCCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        btnTnCCheckbox.tintColor = UIColor.checkBoxUnChecked
        btnTnCCheckbox.tag = 0
        
        vwTnCPopup.isHidden = true
    }
    @IBAction func passEyeBtnAction(_ sender: UIButton) {
        if txtPass.isSecureTextEntry {
            txtPass.isSecureTextEntry = false
            btnPassEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtPass.isSecureTextEntry = true
            btnPassEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func confirmPassEyeBtnAction(_ sender: UIButton) {
        if txtConfirmPass.isSecureTextEntry {
            txtConfirmPass.isSecureTextEntry = false
            btnConfirmPassEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtConfirmPass.isSecureTextEntry = true
            btnConfirmPassEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tnCCheckboxBtnAction(_ sender: UIButton) {
        if btnTnCCheckbox.tag == 0 {
            btnTnCCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            btnTnCCheckbox.tintColor = UIColor.checkBoxChecked
            btnTnCCheckbox.tag = 1
        } else {
            btnTnCCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
            btnTnCCheckbox.tintColor = UIColor.checkBoxUnChecked
            btnTnCCheckbox.tag = 0
        }
    }
    @IBAction func SubmitSignUpBtnAction(_ sender: UIButton) {
        if txtEmail.text?.isEmpty == true { //2
            self.showAlertWithAction(msg: "Please enter an username.") {
                self.txtEmail.becomeFirstResponder()
            }
        } else if existingUsers.contains(where: {$0.email == txtEmail.text}) {
            self.showAlert(withMsg: "Entered user already exist.")
        } else if txtPass.text?.isEmpty == true {
            self.showAlertWithAction(msg: "Please enter a new password.") {
                self.txtPass.becomeFirstResponder()
            }
        } else  if !isValidPassword(txtPass.text ?? "") {
            self.showAlert(withMsg: "Password must contain at least one lowercase letter, one uppercase letter, one digit, one special character, and be at least 8 characters long.")
        } else if txtConfirmPass.text?.isEmpty == true {
            self.showAlertWithAction(msg: "Please confirm password.") {
                self.txtConfirmPass.becomeFirstResponder()
            }
        } else if txtPass.text != txtConfirmPass.text {
            self.showAlert(withMsg: "The new password and confirm password fields do not match.")
        } else if txtAppPin.text?.isEmpty == true {
            self.showAlertWithAction(msg: "Please enter a 4 digit app pin.") {
                self.txtAppPin.becomeFirstResponder()
            }
        } else if txtAppPin.text?.count != 4 {
            self.showAlertWithAction(msg: "Pin must be 4 digits long.") {
                self.txtAppPin.becomeFirstResponder()
            }
        } else if btnTnCCheckbox.tag != 1 {
            self.showAlert(withMsg: "Please accept our terms and conditions to proceed.")
        } else {
            self.SignUp()
        }
        
    }
    @IBAction func EyeAppPinBtnAction(_ sender: UIButton) {
        if txtAppPin.isSecureTextEntry {
            txtAppPin.isSecureTextEntry = false
            btnPinEye.setImage(UIImage.eyeOn, for: .normal)
        } else {
            txtAppPin.isSecureTextEntry = true
            btnPinEye.setImage(UIImage.eyeOff, for: .normal)
        }
    }
    @IBAction func closeTnCBtnAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.vwTnCPopup.alpha = 0.0
        } completion: { _ in
            self.vwTnCPopup.isHidden = true
        }
    }
    @IBAction func tNcBtnAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.vwTnCPopup.alpha = 1.0
            self.vwTnCPopup.isHidden = false
        } completion: { _ in
            self.vwTnCPopup.isHidden = false
        }
    }
    
    func loadTnCPdf() {
        if let pdfURL = Bundle.main.url(forResource: "TnC", withExtension: "pdf") {
            webViewTnC.loadFileURL(pdfURL, allowingReadAccessTo: pdfURL)
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
//    func SignUp() {
//        let newUserId = UsersDBHelper.instance.createData(appPin: txtAppPin.text ?? "", email: txtEmail.text ?? "", password: txtPass.text ?? "")
//        print("newUserId -> ", newUserId)
//        let projects = ProjectsDBHelper.instance.loadData(forUserId: newUserId)
//        if !projects.contains(where: {$0.name == "Foods"}) {
//            insertDefaultFoodsProject(forUser: newUserId)
//        }
//        if !projects.contains(where: {$0.name == "Colors"}) {
//            insertDefaultColorsProject(forUser: newUserId)
//        }
//        if !projects.contains(where: {$0.name == "Numbers"}) {
//            insertDefaultNumbersProject(forUser: newUserId)
//        }
//        if !projects.contains(where: {$0.name == "Letters"}) {
//            insertDefaultLettersProject(forUser: newUserId)
//        }
//        if !projects.contains(where: {$0.name == "Fruis"}) {
//            insertDefaultFruitsProject(forUser: newUserId)
//        }
//        self.showAlertWithAction(msg: "Success! Your account has been created.") {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
    
    func SignUp() {
        let email = txtEmail.text?.lowercased() ?? "" // Convert email to lowercase
        let newUserId = UsersDBHelper.instance.createData(appPin: txtAppPin.text ?? "", email: email, password: txtPass.text ?? "")
        print("newUserId -> ", newUserId)
        
        let projects = ProjectsDBHelper.instance.loadData(forUserId: newUserId)
        
        if !projects.contains(where: { $0.name == "Foods" }) {
            insertDefaultFoodsProject(forUser: newUserId)
        }
        if !projects.contains(where: { $0.name == "Colors" }) {
            insertDefaultColorsProject(forUser: newUserId)
        }
        if !projects.contains(where: { $0.name == "Numbers" }) {
            insertDefaultNumbersProject(forUser: newUserId)
        }
        if !projects.contains(where: { $0.name == "Letters" }) {
            insertDefaultLettersProject(forUser: newUserId)
        }
        if !projects.contains(where: { $0.name == "Fruis" }) { // Fix typo: "Fruis" -> "Fruits"?
            insertDefaultFruitsProject(forUser: newUserId)
        }
        
        self.showAlertWithAction(msg: "Success! Your account has been created.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //allow if backspace
        if string.isEmpty {
            return true
        }
        if textField == self.txtEmail {
            if string.contains(" ") {
                return false
            }
            
        }else if textField == txtAppPin {
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
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        //allow if backspace
//        if string.isEmpty {
//            return true
//        }
//        
//        
//        if textField == self.txtEmail {
//            if string.contains(" ") {
//                return false
//            }
//            
//        }else if textField == txtAppPin {
//            //restrict lenth to 4 digits only
//            let maxLength = 4
//            let currentString = (textField.text ?? "") as NSString
//            let newString = currentString.replacingCharacters(in: range, with: string)
//            
//            //restrict to only numbers
//            var isNumber = false
//            if let _ = Int(string) {
//                isNumber = true
//            }
//            return (newString.count <= maxLength && isNumber)
//        }
//        if textField == txtUsername {
//            textField.text = updatedText.capitalized
//            print("Text changed \(textField.tag) : \(textField.text ?? "")")
//            return false
//        }
//        
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtEmail:
            txtPass.becomeFirstResponder()
        case txtPass:
            txtConfirmPass.becomeFirstResponder()
        case txtConfirmPass:
            txtAppPin.becomeFirstResponder()
        case txtAppPin:
            txtAppPin.resignFirstResponder()
            SubmitSignUpBtnAction(btnSubmitSignUp)
        default:
            return true
        }
        return true
    }
}

//Keyboard management
extension SignUpVC: UIGestureRecognizerDelegate {
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == btnPassEye || touch.view == btnConfirmPassEye {
            return false
        }
        return true
    }
}

//MARK: - insert default project on first time
extension SignUpVC {
    func insertDefaultColorsProject(forUser uid: UUID) {
        let defaultProjectName = "Colors"
        let thumbnail = UIImage.colorsThumbnail.jpegData(compressionQuality: 1)
        let projId = ProjectsDBHelper.instance.createData(withName: defaultProjectName, isEditable: true, thumbnail: thumbnail, userId: uid)
        insertDefaultColorsProjectDetails(projHid: projId)
    }
    
    func insertDefaultColorsProjectDetails(projHid: UUID) {
        let defaultProjectDetails = [
            ("Red", UIImage.redSample.jpegData(compressionQuality: 1)!),
            ("Green", UIImage.greenSample.jpegData(compressionQuality: 1)!),
            ("Blue", UIImage.blueSample.jpegData(compressionQuality: 1)!),
            ("Yellow", UIImage.yellowSample.jpegData(compressionQuality: 1)!),
            ("Brown", UIImage.brownSample.jpegData(compressionQuality: 1)!),
            ("Orange", UIImage.orangeSample.jpegData(compressionQuality: 1)!),
            ("Pink", UIImage.pinkSample.jpegData(compressionQuality: 1)!),
            ("Purple", UIImage.purpleSample.jpegData(compressionQuality: 1)!),
        ]
        for detail in defaultProjectDetails {
            let (title, imageData) = detail
            ProjectsDetailsDBHelper.instance.createData(withTitle: title, withImage: imageData, withProjectId: projHid)
        }
    }
    
    func insertDefaultFruitsProject(forUser uid: UUID) {
        let defaultProjectName = "Fruits"
        let thumbnail = UIImage.icFruits.jpegData(compressionQuality: 1)
        let projId = ProjectsDBHelper.instance.createData(withName: defaultProjectName, isEditable: true, thumbnail: thumbnail, userId: uid)
        insertDefaultFruitsProjectDetails(projHid: projId)
    }
    
    func insertDefaultFruitsProjectDetails(projHid: UUID) {
        let defaultProjectDetails = [
            ("Apple", UIImage.icApple.jpegData(compressionQuality: 1)!),
            ("Banana", UIImage.icBanana.jpegData(compressionQuality: 1)!),
            ("Pineapple", UIImage.icPineapple.jpegData(compressionQuality: 1)!),
            ("Watermelon", UIImage.icWatermelons.jpegData(compressionQuality: 1)!),
            ("Mango", UIImage.icMango.jpegData(compressionQuality: 1)!),
            ("Papaya", UIImage.icPapaya.jpegData(compressionQuality: 1)!),
            ("Orange", UIImage.icOrange.jpegData(compressionQuality: 1)!),
            ("Strawberry", UIImage.icStrawberry.jpegData(compressionQuality: 1)!),
        ]
        
        for detail in defaultProjectDetails {
            let (title, imageData) = detail
            ProjectsDetailsDBHelper.instance.createData(withTitle: title, withImage: imageData, withProjectId: projHid)
        }
    }
    
    func insertDefaultFoodsProject(forUser uid: UUID) {
        let defaultProjectName = "Foods"
        let thumbnail = UIImage.foodThumnail.jpegData(compressionQuality: 1)
        let projId = ProjectsDBHelper.instance.createData(withName: defaultProjectName, isEditable: true, thumbnail: thumbnail, userId: uid)
        insertDefaultFoodsProjectDetails(projHid: projId)
    }
    func insertDefaultFoodsProjectDetails(projHid: UUID) {
        let defaultProjectDetails = [
//            ("Burger", UIImage.burger.jpegData(compressionQuality: 1)!),
//            ("French Fries", UIImage.frenchFries.jpegData(compressionQuality: 1)!),
//            ("Pancake", UIImage.pancake.jpegData(compressionQuality: 1)!),
//            ("Pizza", UIImage.pizza.jpegData(compressionQuality: 1)!),
//            ("Chocolate", UIImage.chocolate.jpegData(compressionQuality: 1)!),
//            ("Ice Cream", UIImage.iceCream.jpegData(compressionQuality: 1)!),
//            ("Tacos", UIImage.tacos.jpegData(compressionQuality: 1)!),
//            ("Donuts", UIImage.donuts.jpegData(compressionQuality: 1)!),
            
            ("Mac and cheese", UIImage.macAndCheese.jpegData(compressionQuality: 1)!),
            ("Sandwich", UIImage.sandwich.jpegData(compressionQuality: 1)!),
            ("PB and J", UIImage.pbAndJ.jpegData(compressionQuality: 1)!),
            ("Cereal", UIImage.cereal.jpegData(compressionQuality: 1)!),
            ("Spaghetti", UIImage.spaghetti.jpegData(compressionQuality: 1)!),
            ("Oatmeal", UIImage.oatmeal.jpegData(compressionQuality: 1)!),
            ("Waffles", UIImage.waffles.jpegData(compressionQuality: 1)!),
            ("Parfait", UIImage.parfait.jpegData(compressionQuality: 1)!),
        ]
        
        for detail in defaultProjectDetails {
            let (title, imageData) = detail
            ProjectsDetailsDBHelper.instance.createData(withTitle: title, withImage: imageData, withProjectId: projHid)
        }
    }
    
    func insertDefaultNumbersProject(forUser uid: UUID) {
        let defaultProjectName = "Numbers"
        let thumbnail = UIImage.numbersThumbnail.jpegData(compressionQuality: 1)
        let projId = ProjectsDBHelper.instance.createData(withName: defaultProjectName, isEditable: true, thumbnail: thumbnail, userId: uid)
        insertDefaultNumbersProjectDetails(projHid: projId)
    }
    func insertDefaultNumbersProjectDetails(projHid: UUID) {
        let defaultProjectDetails = [
            ("One", UIImage.oneSample.jpegData(compressionQuality: 1)!),
            ("Two", UIImage.twoSample.jpegData(compressionQuality: 1)!),
            ("Three", UIImage.threeSample.jpegData(compressionQuality: 1)!),
            ("Four", UIImage.fourSample.jpegData(compressionQuality: 1)!),
            ("Five", UIImage.fiveSample.jpegData(compressionQuality: 1)!),
            ("Six", UIImage.sixSample.jpegData(compressionQuality: 1)!),
            ("Seven", UIImage.sevenSample.jpegData(compressionQuality: 1)!),
            ("Eight", UIImage.eightSample.jpegData(compressionQuality: 1)!),
            ("Nine", UIImage.nineSample.jpegData(compressionQuality: 1)!),
            ("Ten", UIImage.tenSample.jpegData(compressionQuality: 1)!),
            ("Eleven", UIImage.elevenSample.jpegData(compressionQuality: 1)!),
            ("Twelve", UIImage.twelveSample.jpegData(compressionQuality: 1)!),
        ]
        
        for detail in defaultProjectDetails {
            let (title, imageData) = detail
            ProjectsDetailsDBHelper.instance.createData(withTitle: title, withImage: imageData, withProjectId: projHid)
        }
    }
//
    func insertDefaultLettersProject(forUser uid: UUID) {
        let defaultProjectName = "Letters"
        let thumbnail = UIImage.lettersThumbnail.jpegData(compressionQuality: 1)
        let projId = ProjectsDBHelper.instance.createData(withName: defaultProjectName, isEditable: true, thumbnail: thumbnail, userId: uid)
        insertDefaultLettersProjectDetails(projHid: projId)
    }
    func insertDefaultLettersProjectDetails(projHid: UUID) {
        let defaultProjectDetails = [
            ("A", UIImage.aSample.jpegData(compressionQuality: 1)!),
            ("B", UIImage.bSample.jpegData(compressionQuality: 1)!),
            ("C", UIImage.cSample.jpegData(compressionQuality: 1)!),
            ("D", UIImage.dSample.jpegData(compressionQuality: 1)!),
            ("E", UIImage.eSample.jpegData(compressionQuality: 1)!),
            ("F", UIImage.fSample.jpegData(compressionQuality: 1)!),
            ("G", UIImage.gSample.jpegData(compressionQuality: 1)!),
            ("H", UIImage.hSample.jpegData(compressionQuality: 1)!),
            ("I", UIImage.iSample.jpegData(compressionQuality: 1)!),
            ("J", UIImage.jSample.jpegData(compressionQuality: 1)!),
            ("K", UIImage.kSample.jpegData(compressionQuality: 1)!),
            ("L", UIImage.lSample.jpegData(compressionQuality: 1)!),
            ("M", UIImage.mSample.jpegData(compressionQuality: 1)!),
            ("N", UIImage.nSample.jpegData(compressionQuality: 1)!),
            ("O", UIImage.oSample.jpegData(compressionQuality: 1)!),
            ("P", UIImage.pSample.jpegData(compressionQuality: 1)!),
            ("Q", UIImage.qSample.jpegData(compressionQuality: 1)!),
            ("R", UIImage.rSample.jpegData(compressionQuality: 1)!),
            ("S", UIImage.sSample.jpegData(compressionQuality: 1)!),
            ("T", UIImage.tSample.jpegData(compressionQuality: 1)!),
            ("U", UIImage.uSample.jpegData(compressionQuality: 1)!),
            ("V", UIImage.vSample.jpegData(compressionQuality: 1)!),
            ("W", UIImage.wSample.jpegData(compressionQuality: 1)!),
            ("X", UIImage.xSample.jpegData(compressionQuality: 1)!),
            ("Y", UIImage.ySample.jpegData(compressionQuality: 1)!),
            ("Z", UIImage.zSample.jpegData(compressionQuality: 1)!),
        ]
        
        for detail in defaultProjectDetails {
            let (title, imageData) = detail
            ProjectsDetailsDBHelper.instance.createData(withTitle: title, withImage: imageData, withProjectId: projHid)
        }
    }
}
