import Contacts
import Testing
@testable import ContactsExplorer

struct ContactsPermissionServiceTests {
    private func makeService(store: FakeContactStore) -> ContactsPermissionService {
        ContactsPermissionService(dependencies: .init(contactStore: store))
    }

    @Test("Reports the underlying store's authorization status")
    func reportsAuthorizationStatus() {
        let store = FakeContactStore()
        store.statusToReturn = .limited
        let service = makeService(store: store)

        #expect(service.authorizationStatus() == .limited)
    }

    @Test("Already-authorized access does not prompt the user")
    func authorizedDoesNotPrompt() async throws {
        let store = FakeContactStore()
        store.statusToReturn = .authorized
        let service = makeService(store: store)

        let granted = try await service.requestAccessIfNeeded()

        #expect(granted)
        #expect(store.requestAccessCallCount == 0)
    }

    @Test("Limited access does not prompt the user")
    func limitedDoesNotPrompt() async throws {
        let store = FakeContactStore()
        store.statusToReturn = .limited
        let service = makeService(store: store)

        let granted = try await service.requestAccessIfNeeded()

        #expect(granted)
        #expect(store.requestAccessCallCount == 0)
    }

    @Test("Not-determined status prompts the user and forwards the result")
    func notDeterminedPromptsUser() async throws {
        let store = FakeContactStore()
        store.statusToReturn = .notDetermined
        store.requestAccessResult = .success(true)
        let service = makeService(store: store)

        let granted = try await service.requestAccessIfNeeded()

        #expect(granted)
        #expect(store.requestAccessCallCount == 1)
    }

    @Test("Denied and restricted statuses report false without prompting")
    func deniedAndRestrictedReportFalse() async throws {
        for status: CNAuthorizationStatus in [.denied, .restricted] {
            let store = FakeContactStore()
            store.statusToReturn = status
            let service = makeService(store: store)

            let granted = try await service.requestAccessIfNeeded()

            #expect(!granted)
            #expect(store.requestAccessCallCount == 0)
        }
    }

    @Test("Propagates an error thrown while requesting access")
    func propagatesRequestAccessError() async {
        struct RequestError: Error {}
        let store = FakeContactStore()
        store.statusToReturn = .notDetermined
        store.requestAccessResult = .failure(RequestError())
        let service = makeService(store: store)

        await #expect(throws: RequestError.self) {
            try await service.requestAccessIfNeeded()
        }
    }
}
