import Contacts
import Foundation

struct Contact: Identifiable, Hashable {
    struct LabeledValue: Identifiable, Hashable {
        let label: String
        let value: String
        
        var id: String { "\(label)|\(value)" }
    }

    let id: String
    let givenName: String
    let familyName: String
    let fullName: String
    let organizationName: String
    let phoneNumbers: [LabeledValue]
    let emails: [LabeledValue]
    let birthday: Date?
    let thumbnailData: Data?
    
    private var rawName: String {
        "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
    }

    var displayName: String {
        if !rawName.isEmpty {
            return rawName
        }
        if !fullName.isEmpty {
            return fullName
        }
        if !organizationName.isEmpty {
            return organizationName
        }
        return phoneNumbers.first?.value ?? emails.first?.value ?? "No Name"
    }

    var initials: String {
        let nameInitials = [givenName.first, familyName.first].compactMap { $0 }
        if !nameInitials.isEmpty {
            return String(nameInitials).uppercased()
        }
        if let fullNameInitial = fullName.first {
            return String(fullNameInitial).uppercased()
        }
        if let organizationInitial = organizationName.first {
            return String(organizationInitial).uppercased()
        }
        return "#"
    }
}

extension Contact {
    nonisolated init(_ cnContact: CNContact) {
        id = cnContact.identifier
        givenName = cnContact.givenName
        familyName = cnContact.familyName
        fullName = CNContactFormatter.string(from: cnContact, style: .fullName) ?? ""
        organizationName = cnContact.organizationName
        phoneNumbers = cnContact.phoneNumbers.map { phoneNumber in
            LabeledValue(
                label: phoneNumber.label.map { CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0) } ?? "phone",
                value: phoneNumber.value.stringValue
            )
        }
        emails = cnContact.emailAddresses.map { email in
            LabeledValue(
                label: email.label.map { CNLabeledValue<NSString>.localizedString(forLabel: $0) } ?? "email",
                value: email.value as String
            )
        }
        birthday = cnContact.birthday.flatMap { Calendar.current.date(from: $0) }
        thumbnailData = cnContact.thumbnailImageData
    }
}
