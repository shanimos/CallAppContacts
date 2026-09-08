import Foundation
import Observation
import os

@MainActor
@Observable
final class ContactsListViewModel {
    enum LoadState {
        case idle, loading, loaded, permissionDenied, failed
    }

    struct Dependencies {
        let permissionService: ContactsPermissionServiceProtocol
        let fetchingService: ContactsFetchingServiceProtocol
        let favoritesStorageService: FavoritesStorageServiceProtocol
        let logger: Logger
    }

    var searchText = ""
    private(set) var contacts: [Contact] = []
    private(set) var state: LoadState = .idle
    private(set) var favoriteIDs: Set<String>

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        favoriteIDs = dependencies.favoritesStorageService.loadFavoriteIDs()
    }

    func load() async {
        if contacts.isEmpty { state = .loading }
        do {
            guard try await dependencies.permissionService.requestAccessIfNeeded() else {
                state = .permissionDenied
                return
            }
            contacts = try await dependencies.fetchingService.fetchContacts()
            state = .loaded
        } catch {
            dependencies.logger.error("Loading contacts failed: \(String(describing: error))")
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

    var filteredContacts: [Contact] {
        let query = trimmedSearchText
        guard !query.isEmpty else { return contacts }
        return contacts.filter { matches(contact: $0, query: query) }
    }

    var hasNoSearchResults: Bool {
        !trimmedSearchText.isEmpty && filteredContacts.isEmpty
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    private func matches(contact: Contact, query: String) -> Bool {
        if contact.displayName.localizedCaseInsensitiveContains(query) {
            return true
        }
        guard isPhoneNumber(query: query) else {
            return false
        }
        let queryDigits = query.filter(\.isWholeNumber)
        return contact.phoneNumbers.contains { $0.value.filter(\.isWholeNumber).contains(queryDigits) }
    }

    private func isPhoneNumber(query: String) -> Bool {
        query.contains(where: \.isWholeNumber) &&
            query.allSatisfy { $0.isWholeNumber || "+-(). ".contains($0) }
    }
}
