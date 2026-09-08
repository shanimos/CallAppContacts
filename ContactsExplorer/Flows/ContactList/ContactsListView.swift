import SwiftUI

struct ContactsListView: View {
    @Environment(\.openURL) private var openURL
    @State private var viewModel: ContactsListViewModel
    @State private var path: [Contact] = []

    let contactDetailVMDependencies: ContactDetailViewModel.Dependencies

    init(
        contactsListVMDependencies: ContactsListViewModel.Dependencies,
        contactDetailVMDependencies: ContactDetailViewModel.Dependencies
    ) {
        _viewModel = State(initialValue: ContactsListViewModel(dependencies: contactsListVMDependencies))
        self.contactDetailVMDependencies = contactDetailVMDependencies
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Contacts")
                .navigationDestination(for: Contact.self) { contact in
                    ContactDetailView(
                        contact: contact,
                        isFavorite: Binding(
                            get: { viewModel.isFavorite(contact) },
                            set: { _ in viewModel.toggleFavorite(contact) }
                        ),
                        contactDetailVMDependencies: contactDetailVMDependencies
                    )
                }
        }
        .task {
            guard viewModel.state == .idle else { return }
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading Contacts…")
        case .permissionDenied:
            permissionDeniedView
        case .failed:
            failedView
        case .loaded:
            if viewModel.contacts.isEmpty {
                noContactsView
            } else {
                contactsList
            }
        }
    }

    private var contactsList: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Name or phone number", text: $viewModel.searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            List(viewModel.filteredContacts) { contact in
                Button {
                    path.append(contact)
                } label: {
                    ContactRow(
                        contact: contact,
                        isFavorite: viewModel.isFavorite(contact),
                        onToggleFavorite: { viewModel.toggleFavorite(contact) }
                    )
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if viewModel.hasNoSearchResults {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    private var noContactsView: some View {
        ContentUnavailableView {
            Label("No Contacts", systemImage: "person.crop.circle.badge.questionmark")
        } description: {
            Text("Contacts you add will appear here.")
        }
    }

    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("No Access to Contacts", systemImage: "lock")
        } description: {
            Text("Allow access to your contacts in Settings to see them here.")
        } actions: {
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var failedView: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Your contacts could not be loaded. Please try again.")
        } actions: {
            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ContactRow: View {
    let contact: Contact
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ContactAvatarView(contact: contact, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.displayName)
                if let phoneNumber = contact.phoneNumbers.first {
                    Text(phoneNumber.value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            FavoriteButton(isFavorite: isFavorite, action: onToggleFavorite)
                .buttonStyle(.borderless)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
    }
}

struct ContactAvatarView: View {
    let contact: Contact
    var imageData: Data? = nil
    let size: CGFloat

    var body: some View {
        Group {
            if let data = imageData ?? contact.thumbnailData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                initialsAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
    }

    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.gray.gradient)
            Text(contact.initials)
                .font(.system(size: size * 0.4, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }

}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? .yellow : .secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Add to Favorites")
    }
}
