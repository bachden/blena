//
//  ScriptLogViewer.swift
//  Blena
//
//  Created by Lê Vinh on 10/8/24.
//

import Foundation
import UIKit

class ScriptLogViewer: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentControler: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeIcon: UIButton!
    var noDataLabel: UILabel!
    
    @IBAction func removeConsole(_ sender: Any) {
        if(GlobalDataSource.shared.data.isEmpty){
            let alert = UIAlertController(title: "Console Empty", message: "Console is empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            let alertActionController = UIAlertController(title: "Clear console log", message: "Are you sure you want to clear console log?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                HistoryDataSource.shared.browserHistory = []
                GlobalDataSource.shared.data = []
                self.tableView.reloadData()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertActionController.addAction(yesAction)
            alertActionController.addAction(noAction)
            present(alertActionController, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            // Register the default cell class with the identifier "cell"
        removeIcon.setTitle("", for: .normal)
              tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")


            // Assign the data source
            tableView.dataSource = self
        
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            noDataLabel.isHidden = false // Hide initially
        
            tableView.backgroundView = noDataLabel

            // Reload the table view when data changes
            tableView.reloadData()
        }

        // MARK: - UITableViewDataSource Methods

        // Return the number of rows for the table view (in this case, the number of log data entries)
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let count = GlobalDataSource.shared.data.count
            if count == 0 {
                       noDataLabel.isHidden = false
                       tableView.separatorStyle = .none
                   } else {
                       noDataLabel.isHidden = true
                       tableView.separatorStyle = .singleLine
                   }
            return count
        }

        // Provide a cell object for each row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Use the table view's default cell or a custom cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            // Get the data for the current row
            let logMessage = GlobalDataSource.shared.data[indexPath.row]

            // Set the text of the cell
            cell.textLabel?.text = logMessage

            return cell
        }
    }

