import Contacts
@testable import ContactsExplorer

enum FakeContactStoreError: Error {
    case contactNotFound
}

final class FakeContactStore: ContactStoreProtocol, @unchecked Sendable {
    var statusToReturn: CNAuthorizationStatus = .authorized
    var requestAccessResult: Result<Bool, Error> = .success(true)
    var contactsToEnumerate: [CNContact] = []
    var enumerateError: Error?
    var contactToReturn: CNContact?
    var unifiedContactError: Error?

    private(set) var requestAccessCallCount = 0
    private(set) var enumerateCallCount = 0
    private(set) var unifiedContactCallCount = 0
    private(set) var lastRequestedIdentifier: String?

    func authorizationStatus(for entityType: CNEntityType) -> CNAuthorizationStatus {
        statusToReturn
    }

    func requestAccess(for entityType: CNEntityType) async throws -> Bool {
        requestAccessCallCount += 1
        return try requestAccessResult.get()
    }

    func enumerateContacts(
        with request: CNContactFetchRequest,
        usingBlock block: @escaping (CNContact, UnsafeMutablePointer<ObjCBool>) -> Void
    ) async throws {
        enumerateCallCount += 1
        if let enumerateError {
            throw enumerateError
        }
        var stop: ObjCBool = false
        for contact in contactsToEnumerate {
            withUnsafeMutablePointer(to: &stop) { block(contact, $0) }
            if stop.boolValue { break }
        }
    }

    func unifiedContact(withIdentifier identifier: String, keysToFetch: [CNKeyDescriptor]) async throws -> CNContact {
        unifiedContactCallCount += 1
        lastRequestedIdentifier = identifier
        if let unifiedContactError {
            throw unifiedContactError
        }
        guard let contactToReturn else {
            throw FakeContactStoreError.contactNotFound
        }
        return contactToReturn
    }
}

func makeFakeCNContact(
    givenName: String = "",
    familyName: String = "",
    organizationName: String = "",
    phoneNumber: String? = nil,
    imageData: Data? = nil
) -> CNContact {
    let contact = CNMutableContact()
    contact.givenName = givenName
    contact.familyName = familyName
    contact.organizationName = organizationName
    if let phoneNumber {
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber))]
    }
    if let imageData {
        contact.imageData = imageData
    }
    return contact
}
