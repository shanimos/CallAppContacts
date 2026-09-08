import Contacts

protocol ContactsFetchingServiceProtocol {
    func fetchContacts() throws -> [Contact]
}

final class ContactsFetchingService: ContactsFetchingServiceProtocol {
    struct Dependencies {
        let contactStore: CNContactStore
        let sortOrder: CNContactSortOrder
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func fetchContacts() throws -> [Contact] {
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
        try dependencies.contactStore.enumerateContacts(with: request) { cnContact, _ in
            fetched.append(Contact(cnContact))
        }
        return fetched
    }
}
