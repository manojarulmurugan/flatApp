//
//  MainTableViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 17/07/21.
//

import UIKit
import Firebase
import CoreData

class MainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var complaintTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
    
    var complaints = [Complaint]()
    var filteredComplaints = [Complaint]()
   
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        complaintTableView.dataSource = self
        complaintTableView.delegate = self
        searchBar.delegate = self
        
        navigationItem.hidesBackButton = true
        self.complaintTableView.backgroundColor = UIColor.darkGray
        
        loadComplaints()
        
        print(complaints.count)
        
        let firebaseAuth = Auth.auth().currentUser?.phoneNumber

        // Uncomment the following line to preserve selection between presentations
            //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        complaintTableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
    }

    // MARK: - Table view data source

  /*  override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    } */
    
    func loadComplaints(){
        
        db.collection("Complaints").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                   /* if let shortdesc = data["shortDesc"] as? String, let flatno = data["flatNo"] as? String,
                       let statuss = data["status"] as? String, let reportedby = data["reportedBy"] as? String,
                       let reporteddate = data["reportedBy"] as? Date {*/
                    
                    let complId = data["complaintid"] as? String
                    let shortdesc = data["shortDesc"] as? String
                    let longdesc = data["longDesc"] as? String
                    let flatno = data["flatNo"] as? String
                    let statuss = data["status"] as? String
                    let reportedby = data["reportedBy"] as? String
                    let timestamp: Timestamp = data["reportedDate"] as! Timestamp
                    let reporteddate: Date = timestamp.dateValue()
                    let audioflag = data["audioFlag"] as? Bool
                    let photoflag = data["photoFlag"] as? Bool
                    let categoryy = data["category"] as? String
                        
                    let newComplaint = Complaint(context:self.context)
                    
                    print("yolololo:")
                    print(reporteddate)
                        
                    newComplaint.shortDesc = shortdesc
                    newComplaint.flatNo = flatno
                    newComplaint.status = statuss
                    newComplaint.reportedBy = reportedby
                    newComplaint.reportedDate = reporteddate //as! String
                    newComplaint.audioFlag = audioflag ?? false
                    newComplaint.photoFlag = photoflag ?? false
                    newComplaint.category = categoryy
                    newComplaint.complaintid = complId
                    newComplaint.endComments = ""
                    newComplaint.longDesc = longdesc
                    newComplaint.documentid = document.documentID
                
                    self.complaints.append(newComplaint)
                    self.filteredComplaints.append(newComplaint)
                        
                    DispatchQueue.main.async {
                        self.complaintTableView.reloadData()
                        let indexPath = IndexPath(row: self.complaints.count-1, section: 0)
                        self.complaintTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    //}
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredComplaints.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let complaint = filteredComplaints[indexPath.row]
        
        let cell = complaintTableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! ComplaintCell
        
        cell.shortDescLabel.text = complaint.shortDesc
        cell.flatNoLabel.text = complaint.flatNo
        cell.reportedByLabel.text = complaint.reportedBy
        
        //Complaint status:
        let statusVal = complaint.status
        cell.statusLabel.text = statusVal
        if statusVal == "Pending" {
            cell.cellView.layer.borderColor = CGColor(red: 255, green: 238, blue: 0, alpha: 1)
        } else if statusVal == "Seen" {
            cell.cellView.layer.borderColor = UIColor.blue.cgColor
        } else if statusVal == "Completed" {
            cell.cellView.layer.borderColor = UIColor.green.cgColor
        }
        
        //Date Formatting:
        let date = complaint.reportedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let myString = dateFormatter.string(from: date ?? Date())
        let yourDate = dateFormatter.date(from: myString)
        let myStringafd = dateFormatter.string(from: yourDate!)
        cell.reportedDateLabel.text = myStringafd
        
        //Category Symbols:
        let catg = complaint.category
        cell.categoryLabel.text = catg
        if catg == "Electricity" {
            cell.categoryImage.image = UIImage(systemName: "lightbulb.fill")
        } else if catg == "Plumbing" {
            cell.categoryImage.image = UIImage(systemName: "wrench.and.screwdriver.fill")
        } else if catg == "Carpentering" {
            cell.categoryImage.image = UIImage(systemName: "hammer.fill")
        } else if catg == "Other" {
            cell.categoryImage.image = UIImage(systemName: "questionmark.circle.fill")
        }

        // Configure the cell...

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }

    //MARK: - TableView Delegate Methods for segue:
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.complaintSegue, sender: self)
    }
    
    /* ############## IMPORTANT - FOR IDENTIFYING WHICH COMPLAINT WAS SELECTED: #####################*/
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ComplaintViewController
        
        if let Index = complaintTableView.indexPathForSelectedRow {
            destinationVC.selectedComplaint = filteredComplaints[Index.row]
        }
    
    }
}
    //MARK:- SearchBar Extention:

extension MainTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty == false{
            filteredComplaints = complaints.filter({(compl) -> Bool in return compl.shortDesc!.contains(searchText) })
        } else{
            filteredComplaints = complaints
        }
        complaintTableView.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
    
    
    //MARK: - Commented out Useful Code:
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
