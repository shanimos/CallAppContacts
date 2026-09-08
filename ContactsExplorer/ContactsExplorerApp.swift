//
//  ContactsExplorerApp.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import SwiftUI

@main
struct ContactsExplorerApp: App {
    private let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies()
    }

    var body: some Scene {
        WindowGroup {
            ContactsListView(
                contactsListVMDependencies: .init(
                    permissionService: dependencies.permissionService,
                    fetchingService: dependencies.fetchingService,
                    favoritesStorageService: dependencies.favoritesStorageService,
                    logger: AppLogger.make(for: ContactsListViewModel.self)
                ),
                contactDetailVMDependencies: .init(
                    permissionService: dependencies.permissionService,
                    imageLoadingService: dependencies.contactImageLoadingService,
                    logger: AppLogger.make(for: ContactDetailViewModel.self)
                )
            )
        }
    }
}
