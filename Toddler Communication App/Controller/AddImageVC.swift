//
//  AddImageVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 04/04/24.
//

import UIKit

class AddImageVC: UIViewController {
    @IBOutlet weak var cvAddImgCollection: UICollectionView!
    @IBOutlet weak var vwAddImgViewContainer: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtProjName: UITextField!
    @IBOutlet weak var vwProjNmUnderLine: UIView!
    
    var projHid: UUID!
    var existingProj: ProjectsDB?
    var existingContents: [ProjectsDetailsDB] = []
    let imagePicker = UIImagePickerController()
    var localContents: [CustomLocalContentOfProjModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        cvAddImgCollection.delegate = self
        cvAddImgCollection.dataSource = self
        imagePicker.delegate = self
        initialUiSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchProjectById()
    }

    @IBAction func backBtnAction(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is ProjectsVC {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
    @IBAction func saveBtnAction(_ sender: UIButton) {
        let allItemsHaveTitles = localContents.allSatisfy { !$0.title.isEmpty }
        if localContents.isEmpty {
            self.showAlert(withMsg: "No new images added to save. Please add some new images.")
        } else if !allItemsHaveTitles {
            self.showAlert(withMsg: "Please add title to all image.")
        } else if txtProjName.text?.isEmpty == true {
            self.vwProjNmUnderLine.backgroundColor = UIColor.red
            self.showAlertWithAction(msg: "Please add a project name.") {
                self.txtProjName.becomeFirstResponder()
            }
        } else {
            if existingProj?.name != txtProjName.text {
                updateTitle()
            } else {
                addDetailsOnProj(headerId: projHid)
            }
        }
    }
    @IBAction func playProjBtnAction(_ sender: UIButton) {
        if localContents.isEmpty && !existingContents.isEmpty {
            if let playVc = self.storyboard?.instantiateViewController(withIdentifier: "PlayProjectVC") as? PlayProjectVC {
                playVc.currentProjID = projHid
                playVc.allProj.append(self.existingProj!)
                playVc.accessType = .parent
                self.navigationController?.pushViewController(playVc, animated: true)
            }
        } else {
            self.showAlert(withMsg: "You can't play the project without saving it.\nFirst save the project then play it.")
        }
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwAddImgViewContainer.layer.borderWidth = 5
        vwAddImgViewContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwAddImgViewContainer.layer.shadowOpacity = 0.35
        vwAddImgViewContainer.layer.shadowRadius = 3
        vwAddImgViewContainer.layer.shadowColor = UIColor.black.cgColor
        vwAddImgViewContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        btnBack.layer.borderWidth = 1
        btnBack.layer.borderColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.00).cgColor
        
        txtProjName.text = existingProj?.name ?? ""
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    @objc func pickerBtnAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
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
    
    //func update project title if changed
    func updateTitle() {
        ProjectsDBHelper.instance.updateData(withId: projHid, name: txtProjName.text ?? "")
        self.vwProjNmUnderLine.backgroundColor = UIColor.app757575
        if self.localContents.isEmpty {
            self.showAlert(withMsg: "Project Name Updated Successfully.")
        } else {
            self.addDetailsOnProj(headerId: self.projHid)
        }
    }
    
    //method to add details & images in the project
    func addDetailsOnProj(headerId: UUID) {
        for (index, item) in localContents.enumerated() {
            if let imgData = item.image?.jpegData(compressionQuality: 0.80) {
                ProjectsDetailsDBHelper.instance.createData(withTitle: item.title, withImage: imgData, withProjectId: headerId)
            }
        }
        self.fetchProjectById()
        self.showAlert(withMsg: "Project saved successfully.")
    }
    
    //fetch the project and refresh the list
    func fetchProjectById() {
        localContents = []
        let projects = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
        self.existingProj = projects.first(where: {$0.id == projHid})
        self.txtProjName.text = self.existingProj?.name ?? ""
        let projectsDetails = ProjectsDetailsDBHelper.instance.loadData()
        let filteredProjDetails = projectsDetails.filter({$0.projid == projHid})
        self.existingContents = filteredProjDetails
        self.cvAddImgCollection.reloadData()
    }
}

//MARK: - collection view delegate and datasource
extension AddImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localContents.count+1+existingContents.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewImgInNewProjCVC", for: indexPath) as? AddNewImgInNewProjCVC {
                cell.btnAdd.addTarget(self, action: #selector(pickerBtnAction(_ :)), for: .touchUpInside)
                return cell
            }
        } else if indexPath.item <= localContents.count {
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
            let projD = existingContents[indexPath.item-1-localContents.count]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeImgInNewProjCVC", for: indexPath) as? SeeImgInNewProjCVC {
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
extension AddImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            // imageView.image = pickedImage
            print("point 3.0 --> ", pickedImage)
            localContents.append(CustomLocalContentOfProjModel(image: pickedImage, title: ""))
            cvAddImgCollection.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//title textfield delegate to identify and save each
extension AddImageVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text
        let currentText = textField.text ?? ""
        
        // Create the new text string
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Convert the new text to uppercase
        let uppercaseText = updatedText.uppercased()
        
        // Set the text field's text to the uppercase text
        textField.text = uppercaseText
        
        // Return false since we have manually updated the text
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        print("index --> ", index, "text --> ", textField.text)
        localContents[index].title = textField.text ?? ""
        cvAddImgCollection.reloadData()
    }
}
