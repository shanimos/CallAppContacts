final class MockContactsFetchingService: ContactsFetchingServiceProtocol {
    var contactsToReturn: [Contact] = []
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0

    func fetchContacts() throws -> [Contact] {
        fetchCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return contactsToReturn
    }
}
