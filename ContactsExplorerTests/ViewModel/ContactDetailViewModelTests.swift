import Contacts
import Foundation
import Testing
@testable import ContactsExplorer

@MainActor
struct ContactDetailViewModelTests {
    private func makeViewModel(
        contact: Contact = MockGenerator.contact(),
        authorizationStatus: CNAuthorizationStatus = .authorized,
        imageData: Data? = nil,
        loadError: Error? = nil
    ) -> (viewModel: ContactDetailViewModel, imageLoadingService: MockContactImageLoadingService) {
        let permissionService = MockContactsPermissionService()
        permissionService.statusToReturn = authorizationStatus

        let imageLoadingService = MockContactImageLoadingService()
        imageLoadingService.imageDataToReturn = imageData
        imageLoadingService.errorToThrow = loadError

        let viewModel = ContactDetailViewModel(
            contact: contact,
            dependencies: .init(
                permissionService: permissionService,
                imageLoadingService: imageLoadingService,
                logger: AppLogger.make(for: ContactDetailViewModel.self)
            )
        )
        return (viewModel, imageLoadingService)
    }

    @Test("Loads the full image when access is authorized")
    func loadsImageWhenAuthorized() async {
        let imageData = Data([0x01, 0x02])
        let setup = makeViewModel(authorizationStatus: .authorized, imageData: imageData)

        await setup.viewModel.loadFullImage()

        #expect(setup.viewModel.fullImageData == imageData)
        #expect(setup.imageLoadingService.loadCallCount == 1)
    }

    @Test("Loads the full image when access is limited")
    func loadsImageWhenLimited() async {
        let imageData = Data([0x03])
        let setup = makeViewModel(authorizationStatus: .limited, imageData: imageData)

        await setup.viewModel.loadFullImage()

        #expect(setup.viewModel.fullImageData == imageData)
        #expect(setup.imageLoadingService.loadCallCount == 1)
    }

    @Test("Skips loading when access is denied")
    func skipsLoadingWhenDenied() async {
        let setup = makeViewModel(authorizationStatus: .denied, imageData: Data([0x01]))

        await setup.viewModel.loadFullImage()

        #expect(setup.viewModel.fullImageData == nil)
        #expect(setup.imageLoadingService.loadCallCount == 0)
    }

    @Test("Skips loading when access is not yet determined")
    func skipsLoadingWhenNotDetermined() async {
        let setup = makeViewModel(authorizationStatus: .notDetermined, imageData: Data([0x01]))

        await setup.viewModel.loadFullImage()

        #expect(setup.viewModel.fullImageData == nil)
        #expect(setup.imageLoadingService.loadCallCount == 0)
    }

    @Test("Leaves the image nil when loading throws")
    func handlesLoadError() async {
        struct LoadError: Error {}
        let setup = makeViewModel(authorizationStatus: .authorized, loadError: LoadError())

        await setup.viewModel.loadFullImage()

        #expect(setup.viewModel.fullImageData == nil)
    }
}
