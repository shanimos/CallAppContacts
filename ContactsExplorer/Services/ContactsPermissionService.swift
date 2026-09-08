import Contacts

protocol ContactsPermissionServiceProtocol {
    func authorizationStatus() -> CNAuthorizationStatus
    func requestAccessIfNeeded() async throws -> Bool
}

final class ContactsPermissionService: ContactsPermissionServiceProtocol {
    struct Dependencies {
        let contactStore: CNContactStore
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func authorizationStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    func requestAccessIfNeeded() async throws -> Bool {
        switch authorizationStatus() {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return try await dependencies.contactStore.requestAccess(for: .contacts)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}
