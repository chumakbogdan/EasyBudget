//
//  EasyBudgetApp.swift
//  EasyBudget
//
//  Created by Bogdan Chumak on 20/05/2025.
//

import SwiftUI

@main
struct EasyBudgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
