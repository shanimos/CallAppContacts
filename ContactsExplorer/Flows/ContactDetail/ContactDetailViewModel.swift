import Contacts
import Foundation
import os

@MainActor
@Observable
final class ContactDetailViewModel {
    struct Dependencies {
        let permissionService: ContactsPermissionServiceProtocol
        let imageLoadingService: ContactImageLoadingServiceProtocol
        let logger: Logger
    }

    private(set) var fullImageData: Data?

    private let contact: Contact
    private let dependencies: Dependencies

    init(contact: Contact, dependencies: Dependencies) {
        self.contact = contact
        self.dependencies = dependencies
    }

    func loadFullImage() async {
        guard dependencies.permissionService.authorizationStatus() == .authorized
            || dependencies.permissionService.authorizationStatus() == .limited else { return }
        do {
            fullImageData = try await dependencies.imageLoadingService.loadFullImageData(forContactID: contact.id)
        } catch {
            dependencies.logger.error("Loading contact image failed: \(String(describing: error))")
        }
    }
}
