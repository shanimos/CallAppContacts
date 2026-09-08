import Foundation
import Observation

@MainActor
@Observable
final class ContactsListViewModel {
    var searchText = ""

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    func filteredContacts(in contacts: [Contact]) -> [Contact] {
        let query = trimmedSearchText
        guard !query.isEmpty else { return contacts }
        return contacts.filter { matches(contact: $0, query: query) }
    }

    func hasNoSearchResults(in contacts: [Contact]) -> Bool {
        !trimmedSearchText.isEmpty && filteredContacts(in: contacts).isEmpty
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
