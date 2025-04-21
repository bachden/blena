//
//  HapticManager.swift
//  blena
//
//  Created by Lê Vinh on 21/4/25.
//


import CoreHaptics
import UIKit

class HapticManager {
  static let shared = HapticManager()
  private var engine: CHHapticEngine?

  private init() {
    prepareHaptics()
  }

  private func prepareHaptics() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    do {
      engine = try CHHapticEngine()
      try engine?.start()
    } catch {
      print("⚠️ Haptics not available: \(error)")
    }
  }

  /// Public API #1: accept a variadic list of Ints
  func vibrate(_ durations: Int...) {
    vibratePattern(durations)
  }

  /// Public API #2: accept an array of Ints
  func vibrate(_ durations: [Int]) {
    vibratePattern(durations)
  }

  /// Private helper: build & play the pattern
  private func vibratePattern(_ durations: [Int]) {
    guard let engine = engine else { return }

    var events: [CHHapticEvent] = []
    var timeOffset: TimeInterval = 0

    for (i, ms) in durations.enumerated() {
      let seconds = TimeInterval(ms) / 1000
      if i % 2 == 0 {
        // even index → vibrate
        let event = CHHapticEvent(
          eventType: .hapticContinuous,
          parameters: [],
          relativeTime: timeOffset,
          duration: seconds
        )
        events.append(event)
      }
      // advance by either vibration or pause
      timeOffset += seconds
    }

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player  = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      print("Failed to play haptic pattern: \(error)")
    }
  }
}