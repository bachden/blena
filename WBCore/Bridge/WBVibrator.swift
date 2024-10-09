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



class HapticManager {
    private var hapticEngine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    // Prepare the haptic engine
    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine Creation Error: \(error.localizedDescription)")
        }
    }

    // Trigger a custom haptic pattern
    func triggerCustomHaptic() {
        // Check if the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // Define haptic intensity and sharpness
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 10.0) // Maximum intensity
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 10.0) // Sharpness of the vibration

        // Create a haptic event
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 1.0) // Duration can be increased for longer vibrations

        // Create a pattern from the event
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}
