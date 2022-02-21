//
//  NewComplaintViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 16/08/21.
//

import UIKit
import Firebase
import CoreData
import AVFoundation
import FirebaseStorage
import SDWebImage
/* Getting Image from a URL: imageView.sd_setImage(with: URL(string: "http://www.domain.com/path/to/image.jpg"), placeholderImage: UIImage(named: "placeholder.png")) */


class NewComplaintViewController: UIViewController, AVAudioPlayerDelegate , AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var longDescTextView: UITextView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var endCommentsTextField: UITextField!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var photoFlag : Int!
    var audioFlag : Int!
    
    //For CoreData:
    var soundURL: String!
    let contxt = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var complaints = [Complaint]()
    var audioURLs = [AudioURL]()
    var photoURLs = [PhotoURL]()
    
    //For Firebase Storage:
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    //Firebase:
    let db = Firestore.firestore()
    
    //For Recorder and Player:
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    var fileName: String = "audioTestFile.m4a"
    //var fileName: String = UUID().uuidString + ".m4a"
    
    //For DropBox:
    let transparentView = UIView()
    let tableListView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    
    var placeholder = "Long Description"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("COREDATA FILEPATH: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        
        photoFlag = 0
        audioFlag = 0
        
        //Userdefaults URL retreival:
        /*guard let tempPhotoUrl = UserDefaults.standard.url(forKey: "photoURL") else{
            return
        }*/
        
        //Doesn't work?
        navigationItem.hidesBackButton = true
        
        //For Image Uploading:
        previewImageView.contentMode = .scaleAspectFit
        
        //For LongDescription TextView's Placeholder:
        longDescTextView.delegate = self
        longDescTextView.text = placeholder
        if placeholder == "Long Description" {
            longDescTextView.textColor = .lightGray
        } else {
            longDescTextView.textColor = .black
        }
        
        //For Voice Recorder:
        setupRecorder()
        playButton.isEnabled = false
        
        //loadComplaints()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Category Dropdown:
        tableListView.delegate = self
        tableListView.dataSource = self
        tableListView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
    }
    
    
    //MARK:- TextView Delegates
        
    func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .lightGray {
                textView.text = nil
                textView.textColor = .black
            }
        }
    func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
                textView.text = "Long Description"
                textView.textColor = UIColor.lightGray
                placeholder = ""
            } else {
                placeholder = textView.text
            }
        }
    func textViewDidChange(_ textView: UITextView) {
            placeholder = textView.text
        }
    //MARK: - DropDown Box:
    
    func addTransparentView(frames: CGRect) {
             let window = UIApplication.shared.keyWindow
             transparentView.frame = window?.frame ?? self.view.frame
             self.view.addSubview(transparentView)
             
             tableListView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
             self.view.addSubview(tableListView)
             tableListView.layer.cornerRadius = 5
             
             transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
             tableListView.reloadData()
             let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
             transparentView.addGestureRecognizer(tapgesture)
             transparentView.alpha = 0
             UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                 self.transparentView.alpha = 0.5
                 self.tableListView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
             }, completion: nil)
         }
    
    @objc func removeTransparentView() {
             let frames = selectedButton.frame
             UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                 self.transparentView.alpha = 0
                 self.tableListView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
             }, completion: nil)
         }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        print("Yo")
        dataSource = ["Plumbing", "Electricity","Carpentering","Other"]
        selectedButton = categoryButton
        addTransparentView(frames: categoryButton.frame)
    }
    
    
    
//MARK: - Audio Input Module:
    
    func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            print("PATHS: ")
            print(paths)
            return paths[0]
        }
    /*func getCacheDirectory() -> String {

        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)

        return paths[0]

    }
    func getFileURL() -> NSURL{

        let path  = getCacheDirectory().stringByAppendingPathComponent(fileName)

        let filePath = NSURL(fileURLWithPath: path)

        return filePath
    }*/
    
    func setupRecorder() {
        
        //checkMicrophoneAccess() - Might be needed when implemented in device (https://medium.com/swift2go/swift-audio-record-store-and-play-af965bf92b26)
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: .default)
        } catch _ {
        }
        
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                                AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                AVEncoderBitRateKey : 320000,
                                AVNumberOfChannelsKey : 2,
                                AVSampleRateKey : 44100.2] as [String : Any]
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting )
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func recordPressed(_ sender: UIButton) {
        
        audioFlag = 1
        
        if recordButton.titleLabel?.text == "Record" {
            
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(true)
                } catch _ {
                }
                soundRecorder.record()
                recordButton.setTitle("Stop", for: .normal)
                playButton.isEnabled = false
            } else {
                
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(false)
                } catch _ {
                }
                soundRecorder.stop()
                recordButton.setTitle("Record", for: .normal)
                playButton.isEnabled = false
            }
    }
    @IBAction func playPressed(_ sender: UIButton) {
        if playButton.titleLabel?.text == "Play" {
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            setupPlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            playButton.setTitle("Play", for: .normal)
            recordButton.isEnabled = false
        }
    }
//MARK:- CoreData: Data Manipulation Methods:
    
   func saveComplaint(){
        do{
            try contxt.save()
        } catch {
            print("Error saving category \(error)")
        }
        //tableView.reloadData()
    }
    func loadComplaints(with request: NSFetchRequest<Complaint> = Complaint.fetchRequest()){
        
        do{
            complaints = try contxt.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        //tableView.reloadData()
    }
//MARK:- CoreData: Temp Deletion:
    
   /* @IBAction func deletePressed(_ sender: UIButton) {
        let request: NSFetchRequest<Complaint> = Complaint.fetchRequest()
        
        let predicate = NSPredicate(format: "flatNo CONTAINS[cd] %@",deleteField.text!)
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "flatNo", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
         do{
            complaints = try contxt.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        let size = complaints.count
        print(size)
            for i in complaints{
                print(i.flatNo ?? "Default")
                //print(users[i].contactNo )
                contxt.delete(i)
                //users.remove(at: index(ofAccessibilityElement: i))
            }
        saveComplaint()
    }
    */
//MARK: - Submit Complaint
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        
        //MARK: - Complaint Form:
        let firebaseAuthNumber = String((Auth.auth().currentUser?.phoneNumber) ?? "0")
        
        db.collection(K.usersFStore.collectionName).whereField(K.usersFStore.contactNoField, isEqualTo: firebaseAuthNumber)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error: getting documents: \(err)")
                } else {
                    //Fetching the latest complaint ID:
                    self.db.collection(K.identifiersFStore.collectionName).document(K.identifiersFStore.documentID).getDocument { (document, error) in
                        if let document = document, document.exists {
                            if let latComplaint = document.data()![K.identifiersFStore.latestComplaintField] as? String{
                                
                                var flag = 0
                                
                                //Assigning and updating the latest complaint ID:
                                print("LAT COMPLAINT inside:\(latComplaint)")
                                let numberStr : String = String((latComplaint.suffix(7)))
                                var number = Int(numberStr)
                                number = number! + 1
                                
                                let tempStr = String(number!)
                                var tempCount = tempStr.count
                                tempCount = 7 - tempCount
                                var newComplId : String = "C"
                                for _ in 0..<tempCount{
                                    newComplId = newComplId + "0"
                                }
                                newComplId = newComplId + String(number!)
                                print("NEW_COMPL_ID: \(newComplId)")
                                
                                self.db.collection(K.identifiersFStore.collectionName).document(K.identifiersFStore.documentID).setData([
                                    K.identifiersFStore.latestComplaintField : newComplId
                                ], merge: true) { err in
                                    if let err = err {
                                        print("Error updating latest complaint ID document: \(err)")
                                    } else {
                                        print("Latest complaint ID document updated successfully")
                                    }
                                }
                                
                                //MARK: - Uploading Audio:
                                
                                let audioName = newComplId + ".m4a"
                                
                                //Sample audio download URL
                                var audioURL : URL = URL(string: "https://www.learningcontainer.com/download/sample-mp3-file/?wpdmdl=1676&refresh=61ad997f9a8c01638766975")!
                                    // Data in memory
                                let audioFilename = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
                                    
                                    // audioFilePath is the path of audio either from document
                                    // directory or any other location.
                                    do {
                                        let data = try Data(contentsOf:audioFilename as URL)
                                          
                                        // Create a reference to the file you want to upload
                                        let audioRefName = "audios/" + audioName
                                        print("AUDIO REFERENCE:\(audioRefName)")
                                        let audioRef = self.storageRef.child(audioRefName)

                                        // Upload the file to the path "images/rivers.jpg"
                                        let uploadTask = audioRef.putData(data, metadata: nil) { (metadata, error) in
                                          guard let metadata = metadata else {
                                            // Uh-oh, an error occurred!
                                            return
                                          }
                                          // Metadata contains file metadata such as size, content-type.
                                          let size = metadata.size
                                          // You can also access to download URL after upload.
                                            audioRef.downloadURL { [self] (url, error) in
                                            guard let downloadURL = url else {
                                              // Uh-oh, an error occurred!
                                              print("Error getting downloadURL")
                                              return
                                            }
                                                
                                            //Saving Audio URL to CoreData
                                            audioURL = downloadURL
                                            //UserDefaults.standard.set(audioURL, forKey: "audioURL")
                                          }
                                        }
                                    }
                                    catch{print("Error: fetching data from URL")}
                                //let tempAudioUrl = UserDefaults.standard.url(forKey: "audioURL")
                                //print("Audio Download URL: \(tempAudioUrl)")
                                
                                //MARK: - Uploading selected image to firebase storage:
                                
                                let imgData : Data = UserDefaults.standard.data(forKey: "photodata")!
                                
                                let photoFileName = newComplId + ".png"
                                
                                //typealias UploadPictureCompletion = (Result<String, Error>) -> Void
                                
                                let photoRefName = "images/" + photoFileName
                                print("PHOTO REFERENCE:\(photoRefName)")
                                let imageRef = self.storageRef.child(photoRefName)
                                imageRef.putData(imgData, metadata: nil, completion: { _, error in
                                    guard error == nil else{
                                        print("Failed to upload photo")
                                        //completion(.failure(ImageStorageErrors.failedToUpload))
                                        return
                                    }
                                    imageRef.downloadURL(completion: {url,error in
                                        guard let downloadUrl = url, error == nil else{
                                            print("Failed to get download URL")
                                            //completion(.failure(ImageStorageErrors.failedToGetDownloadURL))
                                            return
                                        }
                                        
                                        let task = URLSession.shared.dataTask(with: downloadUrl, completionHandler: {data, _, error in
                                            guard let data = data, error == nil else{
                                                return
                                            }
                                           DispatchQueue.main.async {
                                                let img = UIImage(data: data)
                                                self.previewImageView.image = img
                                                self.photoFlag = 1
                                            }
                                        })
                                        task.resume()
                                        //UserDefaults.standard.set(photoURL, forKey: "photoURL")
                                    })
                                })
                                
                                //MARK: - Save complaint data in CoreData:
                                let newComplaint = Complaint(context:self.contxt)
                                var flatNumber = "Error FlatNo"
                                var reportedName = "Error Name"
                                
                                for document in querySnapshot!.documents {
                                    flag = 1
                                    print("\(document.documentID) => \(document.data())")
                                    flatNumber = document.data()[K.usersFStore.flatNoField] as! String
                                    reportedName = document.data()[K.usersFStore.nameField] as! String
                                    print("SUCCESS: Phone Number found")
                                }
                                newComplaint.category = self.categoryButton.currentTitle!
                                //newComplaint.complaintid = UUID().uuidString
                                newComplaint.complaintid = newComplId
                                newComplaint.endComments = self.endCommentsTextField.text ?? "Nothing"
                                newComplaint.flatNo = flatNumber
                                newComplaint.longDesc = self.longDescTextView.text ?? "Nil"
                                newComplaint.reportedBy = reportedName
                                newComplaint.reportedDate = Date()
                                newComplaint.shortDesc = self.titleTextField.text ?? "Not Specified"
                                newComplaint.status = "Pending"
                                if self.audioFlag == 1 {newComplaint.audioFlag = true}
                                    else{newComplaint.audioFlag = false}
                                if self.photoFlag == 1 {newComplaint.photoFlag = true}
                                    else{newComplaint.photoFlag = false}
                                
                                self.complaints.append(newComplaint)
                                self.saveComplaint()
                                
                                if(flag == 0) {
                                    print("FATAL ERROR: User not found on Database")
                                }
                                
                                //Firestore:
                                self.db.collection(K.complaintsFStore.collectionName).addDocument(data: [
                                    K.complaintsFStore.categoryField : newComplaint.category!,
                                    K.complaintsFStore.complaintIDField : newComplaint.complaintid!,
                                    K.complaintsFStore.endCommentsField : newComplaint.endComments!,
                                    K.complaintsFStore.flatNoField : newComplaint.flatNo!,
                                    K.complaintsFStore.longDescField : newComplaint.longDesc!,
                                    K.complaintsFStore.reportedByField : newComplaint.reportedBy!,
                                    K.complaintsFStore.reportedDateField : newComplaint.reportedDate!,
                                    K.complaintsFStore.shortDescField : newComplaint.shortDesc!,
                                    K.complaintsFStore.statusField : newComplaint.status!,
                                ]){
                                    err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        } else {
                                            print("Document saved successfully")
                                        }
                                }
                                
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
    }

//MARK: - Photo Input/Upload Module:
    
    @IBAction func uploadPhotoButtonPressed(_ sender: UIButton) { 
        presentPhotoActionSheet()
    }
    
    //MARK: - For taking photo directly from camera:
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title:"Photo",
                                            message:"How would you like to select a picture", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Upload from gallery", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet,animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
//MARK: - For Choosing photo from Gallery:
    
    func presentPhotoPicker() {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
        /*guard let urlString = UserDefaults.standard.value(forKey:"url") as? String,
        let url = URL(string: urlString) else {
             return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else{
                return
            }
           DispatchQueue.main.async {
                let img = UIImage(data: data)
                self.previewImageView.image = img
                self.photoFlag = 1
            }
        })
        task.resume()*/
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    //var imagedata : String = "Error"
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage/*'.originalImage' if u don't want square cropped image*/] as? UIImage else{
            return
        }
        
        //Uploading to Firebase part:
        guard let imageData = selectedImage.pngData() else{ //Might wanna change it to '.jpeg' format later, if needed
            return
        }
        
        print("DATA-TYPE:\(type(of: imageData))")
        
        UserDefaults.standard.set(imageData, forKey: "photodata")
        
    }
    /* For Error Handling:
     public enum ImageStorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }*/
}

//MARK: - Extensions:

// Helper function inserted by Swift migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

// Helper function inserted by Swift migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

//MARK: - DropBox Extension
extension NewComplaintViewController {//}: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableListView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
         }
}

//MARK: - Taking a photo Extension:

extension NewComplaintViewController {
}
