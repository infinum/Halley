#if canImport(RxSwift)
import Foundation
import RxSwift

// MARK: Codable + Rx

extension ResourceManager: ReactiveCompatible {}

public extension Reactive where Base: ResourceManager {

    func request<Item>(
        _ input: HalleyRequest<Item>,
        responseScheduler: ImmediateSchedulerType = MainScheduler.instance
    ) -> Single<Item> {
        return Single<Item>
            .fromAsyncDeffered { [weak base] in
                guard let base else { throw HalleyKit.Error.deinited }
                return try await base.request(input)
            }
            .observe(on: responseScheduler)
    }

    func requestCollection<Item>(
        _ input: HalleyRequest<Item>,
        responseScheduler: ImmediateSchedulerType = MainScheduler.instance
    ) -> Single<[Item]> {
        return Single<[Item]>
            .fromAsyncDeffered { [weak base] in
                guard let base else { throw HalleyKit.Error.deinited }
                return try await base.requestCollection(input)
            }
            .observe(on: responseScheduler)
    }

    func requestPage<Item>(
        _ input: HalleyRequest<Item>,
        responseScheduler: ImmediateSchedulerType = MainScheduler.instance
    ) -> Single<PaginationPage<Item>> {
        return Single<PaginationPage<Item>>
            .fromAsyncDeffered { [weak base] in
                guard let base else { throw HalleyKit.Error.deinited }
                return try await base.requestPage(input)
            }
            .observe(on: responseScheduler)
    }
}

extension Single {

    static func fromAsync<T>(_ asyncFunction: @escaping () async throws -> T) -> Single<T> {
        .create { observer in
            let task = Task {
                do { try await observer(.success(asyncFunction())) }
                catch { observer(.failure(error))}
            }
            return Disposables.create { task.cancel() }
        }
    }

    static func fromAsyncDeffered<T>(_ asyncFunction: @escaping () async throws -> T) -> Single<T> {
        .deferred { .fromAsync(asyncFunction) }
    }
}
#endif
