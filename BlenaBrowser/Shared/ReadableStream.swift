//
//  ReadableStream.swift
//  blena
//
//  Created by Lê Vinh on 12/4/24.
//

import Foundation

/// A protocol defining the behavior of a ReadableStreamController.
protocol ReadableStreamController {
    func enqueue(_ chunk: Any)
    func close()
    func error(_ error: Error)
}

/// A custom error type for the stream.
enum ReadableStreamError: Error {
    case streamClosed
    case streamErrored(Error)
}

/// A class to represent a `ReadableStream`.
class ReadableStream {
    private var controller: StreamController?
    private var chunks: [Any] = []
    private var isClosed = false
    private var hasErrored = false
    private var error: Error?

    init(start: @escaping (ReadableStreamController) -> Void) {
        self.controller = StreamController(stream: self)
        DispatchQueue.global().async {
            start(self.controller!)
        }
    }

    /// A function to retrieve a reader for the stream.
    func getReader() -> ReadableStreamReader {
        return ReadableStreamReader(stream: self)
    }

    fileprivate func enqueue(_ chunk: Any) {
        guard !isClosed && !hasErrored else { return }
        chunks.append(chunk)
    }

    fileprivate func close() {
        isClosed = true
    }

    fileprivate func setError(_ error: Error) {
        hasErrored = true
        self.error = error
    }

    fileprivate func read() -> Result<Any?, ReadableStreamError> {
        if hasErrored {
            return .failure(.streamErrored(error!))
        }
        if chunks.isEmpty {
            return isClosed ? .success(nil) : .failure(.streamClosed)
        }
        return .success(chunks.removeFirst())
    }
}

/// A class to represent the `ReadableStreamController`.
class StreamController: ReadableStreamController {
    private weak var stream: ReadableStream?

    init(stream: ReadableStream) {
        self.stream = stream
    }

    func enqueue(_ chunk: Any) {
        stream?.enqueue(chunk)
    }

    func close() {
        stream?.close()
    }

    func error(_ error: Error) {
        stream?.setError(error)
    }
}

/// A class to represent the `ReadableStreamReader`.
class ReadableStreamReader {
    private weak var stream: ReadableStream?

    init(stream: ReadableStream) {
        self.stream = stream
    }

    /// Reads the next chunk from the stream.
    func read() -> Result<Any?, ReadableStreamError> {
        guard let stream = stream else {
            return .failure(.streamClosed)
        }
        return stream.read()
    }
}
