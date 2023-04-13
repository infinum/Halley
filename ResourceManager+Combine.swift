import Foundation
import Combine

// MARK: Codable + Combine

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<Item, Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.request(input)
        }
        return publisher.eraseToAnyPublisher()
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<[Item], Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.requestCollection(input)
        }
        return publisher.eraseToAnyPublisher()
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<PaginationPage<Item>, Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.requestPage(input)
        }
        return publisher.eraseToAnyPublisher()
    }
}
