import Foundation
@preconcurrency import Contacts

protocol ContactImageLoadingServiceProtocol {
    func loadFullImageData(forContactID id: String) async throws -> Data?
}

final class ContactImageLoadingService: ContactImageLoadingServiceProtocol {
    struct Dependencies {
        let contactStore: ContactStoreProtocol
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func loadFullImageData(forContactID id: String) async throws -> Data? {
        try await Task.detached(priority: .userInitiated) { [dependencies] in
            let keysToFetch = [CNContactImageDataKey as CNKeyDescriptor]
            let cnContact = try await dependencies.contactStore.unifiedContact(
                withIdentifier: id,
                keysToFetch: keysToFetch
            )
            return cnContact.imageData
        }.value
    }
}
