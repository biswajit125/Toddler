//
//  ToddlerSetupVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 02/04/24.
//

import UIKit

class ToddlerSetupVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vwNameContainer: UIView!
    @IBOutlet weak var vwDobContainer: UIView!
    @IBOutlet weak var vwSetupContainer: UIView!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnSave: LoaderButton!
    
    private let dobDatePicker = UIDatePicker()
    private var dobPickedDate: Date!
    
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
        txtName.delegate = self
        txtDob.delegate = self
        initialUiSetup()
        addInputViewDatePicker()
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        if txtName.text?.isEmpty == true {
            self.showAlertWithAction(msg: "Please enter the name of the child.") {
                self.txtName.becomeFirstResponder()
            }
        } else if txtDob.text?.isEmpty == true {
            self.showAlertWithAction(msg: "Please enter the date of birth of the child.") {
                self.txtDob.becomeFirstResponder()
            }
        } else {
            ChildEntry()
        }
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwNameContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwNameContainer.layer.borderWidth = 1
        
        vwDobContainer.layer.borderColor = UIColor.appBorder.cgColor
        vwDobContainer.layer.borderWidth = 1
        
        vwSetupContainer.layer.shadowOpacity = 0.25
        vwSetupContainer.layer.shadowRadius = 3
        vwSetupContainer.layer.shadowColor = UIColor.black.cgColor
        vwSetupContainer.layer.shadowOffset = CGSize(width: 4, height: 4)
        
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
    
    func ChildEntry() {
        if let userId = globalLoggedInUserId {
            globalChildName = txtName.text ?? ""
            globalChildDob = txtDob.text ?? ""
            
            UsersDBHelper.instance.updateChildDetails(withId: userId, childName: txtName.text ?? "", childDob: txtDob.text ?? "")
            if let pathVc = self.storyboard?.instantiateViewController(withIdentifier: "ChoosePathVC") as? ChoosePathVC {
                self.navigationController?.pushViewController(pathVc, animated: true)
            }
        } else {
            showAlertWithAction(msg: "Can not save child info. Please login again.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Get the current text
//        let currentText = textField.text ?? ""
//        
//        // Create the new text string
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//        
//        // Capitalize the first letter of each word in the updated text
//        let capitalizedText = updatedText.capitalized
//        
//        // Set the text field's text to the capitalized text
//        textField.text = capitalizedText
//        
//        // Return false since we have manually updated the text
//        print("Text changed \(textField.tag) : \(textField.text ?? "")")
//        
//        
//        
//        return false
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace
        if string.isEmpty {
            return true
        }
        
        // Get the current text
        let currentText = textField.text ?? ""
        
        // Create the new text string
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Capitalize the first letter of each word
        let capitalizedText = updatedText.capitalized
        
        print("Text changed \(textField.tag): \(capitalizedText)")
        
        // Update textField text manually and return false to prevent default behavior
        if textField == txtName {
            textField.text = capitalizedText
            return false
        }
        
        return true
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtName {
            txtDob.becomeFirstResponder()
        }
        return true
    }
}

 //MARK: - all objc methods
 extension ToddlerSetupVC {
     @objc func hideKeyboard() {
         self.view.endEditing(true)
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
 }
