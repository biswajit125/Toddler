//
//  NewProjVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 03/04/24.
//

import UIKit

class NewProjVC: UIViewController {
    @IBOutlet weak var vwNewProjContainer: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var cvcNewProjCollection: UICollectionView!
    @IBOutlet weak var btnSave: LoaderButton!
    @IBOutlet weak var txtProjName: UITextField!
    @IBOutlet weak var vwProjNmUnderLine: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var localContents: [CustomLocalContentOfProjModel] = []
    var alreadyUploadedContents: [ProjectsDetailsDB] = []
    var thisHId: UUID?
    var savedProjNm: String = ""
    var savedProjImg: UIImage?
    var thisProj: ProjectsDB?
    
    var imgPickingFor: ImagePickingFor = .forProject
    
    var pickedThumbnail: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        cvcNewProjCollection.delegate = self
        cvcNewProjCollection.dataSource = self
        imagePicker.delegate = self
        initialUiSetup()
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveProjBtnAction(_ sender: UIButton) {
        let allItemsHaveTitles = localContents.allSatisfy { !$0.title.isEmpty }
        if txtProjName.text?.isEmpty == true || isOnlySpaceCharacter(txtProjName.text ?? "") {
            self.vwProjNmUnderLine.backgroundColor = UIColor.red
            self.showAlertWithAction(msg: "Please add a project name.") {
                self.txtProjName.becomeFirstResponder()
            }
        } else if localContents.isEmpty {
            if alreadyUploadedContents.isEmpty {
                self.showAlert(withMsg: "Please add some images and title to save.")
            } else {
                self.showAlert(withMsg: "Already saved. Please add some new images to add.")
            }
        } else if !allItemsHaveTitles {
            self.showAlert(withMsg: "Please add title to all image.")
        } else {
            if thisHId != nil {
                if txtProjName.text != savedProjNm {
                    //update the title before adding
                    updateTitle()
                } else if pickedThumbnail != savedProjImg {
                    updateThumbnail()
                } else {
                    addDetailsOnProj(headerId: thisHId!)
                }
            } else {
                createProj()
            }
        }
        
    }
    @IBAction func playProjBtnAction(_ sender: UIButton) {
        if !alreadyUploadedContents.isEmpty {
            if let playVc = self.storyboard?.instantiateViewController(withIdentifier: "PlayProjectVC") as? PlayProjectVC {
                playVc.currentProjID = thisHId!
                if self.thisProj != nil {
                    playVc.allProj.append(self.thisProj!)
                }
                playVc.accessType = .parent
                self.navigationController?.pushViewController(playVc, animated: true)
            }
        } else {
            self.showAlert(withMsg: "You can't play the project without saving it.\nFirst save the project then play it.")
        }
    }
    
    @IBAction func addThumbnailBtnAction(_ sender: UIButton) {
        imgPickingFor = .forThumbnail
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        })
        //        actionSheet.addAction(UIAlertAction(title: "Search on Google", style: .default) { _ in
        //               self.showGoogleImageSearch()
        //           })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showGoogleImageSearch() {
        let imageSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageSearchViewController") as! ImageSearchViewController
        imageSearchVC.delegate = self
        self.present(imageSearchVC, animated: true, completion: nil)
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwNewProjContainer.layer.borderWidth = 5
        vwNewProjContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwNewProjContainer.layer.shadowOpacity = 0.35
        vwNewProjContainer.layer.shadowRadius = 3
        vwNewProjContainer.layer.shadowColor = UIColor.black.cgColor
        vwNewProjContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        btnBack.layer.borderWidth = 1
        btnBack.layer.borderColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.00).cgColor
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    @objc func pickerBtnAction(_ sender: UIButton) {
        imgPickingFor = .forProject
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        })
        actionSheet.addAction(UIAlertAction(title: "Search on Google", style: .default) { _ in
            self.showGoogleImageSearch()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        })
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        present(actionSheet, animated: true, completion: nil)
    }
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Selected source type is not available")
        }
    }
    
    //check is the text only space character on not
    func isOnlySpaceCharacter(_ text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    //method to create new project
    func createProj() {
        self.savedProjNm = txtProjName.text ?? ""
        let imgData = pickedThumbnail?.jpegData(compressionQuality: 0.80)
        self.savedProjImg = pickedThumbnail
        self.thisHId = ProjectsDBHelper.instance.createData(withName: txtProjName.text ?? "Untitled", isEditable: true, thumbnail: imgData, userId: globalLoggedInUserId)
        self.vwProjNmUnderLine.backgroundColor = UIColor.app757575
        if let hId = thisHId {
            self.addDetailsOnProj(headerId: hId)
        } else {
            self.showAlert(withMsg: "Error occurred while creating a new project. Please try again.")
        }
    }
    
    //method to add details & images in the project
    func addDetailsOnProj(headerId: UUID) {
        for (index, item) in localContents.enumerated() {
            if let imgData = item.image?.jpegData(compressionQuality: 0.80) {
                ProjectsDetailsDBHelper.instance.createData(withTitle: item.title, withImage: imgData, withProjectId: headerId)
            }
        }
        self.fetchProjectById(hid: headerId)
        //self.showAlert(withMsg: "Project saved successfully.")
        self.showAlertWithAction(msg: "Project saved successfully.") {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    //fetch the project and refresh the list
    func fetchProjectById(hid: UUID) {
        localContents = []
        let projects = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
        self.thisProj = projects.first(where: {$0.id == hid})
        let projectsDetails = ProjectsDetailsDBHelper.instance.loadData()
        let filteredProjDetails = projectsDetails.filter({$0.projid == hid})
        self.alreadyUploadedContents = filteredProjDetails
        self.cvcNewProjCollection.reloadData()
    }
    
    //func update project title if changed
    func updateTitle() {
        ProjectsDBHelper.instance.updateData(withId: thisHId!, name: txtProjName.text ?? "")
        self.savedProjNm = txtProjName.text ?? ""
        self.vwProjNmUnderLine.backgroundColor = UIColor.app757575
        if pickedThumbnail != nil {
            updateThumbnail()
        } else if self.localContents.isEmpty {
            self.showAlert(withMsg: "Project Name Updated Successfully.")
        } else {
            self.addDetailsOnProj(headerId: self.thisHId!)
        }
    }
    
    //func update project thumbnail if changed
    func updateThumbnail() {
        let imgData = pickedThumbnail?.jpegData(compressionQuality: 0.80)
        savedProjImg = pickedThumbnail
        ProjectsDBHelper.instance.updateThumbnail(withId: thisHId!, thumbnail: imgData)
        if self.localContents.isEmpty {
            self.showAlert(withMsg: "Project Updated Successfully.")
        } else {
            self.addDetailsOnProj(headerId: self.thisHId!)
        }
    }
    
}

//collection view delegate and datasource
extension NewProjVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localContents.count+1+alreadyUploadedContents.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let existingContentCount = alreadyUploadedContents.count
        
        if indexPath.item == 0 {
            //add new button
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewImgInNewProjCVC", for: indexPath) as? AddNewImgInNewProjCVC {
                cell.btnAdd.addTarget(self, action: #selector(pickerBtnAction(_ :)), for: .touchUpInside)
                return cell
            }
        } else if localContents.count != 0 && indexPath.item <= localContents.count {
            //newly added not saved
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeImgInNewProjCVC", for: indexPath) as? SeeImgInNewProjCVC {
                cell.txtTitleField.isEnabled = true
                cell.vwTitleContainer.backgroundColor = UIColor.white
                cell.txtTitleField.delegate = self
                cell.txtTitleField.tag = indexPath.item-1
                cell.imgImageView.image = localContents[indexPath.item-1].image
                cell.txtTitleField.text = localContents[indexPath.item-1].title
                return cell
            }
        } else {
            //already saved
            let projD = alreadyUploadedContents[indexPath.item-localContents.count-1]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeImgInNewProjCVC", for: indexPath) as? SeeImgInNewProjCVC {
                cell.txtTitleField.delegate = self
                cell.txtTitleField.isEnabled = false
                cell.vwTitleContainer.backgroundColor = UIColor.systemGray5
                cell.txtTitleField.text = projD.title
                if let imageData = projD.image {
                    // Convert Data to UIImage
                    if let image = UIImage(data: imageData) {
                        cell.imgImageView.image = image
                    }
                }
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 270)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

//image picker controller
extension NewProjVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if imgPickingFor == .forProject {
            if let pickedImage = info[.editedImage] as? UIImage {
                // imageView.image = pickedImage
                print("point 3.0 --> ", pickedImage)
                localContents.append(CustomLocalContentOfProjModel(image: pickedImage, title: ""))
                cvcNewProjCollection.reloadData()
            }
        } else if imgPickingFor == .forThumbnail {
            if let pickedImage = info[.editedImage] as? UIImage {
                pickedThumbnail = pickedImage
                imgThumbnail.image = pickedImage
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//title textfield delegate to identify and save each
extension NewProjVC: UITextFieldDelegate {
 
    // UITextFieldDelegate method to monitor text changes
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Get the current text
//        let currentText = textField.text ?? ""
//        
//        // Create the new text string
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//        
//        // Convert the new text to uppercase
//        let uppercaseText = updatedText.uppercased()
//        
//        // Set the text field's text to the uppercase text
//        textField.text = currentText
//        
//        // Return false since we have manually updated the text
//        return true
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text
        let currentText = textField.text ?? ""
        
        // Create the new text string
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Capitalize the first letter of each word in the updated text
        let capitalizedText = updatedText.capitalized
        
        // Set the text field's text to the capitalized text
        textField.text = capitalizedText
        
        // Return false since we have manually updated the text
        print("Text changed \(textField.tag) : \(textField.text ?? "")")
        
        return false
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == txtProjName {
//            print("test",textField)
//        }else {
//            let index = textField.tag
//            print("index --> ", index, "text --> ", textField.text)
//            localContents[index].title = textField.text ?? ""
//            cvcNewProjCollection.reloadData()
//        }
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if textField == txtProjName {
            print("test", textField)
        } else {
            localContents[textField.tag].title = text
            print("index --> ", textField.tag, "text --> ", text)
            cvcNewProjCollection.reloadData()
        }
    }

}

enum ImagePickingFor {
    case forThumbnail
    case forProject
    case addNew
    case editNewAdded
}
extension NewProjVC: ImageSearchDelegate {
    func didSelectImage(_ image: UIImage) {
        if imgPickingFor == .forProject {
            localContents.append(CustomLocalContentOfProjModel(image: image, title: ""))
            cvcNewProjCollection.reloadData()
        } else if imgPickingFor == .forThumbnail {
            pickedThumbnail = image
            imgThumbnail.image = image
        }
    }
}
