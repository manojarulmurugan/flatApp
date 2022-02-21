//
//  SignupViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 19/07/21.
//

import UIKit
import CoreData
import Firebase

class CellClass: UITableViewCell{
    
}

class SignupViewController: UITableViewController {
    
    @IBOutlet weak var flatNoTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ownerTypeButton: UIButton!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    let transparentView = UIView()
    let tableListView = UITableView()
    
    var selectedButton = UIButton()
    var dataSource = [String]()
    
    //Temp Textfield:
    @IBOutlet weak var deleteTextField: UITextField!
    
    //CoreData Variables:
    var users = [User]()
    let contxt = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Firebase:
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableListView.delegate = self
        tableListView.dataSource = self
        tableListView.register(CellClass.self, forCellReuseIdentifier: "Cell")
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
    
    @IBAction func ownerTypeButtonPressed(_ sender: UIButton) {
        dataSource = ["Owner", "Tenant"]
        selectedButton = ownerTypeButton
        addTransparentView(frames: ownerTypeButton.frame)
    }
    //MARK: - Add New User:
    
    func saveUser(){
        do{
            try contxt.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        //tableView.reloadData()
    }
    
    /* Text Field Checking:
    name1.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    name2.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    name3.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    name4.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)


    func textFieldDidChange(textField: UITextField) {
        if name1.text?.isEmpty || name2.text?.isEmpty || name3.text?.isEmpty || name4.text?.isEmpty {
            //Disable button
        } else {
            //Enable button
        }
    }*/
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        let newUser = User(context:self.contxt)
        
        //CoreData:
        let contactNumber = "+91"+(contactTextField.text!)
        newUser.contactNo = contactNumber
        newUser.flatNo = flatNoTextField.text!
        newUser.name = nameTextField.text!
        newUser.ownershipType = ownerTypeButton.currentTitle!
        
        //Firestore:
        db.collection(K.usersFStore.collectionName).addDocument(data: [
            K.usersFStore.contactNoField : newUser.contactNo!,
            K.usersFStore.flatNoField : newUser.flatNo!,
            K.usersFStore.nameField : newUser.name!,
            K.usersFStore.ownerTypeField : newUser.ownershipType!
        ]){
            err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document saved successfully")
                }
        }
        
        self.users.append(newUser)
        self.saveUser()
        
        self.performSegue(withIdentifier: K.registerSegue , sender: self)
    }
    
    //MARK: - Temp Deletion method:
    
    @IBAction func deletePressed(_ sender: UIButton) {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        let predicate = NSPredicate(format: "contactNo CONTAINS[cd] %@",deleteTextField.text!)
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contactNo", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
         do{
            users = try contxt.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        let size = users.count
        print(size)
            for i in users{
                print(i.contactNo ?? "Default")
                //print(users[i].contactNo )
                contxt.delete(i)
                //users.remove(at: index(ofAccessibilityElement: i))
            }
        saveUser()
    }
    
    
}
//MARK: - DropBox Extension
extension SignupViewController {//}: UITableViewDelegate, UITableViewDataSource {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableListView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
             removeTransparentView()
         }
}
