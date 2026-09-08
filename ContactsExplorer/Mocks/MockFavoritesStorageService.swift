final class MockFavoritesStorageService: FavoritesStorageServiceProtocol {
    var storedIDs: Set<String> = []
    private(set) var saveCallCount = 0

    func loadFavoriteIDs() -> Set<String> {
        storedIDs
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        saveCallCount += 1
        storedIDs = ids
    }
}
