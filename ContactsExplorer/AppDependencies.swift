import Contacts
import Foundation

struct AppDependencies {
    let permissionService: ContactsPermissionServiceProtocol
    let fetchingService: ContactsFetchingServiceProtocol
    let favoritesStorageService: FavoritesStorageServiceProtocol

    init(
        permissionService: ContactsPermissionServiceProtocol = ContactsPermissionService(
            dependencies: .init(contactStore: CNContactStore())
        ),
        fetchingService: ContactsFetchingServiceProtocol = ContactsFetchingService(
            dependencies: .init(contactStore: CNContactStore(), sortOrder: .userDefault)
        ),
        favoritesStorageService: FavoritesStorageServiceProtocol = FavoritesStorageService(
            dependencies: .init(userDefaults: .standard)
        )
    ) {
        self.permissionService = permissionService
        self.fetchingService = fetchingService
        self.favoritesStorageService = favoritesStorageService
    }
}
