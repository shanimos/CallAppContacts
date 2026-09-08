@preconcurrency import Contacts

protocol ContactStoreProtocol: Sendable {
    func authorizationStatus(for entityType: CNEntityType) -> CNAuthorizationStatus
    func requestAccess(for entityType: CNEntityType) async throws -> Bool
    func enumerateContacts(
        with request: CNContactFetchRequest,
        usingBlock block: @escaping (CNContact, UnsafeMutablePointer<ObjCBool>) -> Void
    ) async throws
    func unifiedContact(withIdentifier identifier: String, keysToFetch: [CNKeyDescriptor]) async throws -> CNContact
}

extension CNContactStore: ContactStoreProtocol {
    func authorizationStatus(for entityType: CNEntityType) -> CNAuthorizationStatus {
        Self.authorizationStatus(for: entityType)
    }
}
