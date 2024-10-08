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
    
    override func viewDidLoad() {
            super.viewDidLoad()
            // Register the default cell class with the identifier "cell"
              tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")


            // Assign the data source
            tableView.dataSource = self

            // Reload the table view when data changes
            tableView.reloadData()
        }

        // MARK: - UITableViewDataSource Methods

        // Return the number of rows for the table view (in this case, the number of log data entries)
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return GlobalDataSource.shared.data.count
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

