//
//  AppDelegate.swift
//  BlenaBrowser
//
//  Created by David Park on 13/01/2017.
//  Copyright © 2017 David Park. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Intents
import WidgetKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var viewController: ViewController? {
        get {
            guard let nc = self.window?.rootViewController as? UINavigationController,
                let vc = nc.topViewController as? ViewController else {
                    return nil
            }
            return vc
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            } else if granted {
                print("Notification authorization granted.")
            }
        }
        
        // Set the delegate here
        UNUserNotificationCenter.current().delegate = self

        // Override point for customization after application launch.
        // Create a new window for the window property
        window = UIWindow(frame: UIScreen.main.bounds)
        // Load the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        NSLog("go main")

        let ud = UserDefaults(suiteName: "group.com.nhb.blena")!
        if(ud.value(forKey: "HomePageLocation") != nil){
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "URLViewController") as? ViewController {
                // Wrap the HomeViewController in a UINavigationController
                let navigationController = UINavigationController(rootViewController: homeVC)

                // Set the rootViewController of the window to the UINavigationController
                window?.rootViewController = navigationController
            } else {
                // Handle the error gracefully if the view controller could not be instantiated
                print("Error: URLViewController could not be instantiated from storyboard")
            }
        } else {
            if ud.value(forKey: WBWebViewContainerController.prefKeys.lastLocation.rawValue) is String {
                // Instantiate the view controller with the correct identifier
                if let homeVC = storyboard.instantiateViewController(withIdentifier: "URLViewController") as? ViewController {
                    // Wrap the HomeViewController in a UINavigationController
                    let navigationController = UINavigationController(rootViewController: homeVC)

                    // Set the rootViewController of the window to the UINavigationController
                    window?.rootViewController = navigationController
                } else {
                    // Handle the error gracefully if the view controller could not be instantiated
                    print("Error: URLViewController could not be instantiated from storyboard")
                }
            } else {
                // Instantiate the view controller with the correct identifier
                if let homeVC = storyboard.instantiateViewController(withIdentifier: "URLViewController") as? ViewController {
                    // Wrap the HomeViewController in a UINavigationController
                    let navigationController = UINavigationController(rootViewController: homeVC)

                    // Set the rootViewController of the window to the UINavigationController
                    window?.rootViewController = navigationController
                } else {
                    // Handle the error gracefully if the view controller could not be instantiated
                    print("Error: URLViewController could not be instantiated from storyboard")
                }
            }
        }

        print(DebuggerStatusStream().isDebuggerAttachedToProcess().jsonify())


        // Make the window visible
        window?.makeKeyAndVisible()

        return true
    }



    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("resign")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("background")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("foreground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("active")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NSLog("terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {


        // Called from external link with scheme webble
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            NSLog("System not able to open url \(url) (may be able to try again)")
            return false
        }

        guard let param = urlComponents.queryItems!.first(where: { $0.name == "url" })?.value else {
            return false
        }
        NSLog(param)

        guard let vc = viewController else {
            NSLog("Error opening URL \(url): viewController not instantiated")
            return false
        }
        vc.loadLocation(param)
        return true
    }

    func application(_ application: UIApplication,
                         continue userActivity: NSUserActivity,
                         restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        NSLog("go here")
        window = UIWindow(frame: UIScreen.main.bounds)
        // Load the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "URLViewController") as? ViewController {
            // Wrap the HomeViewController in a UINavigationController
            let navigationController = UINavigationController(rootViewController: homeVC)

            // Set the rootViewController of the window to the UINavigationController
            window?.rootViewController = navigationController
        } else {
            // Handle the error gracefully if the view controller could not be instantiated
            print("Error: URLViewController could not be instantiated from storyboard")
        }
        NSLog(userActivity.activityType)
        if userActivity.activityType == "ConfigurationAppIntent"{
            window?.makeKeyAndVisible()
            return true
        }
            if userActivity.activityType == "com.nhb.blena.openURL" {
                let userInfo = userActivity.userInfo
                let deepLinkString = userInfo?["deepLink"] as? String
                NSLog(deepLinkString ?? "nil")
                if let viewController = window?.rootViewController as? ViewController {
                    viewController.loadURL(URL(string: deepLinkString!)!)
                }
                window?.makeKeyAndVisible()
                return true
            }
            return false
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let sharedURLString = userInfo["sharedURL"] as? String, let url = URL(string: sharedURLString) {
            // Handle the URL in the main app, for example by opening it in a view controller.
            print("Received shared URL from notification: \(url)")
            
            // Load or use the URL in your view controller.
            if let rootVC = window?.rootViewController as? UINavigationController,
               let viewController = rootVC.topViewController as? ViewController {
                viewController.loadLocation(url.absoluteString)
            }
        }
        completionHandler()
    }
}

