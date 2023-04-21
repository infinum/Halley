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
        return Single
            .create { [weak base] observer in
                let task = Task { [weak base] in
                    guard let base else { throw HalleyKit.Error.deinited }
                    observer(.success(try await base.request(input)))
                }
                return Disposables.create { task.cancel() }
            }
            .observe(on: responseScheduler)
    }

    func requestCollection<Item>(
        _ input: HalleyRequest<Item>,
        responseScheduler: ImmediateSchedulerType = MainScheduler.instance
    ) -> Single<[Item]> {
        return Single
            .create { [weak base] observer in
                let task = Task { [weak base] in
                    guard let base else { throw HalleyKit.Error.deinited }
                    observer(.success(try await base.requestCollection(input)))
                }
                return Disposables.create { task.cancel() }
            }
            .observe(on: responseScheduler)
    }

    func requestPage<Item>(
        _ input: HalleyRequest<Item>,
        responseScheduler: ImmediateSchedulerType = MainScheduler.instance
    ) -> Single<PaginationPage<Item>> {
        return Single
            .create { [weak base] observer in
                let task = Task { [weak base] in
                    guard let base else { throw HalleyKit.Error.deinited }
                    observer(.success(try await base.requestPage(input)))
                }
                return Disposables.create { task.cancel() }
            }
            .observe(on: responseScheduler)
    }
}
#endif
