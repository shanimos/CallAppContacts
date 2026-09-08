import Contacts
import Foundation
import os

@MainActor
@Observable
final class ContactDetailViewModel {
    struct Dependencies {
        let permissionService: ContactsPermissionServiceProtocol
        let imageLoadingService: ContactImageLoadingServiceProtocol
    }

    private(set) var fullImageData: Data?

    private let contact: Contact
    private let dependencies: Dependencies
    private let logger = Logger(subsystem: "com.shaibalassiano.ContactsExplorer", category: "ContactDetailViewModel")

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
            logger.error("Loading contact image failed: \(String(describing: error))")
        }
    }
}
