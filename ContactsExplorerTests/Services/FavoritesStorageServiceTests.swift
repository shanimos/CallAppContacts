import Foundation
import Testing
@testable import ContactsExplorer

struct FavoritesStorageServiceTests {
    private func makeService() -> (service: FavoritesStorageService, suiteName: String) {
        let suiteName = "FavoritesStorageServiceTests-\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let service = FavoritesStorageService(dependencies: .init(userDefaults: userDefaults))
        return (service, suiteName)
    }

    @Test("Loading favorites with nothing stored returns an empty set")
    func loadEmptyByDefault() {
        let setup = makeService()
        defer { UserDefaults().removePersistentDomain(forName: setup.suiteName) }

        #expect(setup.service.loadFavoriteIDs().isEmpty)
    }

    @Test("Saved favorite IDs round-trip through loadFavoriteIDs")
    func saveAndLoadRoundTrips() {
        let setup = makeService()
        defer { UserDefaults().removePersistentDomain(forName: setup.suiteName) }
        let ids: Set<String> = ["contact-a", "contact-b"]

        setup.service.saveFavoriteIDs(ids)

        #expect(setup.service.loadFavoriteIDs() == ids)
    }

    @Test("Saving an empty set clears previously stored favorites")
    func savingEmptySetClears() {
        let setup = makeService()
        defer { UserDefaults().removePersistentDomain(forName: setup.suiteName) }

        setup.service.saveFavoriteIDs(["contact-a"])
        setup.service.saveFavoriteIDs([])

        #expect(setup.service.loadFavoriteIDs().isEmpty)
    }
}
