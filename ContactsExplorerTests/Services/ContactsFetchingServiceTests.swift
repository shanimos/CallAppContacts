import Contacts
import Testing
@testable import ContactsExplorer

struct ContactsFetchingServiceTests {
    private func makeService(store: FakeContactStore, sortOrder: CNContactSortOrder = .userDefault) -> ContactsFetchingService {
        ContactsFetchingService(dependencies: .init(contactStore: store, sortOrder: sortOrder))
    }

    @Test("Maps every enumerated CNContact into a Contact")
    func mapsEnumeratedContacts() async throws {
        let store = FakeContactStore()
        store.contactsToEnumerate = [
            makeFakeCNContact(givenName: "Emma", familyName: "Stone", phoneNumber: "555-0100"),
            makeFakeCNContact(givenName: "James", familyName: "Chen", phoneNumber: "555-0101")
        ]
        let service = makeService(store: store)

        let contacts = try await service.fetchContacts()

        #expect(contacts.map(\.givenName) == ["Emma", "James"])
        #expect(contacts.map(\.familyName) == ["Stone", "Chen"])
        #expect(store.enumerateCallCount == 1)
    }

    @Test("Returns an empty array when there are no contacts")
    func returnsEmptyArrayWhenNoContacts() async throws {
        let store = FakeContactStore()
        let service = makeService(store: store)

        let contacts = try await service.fetchContacts()

        #expect(contacts.isEmpty)
    }

    @Test("Propagates an error thrown while enumerating")
    func propagatesEnumerateError() async {
        struct EnumerateError: Error {}
        let store = FakeContactStore()
        store.enumerateError = EnumerateError()
        let service = makeService(store: store)

        await #expect(throws: EnumerateError.self) {
            try await service.fetchContacts()
        }
    }
}
