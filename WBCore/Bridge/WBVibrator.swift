//
//  WBVibrator.swift
//  blena
//
//  Created by Lê Vinh on 10/1/24.
//
import UIKit
import AudioToolbox
import CoreHaptics

enum VibrateStyle: String {
    case light, medium, strong ,test
}

func vibrate(style: VibrateStyle){
    switch style {
    case .test:
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.prepare()
        feedback.impactOccurred()
    case .strong:
              UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    case .light:
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
    case .medium:
              UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

func JSLog(_ message: String) {
    NSLog("JavaScript: \(message)")
}



