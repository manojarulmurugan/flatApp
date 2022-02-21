//
//  constants.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 16/07/21.
//

import Foundation
struct K {
    static let appName = "🏠 FlatApp"
    static let verificationSegue = "phoneToVerification"
    static let loginSegue = "LoginToMain"
    static let complaintSegue = "MainToComplaint"
    static let adminSegue = "LoginToAdmin"
    static let superSegue = "LoginToSuper"
    static let registerSegue = "registerToLogin"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "ComplaintCell"
    var latestComplaint : String
    
    struct usersFStore {
        static let collectionName = "Users"
        static let contactNoField = "contactNo"
        static let flatNoField = "flatNo"
        static let nameField = "name"
        static let ownerTypeField = "ownershipType"
    }
    struct complaintsFStore {
        static let collectionName = "Complaints"
        static let complaintIDField = "complaintid"
        static let categoryField = "category"
        static let flatNoField = "flatNo"
        static let reportedByField = "reportedBy"
        static let reportedDateField = "reportedDate"
        static let shortDescField = "shortDesc"
        static let longDescField = "longDesc"
        static let statusField = "status"
        static let endCommentsField = "endComments"
        static let audioURLField = "audioUrl"
        static let photoURLField = "photoUrl"
    }
    struct adminsFStore {
        static let collectionName = "Admins"
        static let phoneNoField = "phoneNo"
        static let nameField = "name"
        static let designation = "designation"
    }
    struct identifiersFStore {
        static let collectionName = "Identifiers"
        static let documentID = "RxXkbvJzl6UDEBIPdKPW"
        static let latestComplaintField = "latestComplaintId"
        static let latestApartmentField = "latestApartmentId"
    }
}
