import Combine
import Contacts
import Foundation
import os

final class ContactsStore: ObservableObject {
    struct Dependencies {
        let permissionService: ContactsPermissionServiceProtocol
        let fetchingService: ContactsFetchingServiceProtocol
        let favoritesStorageService: FavoritesStorageServiceProtocol
    }

    enum LoadState {
        case idle, loading, loaded, permissionDenied, failed
    }

    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var state: LoadState = .idle
    @Published private(set) var favoriteIDs: Set<String>

    private let dependencies: Dependencies
    private let logger = Logger(subsystem: "com.shaibalassiano.ContactsExplorer", category: "ContactsStore")

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.favoriteIDs = dependencies.favoritesStorageService.loadFavoriteIDs()
    }

    func load() async {
        if contacts.isEmpty { state = .loading }
        do {
            guard try await dependencies.permissionService.requestAccessIfNeeded() else {
                state = .permissionDenied
                return
            }
            contacts = try dependencies.fetchingService.fetchContacts()
            state = .loaded
        } catch {
            logger.error("Loading contacts failed: \(String(describing: error))")
            if contacts.isEmpty { state = .failed }
        }
    }

    func toggleFavorite(_ contact: Contact) {
        if favoriteIDs.contains(contact.id) {
            favoriteIDs.remove(contact.id)
        } else {
            favoriteIDs.insert(contact.id)
        }
        dependencies.favoritesStorageService.saveFavoriteIDs(favoriteIDs)
    }

    func isFavorite(_ contact: Contact) -> Bool {
        favoriteIDs.contains(contact.id)
    }
}
