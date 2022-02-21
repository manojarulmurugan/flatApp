//
//  RegisterViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 14/07/21.
//

import UIKit
import Firebase
import CoreData

class RegisterViewController: UIViewController {
    @IBOutlet weak var flatTextField: UITextField!
    
    let contxt = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userArray = [User]()
    
    let db = Firestore.firestore()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //let dbRef = db.collection(K.FStore.collectionName)
    }
    
    //MARK:- Temp 'To admin' function:
    
    @IBAction func toAdminButtonPressed(_ sender: UIButton) {
        //performSegue(withIdentifier: K.adminSegue, sender: self)
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if var phoneNumber = flatTextField.text{
            phoneNumber = "+91" + phoneNumber
            
    //MARK: - CoreData Local Retrieval:
                /*let request: NSFetchRequest<User> = User.fetchRequest()
                let predicate = NSPredicate(format: "contactNo CONTAINS[cd] %@",phoneNumber)
                request.predicate = predicate
                do{
                   userArray = try contxt.fetch(request)
                }catch{
                   print("Error fetching data from context, \(error)")
                }
                if userArray.isEmpty {
                    print("ALERT: Phone Number not found")
                    //...ALERT code...
                } else{
                    print("SUCCESS: Phone Number found")
                    //...Firestore Authentication code...
                }*/
            
    //MARK: - Firestore Cloud Retrieval:
            db.collection(K.usersFStore.collectionName).whereField(K.usersFStore.contactNoField, isEqualTo: phoneNumber)
                .getDocuments() { (querySnapshot, err) in
                    //print(querySnapshot as Any)
                    if let err = err {
                        print("Error: getting documents: \(err)")
                    } else {
                        var flag = 0
                        for document in querySnapshot!.documents {
                            flag = 1
                            print("\(document.documentID) => \(document.data())")
                            
                            print("SUCCESS: Phone Number found")
                            func showMessagePrompt(_ message: String) {
                                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: false, completion: nil)
                              }
                            
                            /*Auth.auth().createUser(withEmail: flat, password: password) { authResult, error in
                                if let e = error {
                                    print(e)
                                } else {
                                    //Navigate to the MainViewController
                                    self.performSegue(withIdentifier: K.verificationSegue, sender: self)
                                }
                            }*/
                            PhoneAuthProvider.provider()
                              .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                                  if let error = error {
                                    showMessagePrompt(error.localizedDescription)
                                    print(error.localizedDescription)
                                    /*let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                    self.present(alert, animated: true, completion: nil)*/
                                    return
                                  } else{
                                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                                        //let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                                        self.performSegue(withIdentifier: K.verificationSegue, sender: self)
                                  }
                                  // Sign in using the verificationID and the code sent to the user
                                  // ...
                              }
                        }
                        if(flag == 0) {
                            print("ALERT: Phone number not found")
                            let alert = UIAlertController(title: "Error", message: "Phone Number Not Registered", preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "Ok", style: .default)
                            /*{  (action) in
                                //What will happen when the user clicks the Add Item button on our UIAlert:-
                            }*/
                            alert.addAction(action)
                            self.present(alert,animated: true,completion: nil)
                        }
                    }
            }
        }
    }
}
