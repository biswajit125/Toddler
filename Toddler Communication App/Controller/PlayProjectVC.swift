//
//  PlayProjectVC.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 05/04/24.
//

import UIKit
import AVFoundation
import Speech
import NaturalLanguage



class PlayProjectVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var cvImagesCollection: UICollectionView!
    @IBOutlet weak var vwControllContainer: UIView!
    @IBOutlet weak var vwFullScreenContainer: UIView!
    @IBOutlet weak var tblProjList: UITableView!
    @IBOutlet weak var vwPopupEnlargeContainer: UIView!
    @IBOutlet weak var imgEnlarged: UIImageView!
    @IBOutlet weak var lblEnlargedTitle: UILabel!
    @IBOutlet weak var vwEnlargedViewImgContainer: UIView!
    @IBOutlet weak var btnEnlargedSpeak: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnNextPane: UIButton!
    @IBOutlet weak var btnPrevPane: UIButton!
    @IBOutlet weak var vwFullScreen: UIView!
    @IBOutlet weak var vwCOllectionViewContainer: UIView!
    @IBOutlet weak var vwToMoveInFullScreen: UIView!
    @IBOutlet weak var CvFullscreen: UICollectionView!
    @IBOutlet weak var lblChildNm: UILabel!
    @IBOutlet weak var lblChildDob: UILabel!
    @IBOutlet weak var lblProjName: UILabel!
    @IBOutlet weak var btnEnlargedSpeakTwo: UIButton!
    @IBOutlet weak var vwSwitchToChildModeBtnContainer: UIView!
    @IBOutlet weak var btnPrevFullscreen: UIButton!
    @IBOutlet weak var btnNextFullScreen: UIButton!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var accessType: AccessType = .child
    var allProj: [ProjectsDB] = []  //get all projects from the previous page..
    var allProjDetails: [ProjectsDetailsDB] = [] //all projects details
    var currentProjID: UUID!  //current playing project id..
    var arrayOfArraysOfImgs: [[ArrayOfArrayProjModel]] = []
    var currentShowingIndex = 0  //to manage next and prev pane
    
    //speech --> variables
    private let synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()
    private var repeatCount = 1
    private var currentCount = 0
    private var message = ""
    private var languageCode = "en-US"
    var lastButtonClickTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvImagesCollection.delegate = self
        cvImagesCollection.dataSource = self
        CvFullscreen.delegate = self
        CvFullscreen.dataSource = self
        tblProjList.delegate = self
        tblProjList.dataSource = self
        
        cvImagesCollection.allowsMultipleSelection = false
        CvFullscreen.allowsMultipleSelection = false
        cvImagesCollection.allowsMultipleSelection = false
        
        //close enlarged tap gesture
        let closeEnlargedTap = UITapGestureRecognizer(target: self, action: #selector(closeEnlargedTapAction))
        closeEnlargedTap.cancelsTouchesInView = false
        closeEnlargedTap.delegate = self
        vwPopupEnlargeContainer.addGestureRecognizer(closeEnlargedTap)
        initialUiSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchProjects()
        
        lblChildNm.text = globalChildName ?? ""
        lblChildDob.text = "DOB: \(globalChildDob ?? "")"
    }
    

    @IBAction func profileBtnAction(_ sender: UIButton) {
        if accessType == .parent {
            if let profileVc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                self.navigationController?.pushViewController(profileVc, animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func homeBtnAction(_ sender: UIButton) {
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is ProjectsVC {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
    @IBAction func editBtnAction(_ sender: UIButton) {
        if let editVc = self.storyboard?.instantiateViewController(withIdentifier: "EditProjectVC") as? EditProjectVC {
            editVc.projHid = currentProjID
            self.navigationController?.pushViewController(editVc, animated: true)
        }
    }
    @IBAction func addBtnAction(_ sender: UIButton) {
        if let newProjVc = self.storyboard?.instantiateViewController(withIdentifier: "NewProjVC") as? NewProjVC {
            self.navigationController?.pushViewController(newProjVc, animated: true)
        }
    }
    @IBAction func fullScreenBtnAction(_ sender: UIButton) {
        CvFullscreen.reloadData()
        if !arrayOfArraysOfImgs.isEmpty {
            CvFullscreen.scrollToItem(at: IndexPath(item: (currentShowingIndex), section: 0), at: .centeredHorizontally, animated: false)
        }
        vwFullScreen.isHidden = false
    }
    @IBAction func enlargedSpeakBtnAction(_ sender: UIButton) {
        repeatTextToSpeach(with: message, languageCode: "en-US", repeatCount: 1)
    }
    @IBAction func nextPaneBtnAction(_ sender: UIButton) {
        if (arrayOfArraysOfImgs.count-1) > currentShowingIndex {
            cvImagesCollection.scrollToItem(at: IndexPath(item: (currentShowingIndex+1), section: 0), at: .centeredHorizontally, animated: true)
            if !vwFullScreen.isHidden {
                CvFullscreen.scrollToItem(at: IndexPath(item: (currentShowingIndex+1), section: 0), at: .centeredHorizontally, animated: true)
            }
            currentShowingIndex += 1
            checkNextPrevBtnActive()
        }
    }
    @IBAction func prevPaneBtnAction(_ sender: UIButton) {
        if 0 < currentShowingIndex {
            cvImagesCollection.scrollToItem(at: IndexPath(item: (currentShowingIndex-1), section: 0), at: .centeredHorizontally, animated: true)
            if !vwFullScreen.isHidden {
                CvFullscreen.scrollToItem(at: IndexPath(item: (currentShowingIndex-1), section: 0), at: .centeredHorizontally, animated: true)
            }
            currentShowingIndex -= 1
            checkNextPrevBtnActive()
        }
    }
    @IBAction func backFromFullScreen(_ sender: UIButton) {
        vwFullScreen.isHidden = true
    }
    @IBAction func switchToChildBtnAction(_ sender: UIButton) {
        if let projVc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectsVC") as? ProjectsVC {
            projVc.accessType = .child
            self.navigationController?.pushViewController(projVc, animated: true)
        }
    }
    
    func initialUiSetup() {
        lblProjName.text = ""
        vwPopupEnlargeContainer.isHidden = true
        vwFullScreen.isHidden = true
        if accessType == .parent {
            vwFullScreenContainer.isHidden = true
            vwControllContainer.isHidden = false
            vwSwitchToChildModeBtnContainer.isHidden = false
        } else {
            vwFullScreenContainer.isHidden = false
            vwControllContainer.isHidden = true
            vwSwitchToChildModeBtnContainer.isHidden = true
        }
    }
    
    @objc func closeEnlargedTapAction() {
        hideEnlargedImg()
    }
    
    //fetch the project and refresh the list
    func fetchProjects() {
        allProj = ProjectsDBHelper.instance.loadData(forUserId: globalLoggedInUserId)
        tblProjList.reloadData()
        self.lblProjName.text = allProj.first(where: {$0.id == currentProjID})?.name ?? ""
        allProjDetails = ProjectsDetailsDBHelper.instance.loadData()
        self.makeArrayOfArrayOfImages()
    }
    
    func makeArrayOfArrayOfImages() {
        if allProj.first(where: {$0.id == currentProjID})?.isEditable == true {
            btnAdd.isEnabled = true
            btnEdit.isEnabled = true
        } else {
            btnAdd.isEnabled = false
            btnEdit.isEnabled = false
        }
        arrayOfArraysOfImgs = [] //cleare before creating new
        let currentProjectDetails = allProjDetails.filter({$0.projid == currentProjID})
        
            var innerArray: [ArrayOfArrayProjModel] = []
            for (index, item) in currentProjectDetails.enumerated() {
                    innerArray.append(ArrayOfArrayProjModel(image: item.image, title: (item.title ?? "")))
                    // Check if the inner array has reached the desired size (4 items) or if it's the last item in the original array
                    if innerArray.count == 4 || index == (currentProjectDetails.count - 1) {
                        // Add the inner array to the arrayOfArrays
                        arrayOfArraysOfImgs.append(innerArray)
                        // Reset the inner array for the next iteration
                        innerArray = []
                    }
            }
        
        lblProjName.text = allProj.first(where: {$0.id == currentProjID})?.name ?? ""
        currentShowingIndex = 0
        checkNextPrevBtnActive()
        cvImagesCollection.reloadData()
        if !arrayOfArraysOfImgs.isEmpty {
            cvImagesCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        cvImagesCollection.reloadData()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == vwEnlargedViewImgContainer || touch.view == btnEnlargedSpeak || touch.view == btnEnlargedSpeakTwo {
            return false
        }
        return true
    }
}

//collection view delegate and datasource
extension PlayProjectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfArraysOfImgs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayProjCVC", for: indexPath) as? PlayProjCVC {
            
            cell.readBtnOne.paneIndex = indexPath.item
            cell.readBtnOne.quadrantIndex = 0
            
            
            print("readBtnOne::",cell.readBtnOne.quadrantIndex)
            
            cell.readBtnTwo.paneIndex = indexPath.item
            cell.readBtnTwo.quadrantIndex = 1
            
            cell.readBtnThree.paneIndex = indexPath.item
            cell.readBtnThree.quadrantIndex = 2
            
            cell.readBtnFour.paneIndex = indexPath.item
            cell.readBtnFour.quadrantIndex = 3
            
            //add actions to all quadrant
            cell.readBtnOne.addTarget(self, action: #selector(readBtnOneAction(_ :)), for: .allEvents)
            cell.readBtnTwo.addTarget(self, action: #selector(readBtnTwoAction(_ :)), for: .allEvents)
            cell.readBtnThree.addTarget(self, action: #selector(readBtnThreeAction(_ :)), for: .allEvents)
            cell.readBtnFour.addTarget(self, action: #selector(readBtnFourAction(_ :)), for: .allEvents)
            
            //cleare before declare
            cell.imgOne.image = nil
            cell.lblTitleOne.text = ""
            cell.readBtnOne.textToRead = ""
            cell.lblTitleOne.isHidden = true
            cell.imgTwo.image = nil
            cell.lblTitleTwo.text = ""
            cell.readBtnTwo.textToRead = ""
            cell.lblTitleTwo.isHidden = true
            cell.imgThree.image = nil
            cell.lblTitleThree.text = ""
            cell.readBtnThree.textToRead = ""
            cell.lblTitleThree.isHidden = true
            cell.imgFour.image = nil
            cell.lblTitleFour.text = ""
            cell.readBtnFour.textToRead = ""
            cell.lblTitleFour.isHidden = true
            
            print("arrayOfArraysOfImgs::",arrayOfArraysOfImgs.count)
            
            for (index, item) in arrayOfArraysOfImgs[indexPath.item].enumerated() {
                switch index {
                case 0:
                    // Convert Base64 string to Data
                    if let imageData = item.image {
                        // Convert Data to UIImage
                        if let image = UIImage(data: imageData) {
                            cell.imgOne.image = image
                            cell.readBtnOne.showImg = image
                            
                        }
                    }
                    cell.lblTitleOne.isHidden = false
                    cell.lblTitleOne.text = item.title
                    cell.readBtnOne.textToRead = item.title
                case 1:
                    // Convert Base64 string to Data
                    if let imageData = item.image {
                        // Convert Data to UIImage
                        if let image = UIImage(data: imageData) {
                            cell.imgTwo.image = image
                            cell.readBtnTwo.showImg = image
                        }
                    }
                    cell.lblTitleTwo.isHidden = false
                    cell.lblTitleTwo.text = item.title
                    cell.readBtnTwo.textToRead = item.title
                case 2:
                    // Convert Base64 string to Data
                    if let imageData = item.image {
                        // Convert Data to UIImage
                        if let image = UIImage(data: imageData) {
                            cell.imgThree.image = image
                            cell.readBtnThree.showImg = image
                        }
                    }
                    cell.lblTitleThree.isHidden = false
                    cell.lblTitleThree.text = item.title
                    cell.readBtnThree.textToRead = item.title
                case 3:
                    // Convert Base64 string to Data
                    if let imageData = item.image {
                        // Convert Data to UIImage
                        if let image = UIImage(data: imageData) {
                            cell.imgFour.image = image
                            cell.readBtnFour.showImg = image
                        }
                    }
                    cell.lblTitleFour.isHidden = false
                    cell.lblTitleFour.text = item.title
                    cell.readBtnFour.textToRead = item.title
                default:
                    print("check error at point 6.0")
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected image at --> ", indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvImagesCollection {
            return cvImagesCollection.bounds.size
        } else {
            return CvFullscreen.bounds.size
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //quadrant one clicked
    @objc func readBtnOneAction(_ sender: CustomBtnToPlayImage) {
        handleButtonClick(sender)
        
    }
    //quadrant two clicked
    @objc func readBtnTwoAction(_ sender: CustomBtnToPlayImage) {
        handleButtonClick(sender)
    }
    //quadrant three clicked
    @objc func readBtnThreeAction(_ sender: CustomBtnToPlayImage) {
        handleButtonClick(sender)
    }
    //quadrant four clicked
    @objc func readBtnFourAction(_ sender: CustomBtnToPlayImage) {
        handleButtonClick(sender)
    }
    
    
    
    func handleButtonClick(_ sender: CustomBtnToPlayImage) {
        // Debounce: check if last button click was too recent
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastButtonClickTime < 0.2 {
            return
        }
        lastButtonClickTime = currentTime
        
        // Proceed only if there's text to read
        if !sender.textToRead.isEmpty {
            imgEnlarged.image = sender.showImg
            lblEnlargedTitle.text = sender.textToRead
            showEnlargedImg()
            repeatTextToSpeach(with: sender.textToRead, languageCode: "en-US", repeatCount: 1)
        }
    }
    
    func showEnlargedImg() {
        UIView.animate(withDuration: 0.1) {
            self.vwPopupEnlargeContainer.alpha = 1.0
            self.vwPopupEnlargeContainer.isHidden = false
            self.cvImagesCollection.isUserInteractionEnabled = false // Disable interaction
        } completion: { _ in
            self.vwPopupEnlargeContainer.isHidden = false
            self.cvImagesCollection.isUserInteractionEnabled = true // Re-enable interaction after animation
        }
    }
    func hideEnlargedImg() {
        UIView.animate(withDuration: 0.1) {
            self.vwPopupEnlargeContainer.alpha = 0.0
        } completion: { _ in
            self.vwPopupEnlargeContainer.isHidden = true
        }
    }
    
    func checkNextPrevBtnActive() {
        if !arrayOfArraysOfImgs.isEmpty {
            btnNextPane.isHidden = !(currentShowingIndex < (arrayOfArraysOfImgs.count-1))
            btnPrevPane.isHidden = !(currentShowingIndex > 0)
            
            btnPrevFullscreen.isHidden = btnPrevPane.isHidden
            btnNextFullScreen.isHidden = btnNextPane.isHidden
        } else {
            print("point 8.3")
            //disable both
            btnNextPane.isHidden = true
            btnPrevPane.isHidden = true
            btnPrevFullscreen.isHidden = true
            btnNextFullScreen.isHidden = true
        }
    }
}

//MARK: - project list table view delegate and datasource
extension PlayProjectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProj.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProjListInPlayProjTVC", for: indexPath) as? ProjListInPlayProjTVC {
            cell.txtProjNm.text = allProj[indexPath.row].name ?? ""
            if let imgData = allProj[indexPath.row].thumbnail, let imgTh = UIImage(data: imgData) {
                cell.imgThumbnail.image = imgTh
            } else {
                cell.imgThumbnail.image = nil
            }
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentProjID = allProj[indexPath.row].id
        makeArrayOfArrayOfImages()
    }
}

// MARK: - Text to Speech
extension PlayProjectVC: AVSpeechSynthesizerDelegate {
    
    func repeatTextToSpeach(with message: String, languageCode: String, repeatCount: Int) {
        self.synthesizer.delegate = self
        self.message = message
        self.repeatCount = repeatCount
        self.languageCode = languageCode
        self.currentCount = 0
        
        // Stop any ongoing speech
        if self.synthesizer.isSpeaking {
            self.synthesizer.stopSpeaking(at: .immediate)
        } else {
            self.speak()
        }
    }
    
    func speak() {
        
        guard !synthesizer.isSpeaking else { return }
        
        let utterance = AVSpeechUtterance(string: message.lowercased())
        if #available(iOS 14.0, *) {
            utterance.prefersAssistiveTechnologySettings = true
        } else {
            // Fallback on earlier versions
            utterance.pitchMultiplier = 1.0 // or adjust based on your need
            utterance.rate = 0.5
        }
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.4
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        synthesizer.speak(utterance)
        
        currentCount += 1
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if currentCount < repeatCount {
            speak()
        }
    }
}

