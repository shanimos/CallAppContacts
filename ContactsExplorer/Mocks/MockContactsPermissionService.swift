import Foundation
import Contacts

final class MockContactsPermissionService: ContactsPermissionServiceProtocol {
    var statusToReturn: CNAuthorizationStatus = .authorized
    var requestAccessResult: Result<Bool, Error> = .success(true)
    private(set) var requestAccessCallCount = 0

    func authorizationStatus() -> CNAuthorizationStatus {
        statusToReturn
    }

    func requestAccessIfNeeded() async throws -> Bool {
        requestAccessCallCount += 1
        return try requestAccessResult.get()
    }
}
