//
//  HistoryViewController.swift
//  Blena
//
//  Created by Lê Vinh on 10/10/24.
//

import Foundation
import UIKit
import WebKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentControler: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashButton: UIButton!
    var noDataLabel: UILabel!
    
    var historyByDate: [String: [HistoryObject]] = [:]
    var dateSections: [String] = []
    
    @IBAction func removeHistory(_ sender: Any) {
        if(HistoryDataSource.shared.browserHistory.isEmpty){
            let alert = UIAlertController(title: "History Empty", message: "History is empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            let alertActionController = UIAlertController(title: "Clear History", message: "Are you sure you want to clear history?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                HistoryDataSource.shared.browserHistory = []
                self.historyByDate.removeAll()
                self.dateSections.removeAll()
                NSLog("\(HistoryDataSource.shared.saveHistory())")
                let webView = ((self.view.window?.rootViewController as! UINavigationController).topViewController as! ViewController).webView
                let url = URL(string: webView.url!.absoluteString)!
                self.tableView.reloadData()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertActionController.addAction(yesAction)
            alertActionController.addAction(noAction)
            present(alertActionController, animated: true, completion: nil)
            
        }
        
    }
    
    func loadReplace(url: URL, in webView: WKWebView) {
        let replaceScript = "location.replace('\(url.absoluteString)')"
        webView.evaluateJavaScript(replaceScript) { result, error in
            if let error = error {
                print("JavaScript Error: \(error.localizedDescription)")
            } else {
                print("URL replaced successfully")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        trashButton.setTitle("", for: UIControl.State.normal)

        // Register the default cell class with the identifier "HistoryTableViewCell"
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")

        // Assign the data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        // No Data Label for empty state
        noDataLabel = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tableView.bounds.size.width,
                height: tableView.bounds.size.height
            )
        )
        noDataLabel.text = "No Data Available"
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.font = UIFont.systemFont(ofSize: 20)
        noDataLabel.isHidden = true // Initially hidden unless there's no data

        tableView.backgroundView = noDataLabel
        tableView.isUserInteractionEnabled = true

        groupHistoryByDate()
        // Reload the table view when data changes
        tableView.reloadData()
    }
    
    // Helper function to group history objects by date (ignoring time)
        func groupHistoryByDate() {
            let historyObjects = HistoryDataSource.shared.browserHistory
            
            // Clear previous grouping
            historyByDate.removeAll()
            dateSections.removeAll()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            for historyObject in historyObjects {
                let formattedDate = dateFormatter.string(from: historyObject.dateSuft)
                
                // Group history objects by their date string
                if historyByDate[formattedDate] == nil {
                    historyByDate[formattedDate] = [historyObject]
                    dateSections.append(formattedDate)
                } else {
                    historyByDate[formattedDate]?.append(historyObject)
                }
            }
        }

    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if dateSections.count == 0 {
            noDataLabel.isHidden = false
            tableView.separatorStyle = .none
        } else {
            noDataLabel.isHidden = true
            tableView.separatorStyle = .singleLine
        }
        return dateSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateSections[section] // Display the date as section header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = dateSections[section]
        return historyByDate[dateKey]?.count ?? 0
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let count = HistoryDataSource.shared.browserHistory.count
//        if count == 0 {
//            noDataLabel.isHidden = false
//            tableView.separatorStyle = .none
//        } else {
//            noDataLabel.isHidden = true
//            tableView.separatorStyle = .singleLine
//        }
//        return count
//    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
                    
        // Get the history object for the current row
        let historyObject = HistoryDataSource.shared.browserHistory[indexPath.row]
                    
        // Configure the cell with the history object
        cell.configure(with: historyObject)
        cell.selectionStyle = .default
                    
        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedHistoryObject = HistoryDataSource.shared.browserHistory[indexPath.row]
        NSLog(
            "Selected: \(selectedHistoryObject.title) - \(selectedHistoryObject.url)"
        )
        
        // Optionally, deselect the row after selection
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.window?.rootViewController?.dismiss(animated: true)
        ((self.view.window?.rootViewController as! UINavigationController).topViewController as! ViewController).webView.load(URLRequest(url: URL(string: selectedHistoryObject.url)!))
    }
}


class HistoryTableViewCell: UITableViewCell {
    
    // UI elements to display the title and URL
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var imageLabel : UIImageView!
    
    // Activity indicator to show while image is loading
        private var activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            return indicator
        }()
        
        // Configure the cell with data from a HistoryObject
        func configure(with historyObject: HistoryObject) {
            titleLabel.text = historyObject.title
            urlLabel.text = historyObject.url
            
            // Add loading indicator to the image view
            addLoadingIndicator()
            
            // If there's an image URL, load the image from the network
            if !historyObject.image.isEmpty {
                if let imageURL = URL(string: historyObject.image) {
                    loadImage(from: imageURL)
                }
            } else {
                imageLabel.image = UIImage(named: "BLENA.png", in: Bundle.main, compatibleWith: self.traitCollection)
            }
        }
        
        private func loadImage(from url: URL) {
            // Start activity indicator before loading image
            activityIndicator.startAnimating()
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                // Ensure no error and we have valid data
                if let data = data, let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Update the image view and stop the loading indicator
                        self.imageLabel.image = downloadedImage
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        // Stop loading indicator and set a default image if the download failed
                        self.imageLabel.image = UIImage(systemName: "exclamationmark.triangle")
                        self.activityIndicator.stopAnimating()
                    }
                }
            }.resume()
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            self.imageLabel.layer.cornerRadius = 3
        }
        
        // Add loading indicator to image label
        private func addLoadingIndicator() {
            if activityIndicator.superview == nil {
                imageLabel.addSubview(activityIndicator)
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    activityIndicator.centerXAnchor.constraint(equalTo: imageLabel.centerXAnchor),
                    activityIndicator.centerYAnchor.constraint(equalTo: imageLabel.centerYAnchor)
                ])
            }
        }
        
}
