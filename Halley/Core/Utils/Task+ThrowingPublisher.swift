import Combine

final class ThrowingTaskPublisher<Success> {
    typealias Work = () async throws -> Success
    private let work: Work

    init(_ work: @escaping Work) {
        self.work = work
    }
}

extension ThrowingTaskPublisher: Publisher {
    typealias Output = Success
    typealias Failure = Error

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription<S>(work, downstream: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension ThrowingTaskPublisher {

    actor Subscription<Downstream: Subscriber> where Downstream.Input == Output, Downstream.Failure == Failure {
        let work: Work
        var task: Task<Void, Never>?
        var downstream: Downstream?

        init(_ work: @escaping Work, downstream: Downstream? = nil) {
            self.work = work
            self.downstream = downstream
        }

        func cleanup() {
            task = nil
            downstream = nil
        }

        func cancelAndCleanup() {
            task?.cancel()
            cleanup()
        }

        func receive(_ value: Output) {
            _ = downstream?.receive(value)
            downstream?.receive(completion: .finished)
            cleanup()
        }

        func fail(_ error: Failure) {
            downstream?.receive(completion: .failure(error))
            cleanup()
        }

        func runWork() {
            guard task == nil else { return }
            task = Task<Void, Never> {
                do {
                    receive(try await work())
                } catch {
                    fail(error)
                }
            }
        }
    }
}

extension ThrowingTaskPublisher.Subscription: Subscription {

    nonisolated func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        Task<Void, Never> { await runWork() }
    }

    nonisolated func cancel() {
        Task<Void, Never> { await cancelAndCleanup() }
    }
}
