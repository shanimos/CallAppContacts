import Foundation

final class MockContactImageLoadingService: ContactImageLoadingServiceProtocol {
    var imageDataToReturn: Data?
    var errorToThrow: Error?
    private(set) var loadCallCount = 0

    func loadFullImageData(forContactID id: String) async throws -> Data? {
        loadCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return imageDataToReturn
    }
}
