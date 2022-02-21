//
//  ComplaintViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 15/01/22.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

class ComplaintViewController: UIViewController {
    
    //let marginWidth = 8
    let buttonSize = 60
    
    @IBOutlet weak var complaintIdTitleLabel: UILabel!
    @IBOutlet weak var complaintIdLabel: UILabel!
    @IBOutlet weak var shortDescTitleLabel: UILabel!
    @IBOutlet weak var shortDescTextField: UITextField!
    @IBOutlet weak var longDescTitleLabel: UILabel!
    @IBOutlet weak var longDescTextField: UITextView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    
    var selectedComplaint : Complaint? {
        didSet{
        }
    }

    let db = Firestore.firestore()
    
    //For category dropdown-box
    let transparentView = UIView()
    let tableListView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //For floating Button:
        view.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        
        //Category Dropdown:
        tableListView.delegate = self
        tableListView.dataSource = self
        tableListView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        //Making fields non-editable
        shortDescTextField.isUserInteractionEnabled = false
        longDescTextField.isUserInteractionEnabled = false
        categoryButton.isEnabled = false
        
        //Displaying Complaint details:
        complaintIdLabel.text = selectedComplaint?.complaintid
        shortDescTextField.text = selectedComplaint?.shortDesc
        longDescTextField.text = selectedComplaint?.longDesc
        categoryButton.setTitle(selectedComplaint?.category, for: .normal)
        
    }
    
//MARK: - Floating edit button:
    
    private let floatingButton: UIButton = {
        
        let buttonSize = 60
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = CGFloat(buttonSize/2)
        button.backgroundColor = .systemBlue
        
        let image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        floatingButton.frame = CGRect(x: Int(view.frame.size.width) - 70,
                                      y: Int(view.frame.size.height) - 100,
                                      width: buttonSize, height: buttonSize)
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
        dataSource = ["Plumbing", "Electricity","Carpentering","Other"]
        selectedButton = categoryButton
        addTransparentView(frames: categoryButton.frame)
    }
    
//MARK: - Edit Button Pressed:
    let editImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
    @objc private func editButtonPressed() {
        if floatingButton.currentImage == editImage{
            print("Edit Button Pressed")
            //Making fields non-editable
            shortDescTextField.isUserInteractionEnabled = true
            longDescTextField.isUserInteractionEnabled = true
            categoryButton.isEnabled = true
            floatingButton.setImage(nil, for: .normal)
            floatingButton.setTitle("Done", for: .normal)
        }else{
            print("Done Button Pressed")
            shortDescTextField.isUserInteractionEnabled = false
            longDescTextField.isUserInteractionEnabled = false
            categoryButton.isEnabled = false
            floatingButton.setImage(editImage, for: .normal)
            floatingButton.setTitle("", for: .normal)
            
            //Updation in Firestore:
            let complId = (selectedComplaint?.documentid)!
            self.db.collection(K.complaintsFStore.collectionName).document(complId).setData([
                K.complaintsFStore.categoryField : categoryButton.currentTitle!,
                K.complaintsFStore.longDescField : longDescTextField.text!,
                K.complaintsFStore.shortDescField : shortDescTextField.text!
            ], merge: true) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document updated successfully")
                }
            }
        }
    }
}

//MARK: - DropBox Extension
extension ComplaintViewController : UITableViewDelegate, UITableViewDataSource {
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
