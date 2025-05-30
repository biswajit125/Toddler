//
//  EditProjectVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 04/04/24.
//

import UIKit

class EditProjectVC: UIViewController {
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var cvCollectionView: UICollectionView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var txtProjectName: UITextField!
    @IBOutlet weak var vwProjNmUnderLine: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    var projHid: UUID!
    var existingProj: ProjectsDB?
    var existingContents: [ProjectsDetailsDB] = []
    let imagePicker = UIImagePickerController()
    var localContents: [CustomLocalContentOfProjForEditingModel] = []
    var newAddedLocalContents: [CustomLocalContentOfProjModel] = []
    //var serverContents: [CustomLocalContentOfProjForEditingModel] = []
    var enabledTxtFieldDIdArray: [UUID] = []
    var currentlyEditingIndex: Int = 0
    
    var imgPickingFor: ImagePickingFor = .forProject
    var pickedThumbnail: UIImage?
    
    var editProjectsCVC = EditProjectsCVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        cvCollectionView.delegate = self
        cvCollectionView.dataSource = self
        imagePicker.delegate = self
        initialUiSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cvCollectionView.isUserInteractionEnabled = true
        fetchProjectById(shouldResetFlags: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        rollbackChanges()
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
    
    func rollbackChanges() {
        print("rollbackChanges >>> ")
        let context = ProjectsDBHelper.instance.context
        context.rollback()
    }
    
    
    @IBAction func projNmEditBtnAction(_ sender: UIButton) {
        txtProjectName.isEnabled = true
        txtProjectName.becomeFirstResponder()
    }
    @IBAction func saveBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        print(localContents)
        let allItemsHaveTitles = newAddedLocalContents.allSatisfy { !$0.title.isEmpty }
        if localContents.isEmpty  && (txtProjectName.text == existingProj?.name) && pickedThumbnail == nil && newAddedLocalContents.isEmpty {
            self.showAlert(withMsg: "No changes made to save.")
        } else if txtProjectName.text?.isEmpty == true {
            self.showAlert(withMsg: "Project name can not be blank.")
        } else if !allItemsHaveTitles {
            self.showAlert(withMsg: "Please add title to all image.")
        } else if !newAddedLocalContents.isEmpty {
            addDetailsOnProj(headerId: projHid!)
        } else if (txtProjectName.text != existingProj?.name) {
            //update title and contents
            updateTitle()
        } else if pickedThumbnail != nil {
            //thumbnail changed
            updateThumbnail()
        } else {
            //no need to update title or images
            updateEditedDetails()
        }
    }
    @IBAction func playBtnAction(_ sender: UIButton) {
        if localContents.isEmpty && !existingContents.isEmpty && (txtProjectName.text == existingProj?.name) && newAddedLocalContents.isEmpty {
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
    @IBAction func pickThumbnailBtnAction(_ sender: UIButton) {
        imgPickingFor = .forThumbnail
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            self.showImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            self.showImagePicker(sourceType: .camera)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        print("endEditing Called")
        //self.view.endEditing(false)
    }
    
    func initialUiSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        vwContainer.layer.borderWidth = 5
        vwContainer.layer.borderColor = UIColor.appGolden.cgColor
        vwContainer.layer.shadowOpacity = 0.35
        vwContainer.layer.shadowRadius = 3
        vwContainer.layer.shadowColor = UIColor.black.cgColor
        vwContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        btnBack.layer.borderWidth = 1
        btnBack.layer.borderColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.00).cgColor
        
        txtProjectName.text = existingProj?.name ?? ""
        if let thumbnailData = existingProj?.thumbnail, let thumbnailImg = UIImage(data: thumbnailData) {
            imgThumbnail.image = thumbnailImg
        }
        txtProjectName.isEnabled = false
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
    
    //method to add details & images in the project
    func addDetailsOnProj(headerId: UUID) {
        for (_, item) in newAddedLocalContents.enumerated() {
            if let imgData = item.image?.jpegData(compressionQuality: 0.80) {
                ProjectsDetailsDBHelper.instance.createData(withTitle: item.title, withImage: imgData, withProjectId: headerId)
            }
        }
        self.newAddedLocalContents = []
        if (txtProjectName.text != existingProj?.name) {
            updateTitle()
        } else if pickedThumbnail != nil {
            updateThumbnail()
        } else if self.localContents.isEmpty {
            self.fetchProjectById(shouldResetFlags: true)
            self.showAlert(withMsg: "Project saved successfully.")
        } else {
            self.updateEditedDetails()
        }
    }
    
    //func update project title if changed
    func updateTitle() {
        ProjectsDBHelper.instance.updateData(withId: projHid, name: txtProjectName.text ?? "")
        self.vwProjNmUnderLine.backgroundColor = UIColor.app757575
        if pickedThumbnail != nil {
            updateThumbnail()
        } else if self.localContents.isEmpty {
            self.fetchProjectById(shouldResetFlags: false)
            self.showAlert(withMsg: "Project Name Updated Successfully.")
        } else {
            self.updateEditedDetails()
        }
    }
    
    //func update project thumbnail if changed
    func updateThumbnail() {
        let imgData = pickedThumbnail?.jpegData(compressionQuality: 0.80)
        ProjectsDBHelper.instance.updateThumbnail(withId: projHid, thumbnail: imgData)
        if self.localContents.isEmpty {
            self.fetchProjectById(shouldResetFlags: false)
            self.showAlert(withMsg: "Project Updated Successfully.")
        } else {
            self.updateEditedDetails()
        }
    }
    
    func updateEditedDetails() {
        for (index, item) in localContents.enumerated() {
            if let imgData = item.image?.jpegData(compressionQuality: 0.80) {
                ProjectsDetailsDBHelper.instance.updateData(withId: item.hId!, title: item.title, image: imgData)
            }
        }
        self.fetchProjectById(shouldResetFlags: true)
        self.showAlert(withMsg: "Project saved successfully.")
    }
    
    func deleteDetails(dId: UUID) {
        ProjectsDetailsDBHelper.instance.deleteData(withId: dId)
        //remove if edited the data before deleting
        if let existingIndex = self.localContents.firstIndex(where: {$0.hId == dId}) {
            self.localContents.remove(at: existingIndex)
        }
        self.showAlert(withMsg: "Deleted successfully.")
        self.fetchProjectById(shouldResetFlags: false)
    }
    
    //fetch the project and refresh the list
    func fetchProjectById(shouldResetFlags: Bool) {
        //reset all flags and temp storages
        if shouldResetFlags {
            currentlyEditingIndex = 0
            enabledTxtFieldDIdArray = []
            localContents = []
        }
        
        let projects = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
        self.existingProj = projects.first(where: {$0.id == projHid})
        self.txtProjectName.text = self.existingProj?.name ?? ""
        if let thumbnailData = existingProj?.thumbnail, let thumbnailImg = UIImage(data: thumbnailData) {
            imgThumbnail.image = thumbnailImg
        }
        let projectsDetails = ProjectsDetailsDBHelper.instance.loadData()
        let filteredProjDetails = projectsDetails.filter({$0.projid == projHid})
        self.existingContents = filteredProjDetails
        self.cvCollectionView.reloadData()
    }
}

//MARK: - collection view delegate and datasource
extension EditProjectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1+existingContents.count+newAddedLocalContents.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewImgInNewProjCVC", for: indexPath) as? AddNewImgInNewProjCVC {
                cell.btnAdd.addTarget(self, action: #selector(pickerBtnAction(_ :)), for: .touchUpInside)
                return cell
            }
        } else if indexPath.item <= existingContents.count { // existion or older one
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProjectsCVC", for: indexPath) as? EditProjectsCVC {
                
                cell.txtTitle.text = existingContents[indexPath.item-1].title
                if let imgData = existingContents[indexPath.item-1].image {
                    cell.img.image = UIImage(data: imgData)
                } else {
                    cell.img.image = nil
                }
                
                cell.btnEdit.tag = indexPath.item-1 //
                cell.btnEdit.addTarget(self, action: #selector(editImgAction(_ :)), for: .touchUpInside)
                cell.btnEditTitle.tag = indexPath.item
                cell.btnEditTitle.isHidden = false
                cell.btnEditTitle.accessibilityIdentifier = "old_EditTitleBtn"
                cell.txtTitle.tag = indexPath.item
                cell.txtTitle.delegate = self
                //cell.isUserInteractionEnabled = true
                cell.txtTitle.accessibilityIdentifier = "old_TextField"
                cell.txtTitle.returnKeyType = .done  // Set return key to "Done"
                cell.vwTitleContainer.backgroundColor = UIColor.systemGray5
                cell.txtTitle.isUserInteractionEnabled = false
                
                if enabledTxtFieldDIdArray.contains(existingContents[indexPath.item-1].id!) {
//                    cell.txtTitle.isEnabled = true
//                    cell.txtTitle.isUserInteractionEnabled = true
//                    cell.txtTitle.endEditing(false)
//                    cell.vwTitleContainer.backgroundColor = UIColor.white
                    
                    //self.view.endEditing(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        cell.isUserInteractionEnabled = true
                        cell.txtTitle.isUserInteractionEnabled = true
                        cell.txtTitle.isEnabled = true
                        cell.txtTitle.becomeFirstResponder()
                        cell.vwTitleContainer.backgroundColor = UIColor.white
                    }
                }else {
                    
                    //cell.txtTitle.isEnabled = false
//                    cell.txtTitle.isUserInteractionEnabled = false
//                    //cell.txtTitle.endEditing(true)
//                    cell.vwTitleContainer.backgroundColor = UIColor.systemGray5
                }
                
                //cell.btnEditTitle.addTarget(self, action: #selector(editTitleBtnAction(_ :)), for: .touchUpInside)
                cell.btnDelete.tag = indexPath.item
                cell.btnDelete.addTarget(self, action: #selector(deleteDetailsBtnAction(_ :)), for: .touchUpInside)
                return cell
            }
        } else { // newly added one
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProjectsCVC", for: indexPath) as? EditProjectsCVC {
                
                cell.txtTitle.text = newAddedLocalContents[indexPath.item-1-existingContents.count].title
                if let img = newAddedLocalContents[indexPath.item-1-existingContents.count].image {
                    cell.img.image = img
                } else {
                    cell.img.image = nil
                }
                
                cell.btnEdit.tag = indexPath.item-1-existingContents.count
                cell.btnEdit.addTarget(self, action: #selector(editNewAddedImgAction(_ :)), for: .touchUpInside)
                cell.btnEditTitle.tag = indexPath.item-1-existingContents.count //
                cell.btnEditTitle.isHidden = true
                cell.txtTitle.tag = indexPath.item-1-existingContents.count // indexPath.item - 1
                cell.txtTitle.delegate = self
                cell.txtTitle.isEnabled = true
                cell.txtTitle.returnKeyType = .done  // Set return key to "Done"
                cell.txtTitle.accessibilityIdentifier = "new_TextField"
                cell.txtTitle.isUserInteractionEnabled = true
                cell.vwTitleContainer.backgroundColor = UIColor.white
                cell.btnDelete.tag = indexPath.item
                cell.btnDelete.addTarget(self, action: #selector(deleteDetailsBtnAction(_ :)), for: .touchUpInside)
                return cell
            }
        }
        
//        else if indexPath.item <= newAddedLocalContents.count {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProjectsCVC", for: indexPath) as? EditProjectsCVC {
//                cell.txtTitle.text = newAddedLocalContents[indexPath.item-1].title
//                if let img = newAddedLocalContents[indexPath.item-1].image {
//                    cell.img.image = img
//                } else {
//                    cell.img.image = nil
//                }
//
//                cell.btnEdit.tag = indexPath.item-1
//                cell.btnEdit.addTarget(self, action: #selector(editNewAddedImgAction(_ :)), for: .touchUpInside)
//                cell.btnEditTitle.tag = indexPath.item
//                cell.txtTitle.tag = indexPath.item
//                cell.txtTitle.delegate = self
//                cell.txtTitle.isEnabled = true
//                cell.vwTitleContainer.backgroundColor = UIColor.white
//                cell.btnDelete.tag = indexPath.item
//                cell.btnDelete.addTarget(self, action: #selector(deleteDetailsBtnAction(_ :)), for: .touchUpInside)
//                return cell
//            }
//        } else {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProjectsCVC", for: indexPath) as? EditProjectsCVC {
//                cell.txtTitle.text = existingContents[indexPath.item-1-newAddedLocalContents.count].title
//                if let imgData = existingContents[indexPath.item-1-newAddedLocalContents.count].image {
//                    cell.img.image = UIImage(data: imgData)
//                } else {
//                    cell.img.image = nil
//                }
//
//                cell.btnEdit.tag = indexPath.item-1-newAddedLocalContents.count
//                cell.btnEdit.addTarget(self, action: #selector(editImgAction(_ :)), for: .touchUpInside)
//                cell.btnEditTitle.tag = indexPath.item
//                cell.btnEditTitle.addTarget(self, action: #selector(editTitleBtnAction(_ :)), for: .touchUpInside)
//                cell.txtTitle.tag = indexPath.item
//                cell.txtTitle.delegate = self
//                //cell.txtTitle.isEnabled = enabledTxtFieldDIdArray.contains(serverContents[indexPath.item].hId!)
//                if enabledTxtFieldDIdArray.contains(existingContents[indexPath.item-1-newAddedLocalContents.count].id!) {
//                    cell.txtTitle.isEnabled = true
//                    cell.vwTitleContainer.backgroundColor = UIColor.white
//                } else {
//                    cell.txtTitle.isEnabled = false
//                    cell.vwTitleContainer.backgroundColor = UIColor.systemGray5
//                }
//                cell.btnDelete.tag = indexPath.item
//                cell.btnDelete.addTarget(self, action: #selector(deleteDetailsBtnAction(_ :)), for: .touchUpInside)
//                return cell
//            }
//        }
        
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
    
    @objc func pickerBtnAction(_ sender: UIButton) {
        imgPickingFor = .addNew
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
    func showGoogleImageSearch() {
        let imageSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageSearchViewController") as! ImageSearchViewController
        imageSearchVC.delegate = self
        self.present(imageSearchVC, animated: true, completion: nil)
    }
    
    @objc func editImgAction(_ sender: UIButton) {
        imgPickingFor = .forProject
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            print("Edit btn tag",sender.tag)
            self.showImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            print("Edit btn tag",sender.tag)
            self.showImagePicker(sourceType: .camera)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func titleEditBtnTapped(_ sender: UIButton) {
        debugPrint("Title Edit Btn Tapped >>> ", sender.tag)
//        if sender.accessibilityIdentifier == "old_EditTitleBtn" {
//            let index = sender.tag
//            let id = existingContents[index-self.newAddedLocalContents.count-1].id
//            enabledTxtFieldDIdArray.removeAll()
//            if !enabledTxtFieldDIdArray.contains(id!) {
//                enabledTxtFieldDIdArray.append(id!)
//            }
//            cvCollectionView.reloadData()
//        }
        
        if sender.accessibilityIdentifier == "old_EditTitleBtn" {
            let indexPath = IndexPath(item: sender.tag, section: 0)
            if let cell = cvCollectionView.cellForItem(at: indexPath) as? EditProjectsCVC {
                // You now have a reference to the cell.
                print("Cell found: ")
                print("Edit text Tapped >>> ", cell.txtTitle.text )
                self.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    cell.isUserInteractionEnabled = true
                    cell.txtTitle.isUserInteractionEnabled = true
                    cell.txtTitle.isEnabled = true
                    cell.txtTitle.becomeFirstResponder()
                    cell.vwTitleContainer.backgroundColor = UIColor.white
                }
            } else {
                print("Cell not found")
            }
        }
        
        
    }
    
    @objc func editTitleBtnAction(_ sender: UIButton) {
        print("Edit Btn Tapped >>> ", sender.tag)
        
//        let indexPath = IndexPath(item: sender.tag, section: 0)
//        if let cell = cvCollectionView.cellForItem(at: indexPath) as? EditProjectsCVC {
//            // You now have a reference to the cell.
//            print("Cell found: ")
//            print("Edit text Tapped >>> ", cell.txtTitle.text )
//            self.view.endEditing(true)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                cell.isUserInteractionEnabled = true
//                cell.txtTitle.isUserInteractionEnabled = true
//                cell.txtTitle.isEnabled = true
//                cell.txtTitle.becomeFirstResponder()
//                cell.vwTitleContainer.backgroundColor = UIColor.white
//            }
//        } else {
//            print("Cell not found")
//        }
        
        let index = sender.tag
        //-1-newAddedLocalContents.count
        if index-1 < newAddedLocalContents.count {
            //for newly added
            //nothing to implement
        } else {
            let id = existingContents[index-self.newAddedLocalContents.count-1].id
            enabledTxtFieldDIdArray.removeAll()
            if !enabledTxtFieldDIdArray.contains(id!) {
                enabledTxtFieldDIdArray.append(id!)
            }
            cvCollectionView.reloadData()
        }
        
        
    }
    
    @objc func deleteDetailsBtnAction(_ sender: UIButton) {
        let index = sender.tag
        if index-1 < newAddedLocalContents.count {
            //for newly added
            let alert = UIAlertController(title: "Are you sure you want to delete the image?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.newAddedLocalContents.remove(at: index-1)
                self.cvCollectionView.reloadData()
            }))
            self.present(alert, animated: true)
        } else {
            //for already uploaded
            let alert = UIAlertController(title: "Are you sure you want to delete the image?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteDetails(dId: self.existingContents[index-self.newAddedLocalContents.count-1].id!)
            }))
            self.present(alert, animated: true)
        }
    }
    
    //edit image newly added
    @objc func editNewAddedImgAction(_ sender: UIButton) {
        imgPickingFor = .editNewAdded
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            self.showImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.currentlyEditingIndex = sender.tag
            self.showImagePicker(sourceType: .camera)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        
        present(actionSheet, animated: true, completion: nil)
    }
}

//image picker controller
extension EditProjectVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if imgPickingFor == .forProject {
            if let pickedImage = info[.editedImage] as? UIImage {
                // imageView.image = pickedImage
                print("point 3.0 --> ", pickedImage)
                existingContents[currentlyEditingIndex].image = pickedImage.jpegData(compressionQuality: 0.80)
                if let existingIndex = localContents.firstIndex(where: {$0.hId == existingContents[currentlyEditingIndex].id }) {
                    //already edited.. Title caould be saved
                    localContents[existingIndex].image = pickedImage
                } else {
                    //editing new
                    localContents.append(CustomLocalContentOfProjForEditingModel(hId: existingContents[currentlyEditingIndex].id, image: pickedImage, title: existingContents[currentlyEditingIndex].title ?? ""))
                }
                
                cvCollectionView.reloadData()
            }
        } else if imgPickingFor == .forThumbnail {
            if let pickedImage = info[.editedImage] as? UIImage {
                pickedThumbnail = pickedImage
                imgThumbnail.image = pickedImage
            }
        } else if imgPickingFor == .addNew {
            if let pickedImage = info[.editedImage] as? UIImage {
                // imageView.image = pickedImage
                print("addNew ::")
                print("point 3.1 --> ", pickedImage)
                //newAddedLocalContents.append(CustomLocalContentOfProjModel(image: pickedImage, title: ""))
                
                // Create an instance of CustomLocalContentOfProjModel
                let newContent = CustomLocalContentOfProjModel(image: pickedImage, title: "")

                // Add the instance to the end of the array
                newAddedLocalContents.append(newContent)
                
                for item in newAddedLocalContents {
                    print("title :: ", item.title)
                }
                
                cvCollectionView.reloadData()
            }
        } else if imgPickingFor == .editNewAdded {
            print("editNewAdded ::", currentlyEditingIndex)
            if let pickedImage = info[.editedImage] as? UIImage {
                newAddedLocalContents[currentlyEditingIndex].image = pickedImage
                cvCollectionView.reloadData()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//title textfield delegate to identify and save each
extension EditProjectVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        enabledTxtFieldDIdArray.removeAll()
        textField.resignFirstResponder()  // Dismiss the keyboard
        
        // identify the text field (new or existing)
        let accessibilityIdentifier = textField.accessibilityIdentifier
        if let accessibilityIdentifier = accessibilityIdentifier {
            if accessibilityIdentifier == "new_TextField" {
                print("new_TextField")
                print("\(newAddedLocalContents.count) index --> ", textField.tag, "text --> ", textField.text ?? "")
                if newAddedLocalContents.count > textField.tag {
                    newAddedLocalContents[textField.tag].title = textField.text ?? ""
                }
                
            }else{
                //                print("old_TextField")
                //                //already uploaded
                //                print("index --> ", textField.tag-1, "text --> ", textField.text)
                //                //existingContents[index-newAddedLocalContents.count-1].title = textField.text ?? ""
                //                existingContents[textField.tag-1].title = textField.text ?? ""
                //                
                //                print("\(existingContents.count) index --> ", index-newAddedLocalContents.count-1, "text --> ", textField.text ?? "")
                //                if let existingIndex = localContents.firstIndex(where: {$0.hId == existingContents[textField.tag-1].id }) {
                //                  //already edited.. Image or title caould be saved
                //                    localContents[textField.tag-1].title = textField.text ?? ""
                //                } else {
                //                    //editing new
                //                    print("index --> ", textField.tag-1, "text --> ", textField.text)
                //                    localContents.append(CustomLocalContentOfProjForEditingModel(hId: existingContents[textField.tag-1].id, image: UIImage(data: existingContents[textField.tag-1].image ?? Data()), title: textField.text ?? ""))
                //                }
                //                
                //                
                //                textField.isUserInteractionEnabled = false
                
                
                print("old_TextField")
                //already uploaded
                if existingContents.count > textField.tag-1 {
                    print("index --> ", textField.tag-1, "text --> ", textField.text)
                    //existingContents[index-newAddedLocalContents.count-1].title = textField.text ?? ""
                    existingContents[textField.tag-1].title = textField.text ?? ""
                    
                    print("\(existingContents.count) index --> ", index-newAddedLocalContents.count-1, "text --> ", textField.text ?? "")
                    if let existingIndex = localContents.firstIndex(where: {$0.hId == existingContents[textField.tag-1].id }) {
                        //already edited.. Image or title caould be saved
                        //localContents[textField.tag-1].title = textField.text ?? ""
                        localContents[existingIndex].title = textField.text ?? ""
                    } else {
                        //editing new
                        print("index --> ", textField.tag-1, "text --> ", textField.text)
                        localContents.append(CustomLocalContentOfProjForEditingModel(hId: existingContents[textField.tag-1].id, image: UIImage(data: existingContents[textField.tag-1].image ?? Data()), title: textField.text ?? ""))
                    }
                }
                textField.isUserInteractionEnabled = false
                
            }
            
        }
        let indexPath = IndexPath(item: index, section: 0)
        cvCollectionView.reloadItems(at: [indexPath])
    }
}



//title textfield delegate to identify and save each
extension EditProjectVC {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        let index = textField.tag
//        print("index --> ", index, "text --> ", textField.text)
//        localContents[index].title = textField.text ?? ""
//        cvcNewProjCollection.reloadData()
//    }
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
//        textField.text = updatedText //uppercaseText
//        
//        // Return false since we have manually updated the text
//        
//        print("Text changed \(textField.tag) : \(textField.text)")
//        
//        return false
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Dismiss the keyboard
        return true
    }
}

extension EditProjectVC: ImageSearchDelegate {
    func didSelectImage(_ image: UIImage) {
        if imgPickingFor == .forProject {
            localContents.append(CustomLocalContentOfProjForEditingModel(image: image, title: ""))
            cvCollectionView.reloadData()
        } else if imgPickingFor == .forThumbnail {
            pickedThumbnail = image
            imgThumbnail.image = image
        }
    }
}
