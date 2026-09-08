import Foundation

protocol FavoritesStorageServiceProtocol {
    func loadFavoriteIDs() -> Set<String>
    func saveFavoriteIDs(_ ids: Set<String>)
}

final class FavoritesStorageService: FavoritesStorageServiceProtocol {
    struct Dependencies {
        let userDefaults: UserDefaults
    }

    private enum Key: String {
        case favoriteContactIDs
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func loadFavoriteIDs() -> Set<String> {
        let ids = dependencies.userDefaults.stringArray(forKey: Key.favoriteContactIDs.rawValue) ?? []
        return Set(ids)
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        dependencies.userDefaults.set(Array(ids), forKey: Key.favoriteContactIDs.rawValue)
    }
}
