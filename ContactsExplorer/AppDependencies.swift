import Contacts
import Foundation

struct AppDependencies {
    let permissionService: ContactsPermissionServiceProtocol = ContactsPermissionService(
        dependencies: .init(contactStore: CNContactStore()))
    let fetchingService: ContactsFetchingServiceProtocol = ContactsFetchingService(dependencies: .init(contactStore: CNContactStore(), sortOrder: .userDefault))
    let favoritesStorageService: FavoritesStorageServiceProtocol = FavoritesStorageService(dependencies: .init(userDefaults: .standard))
    let contactImageLoadingService: ContactImageLoadingServiceProtocol = ContactImageLoadingService(dependencies: .init(contactStore: CNContactStore()))
}
