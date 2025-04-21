//
//  AboutBlenaController.swift
//  Blena
//
//  Created by Lê Vinh on 10/17/24.
//

import Foundation
import UIKit

class AboutBlenaController: UIViewController {
    @IBOutlet weak var contactMeButton: UIButton!
    @IBOutlet weak var SupportBlenaButton: UIButton!
    
    
    override func viewDidLoad() {
        SupportBlenaButton.isHidden = true
    }



    @IBAction func donate() {
        let url = URL(string: "https://buymeacoffee.com/bachhoangnguyen")!
        guard UIApplication.shared.canOpenURL(url) else {
            let alert = UIAlertController(title: "Can't open URL",message: "Can't navigate to this URL.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func contact(){

        let email = "hoangbach.bk@gmail.com"
        let subject = "[BLENA] I want to contact with you"

        if let emailUrl = URL(string: "mailto:\(email)?subject=\(subject)") {
            if UIApplication.shared.canOpenURL(emailUrl) {
                UIApplication.shared.open(emailUrl)
            }
        }
    }
}

