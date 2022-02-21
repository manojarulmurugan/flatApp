//
//  SuperAdminViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 21/01/22.
//

import UIKit
import Firebase
import CoreData
import FirebaseStorage

class SuperAdminViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var adminNameTextField: UITextField!
    @IBOutlet weak var designationTextField: UITextField!
    
    @IBOutlet weak var submitAdminButton: UIButton!
    
    
    let contxt = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var admins = [Admin]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitAdminButtonPressed(_ sender: UIButton) {
        
        let firebaseAuthNumber = String((Auth.auth().currentUser?.phoneNumber) ?? "0")
                db.collection(K.adminsFStore.collectionName).whereField(K.adminsFStore.phoneNoField, isEqualTo: firebaseAuthNumber)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error: getting documents: \(err)")
                        } else {
                            var flag = 0
                            //Save data in CoreData:
                            let newAdmin = Admin(context:self.contxt)
                            //var flatNumber = "Error FlatNo"
                            //var reportedName = "Error Name"
                            
                            for document in querySnapshot!.documents {
                                flag = 1
                                print("\(document.documentID) => \(document.data())")
                                print("SUCCESS: Phone Number found")
                            }
                            let phoneNumber = "+91"+(self.phoneNoTextField.text ?? "0")
                            newAdmin.name = self.adminNameTextField.text ?? "Error Name"
                            newAdmin.phoneNo = phoneNumber
                            newAdmin.designation = self.designationTextField.text ?? "Error Designation"
                            
                            self.admins.append(newAdmin)
                            self.saveAdmin()
                            
                            if(flag == 0) {
                                print("FATAL ERROR: User not found on Database")
                            }
                            
                            //Firestore:
                            self.db.collection(K.adminsFStore.collectionName).addDocument(data: [
                                K.adminsFStore.nameField : newAdmin.name!,
                                K.adminsFStore.phoneNoField : newAdmin.phoneNo!,
                                K.adminsFStore.designation : newAdmin.designation!,
                            ]){
                                err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    } else {
                                        print("Document saved successfully")
                                    }
                            }
                        }
                    }
    }
    
    
    //MARK:- CoreData: Data Manipulation Methods:
       func saveAdmin(){
            do{
                try contxt.save()
            } catch {
                print("Error saving category \(error)")
            }
            //tableView.reloadData()
        }
        func loadAdmins(with request: NSFetchRequest<Admin> = Admin.fetchRequest()){
            
            do{
                admins = try contxt.fetch(request)
            } catch {
                print("Error loading categories \(error)")
            }
            //tableView.reloadData()
        }
}
