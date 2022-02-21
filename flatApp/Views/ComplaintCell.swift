//
//  ComplaintCell.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 17/07/21.
//

import UIKit

class ComplaintCell: UITableViewCell {

    @IBOutlet weak var shortDescLabel: UILabel!
    @IBOutlet weak var flatNoLabel: UILabel!
    @IBOutlet weak var reportedByLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var reportedDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowCellView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        cellView.layer.cornerRadius = 8
        cellView.layer.masksToBounds = true
        cellView.layer.borderWidth = 2.5
        //cellView.layer.borderColor = UIColor.black.cgColor

        shadowCellView.layer.masksToBounds = false
        shadowCellView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowCellView.layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 50.0)
        shadowCellView.layer.shadowOpacity = 0.23
        shadowCellView.layer.shadowRadius = 4
    }
}

