import Contacts
import Testing
@testable import ContactsExplorer

struct ContactImageLoadingServiceTests {
    private func makeService(store: FakeContactStore) -> ContactImageLoadingService {
        ContactImageLoadingService(dependencies: .init(contactStore: store))
    }

    @Test("Returns the image data for the requested contact identifier")
    func returnsImageData() async throws {
        let imageData = Data([0x01, 0x02, 0x03])
        let store = FakeContactStore()
        store.contactToReturn = makeFakeCNContact(imageData: imageData)
        let service = makeService(store: store)

        let result = try await service.loadFullImageData(forContactID: "contact-1")

        #expect(result == imageData)
        #expect(store.lastRequestedIdentifier == "contact-1")
        #expect(store.unifiedContactCallCount == 1)
    }

    @Test("Returns nil when the contact has no image")
    func returnsNilWhenNoImage() async throws {
        let store = FakeContactStore()
        store.contactToReturn = makeFakeCNContact()
        let service = makeService(store: store)

        let result = try await service.loadFullImageData(forContactID: "contact-1")

        #expect(result == nil)
    }

    @Test("Propagates an error thrown while fetching the contact")
    func propagatesFetchError() async {
        struct FetchError: Error {}
        let store = FakeContactStore()
        store.unifiedContactError = FetchError()
        let service = makeService(store: store)

        await #expect(throws: FetchError.self) {
            try await service.loadFullImageData(forContactID: "contact-1")
        }
    }
}
