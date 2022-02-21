//
//  DeleteViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 21/01/22.
//

import UIKit
import Firebase
import CoreData
import FirebaseStorage

class DeleteViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    let db = Firestore.firestore()
    var docId = "ErrorDocID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        var phoneNumber = phoneNumberTextField.text ?? "0"
        phoneNumber = "+91" + phoneNumber
        
        //Retrieving Document(Admin) ID:
        db.collection("Admins").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var flag = 0
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    if data["phoneNo"] as! String == phoneNumber{
                        flag = 1
                        self.docId = document.documentID
                        break
                    }
                }
                if flag==0{
                    print("ALERT: Phone number not found")
                    let alert = UIAlertController(title: "Error", message: "Phone Number Not found", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default)
                    /*{  (action) in
                        //What will happen when the user clicks the Add Item button on our UIAlert:-
                    }*/
                    alert.addAction(action)
                    self.present(alert,animated: true,completion: nil)
                }
            }
        }
        
        //Delecting the Document(Admin):
        db.collection("Admins").document(docId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                let alert2 = UIAlertController(title: "Success!", message: "Document removed", preferredStyle: .alert)
                
                let action2 = UIAlertAction(title: "Ok", style: .default)
                /*{  (action) in
                    //What will happen when the user clicks the Add Item button on our UIAlert:-
                }*/
                alert2.addAction(action2)
                self.present(alert2,animated: true,completion: nil)
            }
        }
    }
    
}
