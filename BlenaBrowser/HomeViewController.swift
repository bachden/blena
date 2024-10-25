//
//  HomeViewController.swift
//  Blena
//
//  Created by Lê Vinh on 26/9/24.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet var imageViewGoogle: UIStackView!
    @IBOutlet var imageViewYoutube: UIStackView!
    @IBOutlet var imageViewWikipedia: UIStackView!
    @IBOutlet var imageViewApple: UIStackView!
    @IBOutlet var textFieldSearch: UITextField!
    @IBOutlet weak var StackViewCenterYConstant: NSLayoutConstraint!

    // Function to dismiss the keyboard
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

    override func viewDidLoad() {
        super.viewDidLoad()


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)


        imageViewApple.layer.cornerRadius = 16
        imageViewGoogle.layer.cornerRadius = 16
        imageViewYoutube.layer.cornerRadius = 16
        imageViewWikipedia.layer.cornerRadius = 16

        let googleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(googleTapGestureRecognizerAction))
        imageViewGoogle.addGestureRecognizer(googleTapGestureRecognizer)
        let youtubeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(youtubeTapGestureRecognizerAction))
        imageViewYoutube.addGestureRecognizer(youtubeTapGestureRecognizer)
        let wikipediaTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wikipediaTapGestureRecognizerAction))
        imageViewWikipedia.addGestureRecognizer(wikipediaTapGestureRecognizer)
        let appleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appleTapGestureRecognizerAction))
        imageViewApple.addGestureRecognizer(appleTapGestureRecognizer)

    }

    @objc func googleTapGestureRecognizerAction() {
        let googleURL = URL(string: "https://google.com")!
        passURLandNavigate(url: googleURL)

    }

    @objc func youtubeTapGestureRecognizerAction() {
        let youtubeURL = URL(string: "https://youtube.com")!
        passURLandNavigate(url: youtubeURL)
    }

    @objc func wikipediaTapGestureRecognizerAction() {
        let wikipediaURL = URL(string: "https://wikipedia.org")!
        passURLandNavigate(url: wikipediaURL)
    }

    @objc func appleTapGestureRecognizerAction() {
        let appleURL = URL(string: "https://apple.com")!
        passURLandNavigate(url: appleURL)
    }

    func passURLandNavigate(url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "URLViewController") as? ViewController {

            // Set the presentation style if needed
            homeVC.modalPresentationStyle = .fullScreen

            var location = url.absoluteString
            if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
                if(location.contains(".")){
                    location = "https://\(location)"
                } else {
                    location = "https://www.google.com/search?q=\(location)"
                }
            }

            NSLog(location)


            let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
            ud.set(location, forKey: "LastDirectLocation")
            // Create a transition animation
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .moveIn // Use desired type like `.fade`, `.moveIn`, `.reveal`, etc.
            transition.subtype = .fromRight // Direction of the transition, e.g., `.fromRight`
            homeVC.navigationController?.setNavigationBarHidden(true, animated: false)
            homeVC.loadURL(URL(string: location)!)

            // Add the transition to the window's layer
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }



}
