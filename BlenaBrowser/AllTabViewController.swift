//
//  AllTabViewController.swift
//  Blena
//
//  Created by Lê Vinh on 28/9/24.
//

import Foundation
import UIKit

class AllTabViewController: UIViewController {
    @IBOutlet var tabCollectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabManager = TabManager(userDefaults: UserDefaults.standard, key: "tab")
        NSLog("\(tabManager.tabItems)")
    }
}
