@preconcurrency import Contacts

protocol ContactsFetchingServiceProtocol {
    func fetchContacts() async throws -> [Contact]
}

final class ContactsFetchingService: ContactsFetchingServiceProtocol {
    struct Dependencies: Sendable {
        let contactStore: ContactStoreProtocol
        let sortOrder: CNContactSortOrder
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func fetchContacts() async throws -> [Contact] {
        try await Task.detached(priority: .userInitiated) { [dependencies] in
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            request.sortOrder = dependencies.sortOrder

            var fetched: [Contact] = []
            try await dependencies.contactStore.enumerateContacts(with: request) { cnContact, _ in
                fetched.append(Contact(cnContact))
            }
            return fetched
        }.value
    }
}
