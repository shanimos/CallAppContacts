import SwiftUI

struct ContactDetailView: View {
    let contact: Contact
    @Binding var isFavorite: Bool
    @State private var viewModel: ContactDetailViewModel

    init(contact: Contact, isFavorite: Binding<Bool>, contactDetailVMDependencies: ContactDetailViewModel.Dependencies) {
        self.contact = contact
        _isFavorite = isFavorite
        _viewModel = State(initialValue: ContactDetailViewModel(contact: contact, dependencies: contactDetailVMDependencies))
    }

    var body: some View {
        List {
            header
            details
            info
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .task {
            await viewModel.loadFullImage()
        }
    }

    private var header: some View {
        Section {
            VStack(spacing: 12) {
                ContactAvatarView(contact: contact, imageData: viewModel.fullImageData, size: 120)
                Text(contact.displayName)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var details: some View {
        if contact.phoneNumbers.isEmpty && contact.emails.isEmpty {
            Section {
                Text("This contact has no phone numbers or emails.")
                    .foregroundStyle(.secondary)
            }
        } else {
            if !contact.phoneNumbers.isEmpty {
                Section("Phone Numbers") {
                    ForEach(contact.phoneNumbers) { phoneNumber in
                        LabeledContent(phoneNumber.label, value: phoneNumber.value)
                    }
                }
            }
            if !contact.emails.isEmpty {
                Section("Emails") {
                    ForEach(contact.emails) { email in
                        LabeledContent(email.label, value: email.value)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var info: some View {
        if !contact.organizationName.isEmpty || contact.birthday != nil {
            Section {
                if !contact.organizationName.isEmpty {
                    infoRow(label: "Organization", value: contact.organizationName)
                }
                if let birthday = contact.birthday {
                    infoRow(label: "Birthday", value: birthday.formatted(date: .long, time: .omitted))
                }
            } header: {
                Text("Info")
                    .font(.subheadline)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.callout)
    }

    private var favoriteButton: some View {
        FavoriteButton(isFavorite: isFavorite, action: { isFavorite.toggle() })
    }
}

