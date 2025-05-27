//
//  ContentView.swift
//  EasyBudget
//
//  Created by Bogdan Chumak on 20/05/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }

            AddTransactionView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }
        }
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
