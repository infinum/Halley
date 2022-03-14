import Foundation

extension NSLocking {

    func safe<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}

class ConcurrentOperation: Operation {

    // - State Keys -
    private let _isExecutingKey = "isExecuting"
    private let _isFinishedKey = "isFinished"
    private let _lock = NSLock()

    private var _executing = false
    override private(set) var isExecuting: Bool {
        get {
            return _lock.safe { _executing }
        }
        set {
            willChangeValue(forKey: _isExecutingKey)
            _lock.safe { _executing = newValue }
            didChangeValue(forKey: _isExecutingKey)
        }
    }

    private var _finished = false
    override private(set) var isFinished: Bool {
        get {
            return _lock.safe { _finished }
        }
        set {
            willChangeValue(forKey: _isFinishedKey)
            _lock.safe { _finished = newValue }
            didChangeValue(forKey: _isFinishedKey)
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        if !isExecuting {
            isExecuting = true
        }

        main()
    }

    func finish() {
        if isExecuting {
            isExecuting = false
        }

        if !isFinished {
            isFinished = true
        }
    }

    override func main() {
        fatalError("Subclasses must override `main` and execute the operation task")
    }
}

