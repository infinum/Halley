#if canImport(RxSwift)
import Foundation
import RxSwift

// MARK: Codable + Rx

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) -> Single<Item> {
        return Single.create { [weak self] observer in
            let task = Task { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                observer(.success(try await self.request(input)))
            }
            return Disposables.create { task.cancel() }
        }
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> Single<[Item]> {
        return Single.create { [weak self] observer in
            let task = Task { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                observer(.success(try await self.requestCollection(input)))
            }
            return Disposables.create { task.cancel() }
        }
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) -> Single<PaginationPage<Item>> {
        return Single.create { [weak self] observer in
            let task = Task { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                observer(.success(try await self.requestPage(input)))
            }
            return Disposables.create { task.cancel() }
        }
    }
}
#endif
