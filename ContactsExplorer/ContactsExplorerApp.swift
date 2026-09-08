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
    private let store: ContactsStore

    init() {
        dependencies = AppDependencies()
        store = ContactsStore(
            dependencies: .init(
                permissionService: dependencies.permissionService,
                fetchingService: dependencies.fetchingService,
                favoritesStorageService: dependencies.favoritesStorageService
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContactsListView(store: store)
        }
    }
}
