import Foundation
import Combine

// MARK: Codable + Combine

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<Item, Error> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            return ThrowingTaskPublisher { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                return try await self.request(input)
            }
        }.eraseToAnyPublisher()
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<[Item], Error> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            return ThrowingTaskPublisher { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                return try await self.requestCollection(input)
            }
        }.eraseToAnyPublisher()
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<PaginationPage<Item>, Error> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            return ThrowingTaskPublisher { [weak self] in
                guard let self else { throw HalleyKit.Error.deinited }
                return try await self.requestPage(input)
            }
        }.eraseToAnyPublisher()
    }
}
