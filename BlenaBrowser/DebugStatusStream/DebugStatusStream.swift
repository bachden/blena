import Foundation
import Combine
import Darwin

// Custom class to stream debugger status
class DebuggerStatusStream {
    // Combine subject to stream changes in debugger status
    private let debuggerStatusSubject = PassthroughSubject<Bool, Never>()
    private var timer: DispatchSourceTimer?
    private var currentStatus: Bool = false

    // Public stream for others to subscribe to
    var statusStream: AnyPublisher<Bool, Never> {
        return debuggerStatusSubject.eraseToAnyPublisher()
    }

    // Start the listener with a default interval of 1 second
    func startStreaming(interval: TimeInterval = 1.0) {
        stopStreaming() // Stop any existing timer

        let queue = DispatchQueue(label: "debugger.check.queue", qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: interval)

        // Periodically check debugger status
        timer?.setEventHandler { [weak self] in
            self?.checkDebuggerStatus()
        }

        timer?.resume()
    }

    // Stop the timer and streaming
    func stopStreaming() {
        timer?.cancel()
        timer = nil
    }

    // Check the current debugger status and publish updates
    private func checkDebuggerStatus() {
        let newStatus = isDebuggerAttachedToProcess()
        if newStatus != currentStatus {
            currentStatus = newStatus
            debuggerStatusSubject.send(currentStatus) // Publish status change
        }
    }

    // Detect if the process is being traced (debugged)
     func isDebuggerAttachedToProcess() -> Bool {
        var info = kinfo_proc()
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride

        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        assert(result == 0, "sysctl failed")

        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}

// Usage Example: Subscribe to the stream

let debuggerStream = DebuggerStatusStream()

// Subscribe to the debugger status stream
let cancellable = debuggerStream.statusStream
    .receive(on: DispatchQueue.main) // Ensure updates are received on the main thread
    .sink { isDebuggerAttached in
        if isDebuggerAttached {
            print("Debugger is attached.")
        } else {
            print("Debugger is not attached.")
        }
    }

// Start streaming
//debuggerStream.startStreaming(interval: 2.0)

// Later, when you're done, you can stop the stream and cancel the subscription
// debuggerStream.stopStreaming()
// cancellable.cancel()
