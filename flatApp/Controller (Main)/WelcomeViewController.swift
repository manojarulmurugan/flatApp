//
//  ViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 07/05/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var registerNavPressed: UIButton!
    @IBOutlet weak var loginPressed: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = K.appName
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }


}

