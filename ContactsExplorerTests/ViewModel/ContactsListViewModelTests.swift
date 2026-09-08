import Foundation
import Testing
@testable import ContactsExplorer

@MainActor
struct ContactsListViewModelTests {
    private func makeViewModel(
        contacts: [Contact] = MockGenerator.contacts(),
        fetchError: Error? = nil,
        accessGranted: Bool = true,
        favoriteIDs: Set<String> = []
    ) -> (
        viewModel: ContactsListViewModel,
        fetchingService: MockContactsFetchingService,
        favoritesStorageService: MockFavoritesStorageService,
        permissionService: MockContactsPermissionService
    ) {
        let permissionService = MockContactsPermissionService()
        permissionService.requestAccessResult = .success(accessGranted)

        let fetchingService = MockContactsFetchingService()
        fetchingService.contactsToReturn = contacts
        fetchingService.errorToThrow = fetchError

        let favoritesStorageService = MockFavoritesStorageService()
        favoritesStorageService.storedIDs = favoriteIDs

        let viewModel = ContactsListViewModel(
            dependencies: .init(
                permissionService: permissionService,
                fetchingService: fetchingService,
                favoritesStorageService: favoritesStorageService,
                logger: AppLogger.make(for: ContactsListViewModel.self)
            )
        )
        return (viewModel, fetchingService, favoritesStorageService, permissionService)
    }

    @Test("Initial state is idle with no contacts")
    func initialState() {
        let setup = makeViewModel()
        #expect(setup.viewModel.state == .idle)
        #expect(setup.viewModel.contacts.isEmpty)
    }

    @Test("Loading succeeds and populates contacts")
    func loadSucceeds() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)

        await setup.viewModel.load()

        #expect(setup.viewModel.state == .loaded)
        #expect(setup.viewModel.contacts == contacts)
    }

    @Test("Loading reflects denied permission")
    func loadPermissionDenied() async {
        let setup = makeViewModel(accessGranted: false)

        await setup.viewModel.load()

        #expect(setup.viewModel.state == .permissionDenied)
        #expect(setup.viewModel.contacts.isEmpty)
    }

    @Test("Loading fails when the fetch throws and nothing is cached")
    func loadFailsWithNoCache() async {
        struct FetchError: Error {}
        let setup = makeViewModel(fetchError: FetchError())

        await setup.viewModel.load()

        #expect(setup.viewModel.state == .failed)
        #expect(setup.viewModel.contacts.isEmpty)
    }

    @Test("A failed refresh keeps the previously loaded contacts and state")
    func refreshFailureKeepsCache() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)

        await setup.viewModel.load()
        #expect(setup.viewModel.state == .loaded)

        struct RefreshError: Error {}
        setup.fetchingService.errorToThrow = RefreshError()
        await setup.viewModel.load()

        #expect(setup.viewModel.state == .loaded)
        #expect(setup.viewModel.contacts == contacts)
    }

    @Test("Toggling favorite flips state and persists through the storage service")
    func toggleFavoritePersists() {
        let contact = MockGenerator.contact()
        let setup = makeViewModel()

        #expect(!setup.viewModel.isFavorite(contact))

        setup.viewModel.toggleFavorite(contact)
        #expect(setup.viewModel.isFavorite(contact))
        #expect(setup.favoritesStorageService.storedIDs.contains(contact.id))
        #expect(setup.favoritesStorageService.saveCallCount == 1)

        setup.viewModel.toggleFavorite(contact)
        #expect(!setup.viewModel.isFavorite(contact))
        #expect(!setup.favoritesStorageService.storedIDs.contains(contact.id))
    }

    @Test("Favorites loaded from storage are reflected immediately")
    func loadsInitialFavorites() {
        let contact = MockGenerator.contact()
        let setup = makeViewModel(favoriteIDs: [contact.id])

        #expect(setup.viewModel.isFavorite(contact))
    }

    @Test("Search matches by contact name")
    func searchMatchesByName() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)
        await setup.viewModel.load()

        setup.viewModel.searchText = "emma"

        #expect(setup.viewModel.filteredContacts.map(\.id) == ["contact-emma"])
        #expect(!setup.viewModel.hasNoSearchResults)
    }

    @Test("Search matches by phone number digits, ignoring formatting")
    func searchMatchesByPhoneNumber() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)
        await setup.viewModel.load()

        setup.viewModel.searchText = "555-0187"

        #expect(setup.viewModel.filteredContacts.map(\.id) == ["contact-james"])
    }

    @Test("Search with no matches reports no results")
    func searchNoResults() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)
        await setup.viewModel.load()

        setup.viewModel.searchText = "no-such-contact"

        #expect(setup.viewModel.filteredContacts.isEmpty)
        #expect(setup.viewModel.hasNoSearchResults)
    }

    @Test("Blank search returns every contact")
    func blankSearchReturnsAll() async {
        let contacts = MockGenerator.contacts()
        let setup = makeViewModel(contacts: contacts)
        await setup.viewModel.load()

        setup.viewModel.searchText = "   "

        #expect(setup.viewModel.filteredContacts == contacts)
        #expect(!setup.viewModel.hasNoSearchResults)
    }
}
