import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview do SwiftUI canvasów (np. z przykładowym użytkownikiem)
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let sampleUser = User(context: viewContext)
        sampleUser.name = "Test User"

        // Dodaj domyślne zdjęcie profilowe jako Data (binary)
        if let defaultImage = UIImage(systemName: "person.circle"),
           let imageData = defaultImage.pngData() {
            sampleUser.profilePicture = imageData
        }

        let sampleCategory = Category(context: viewContext)
        sampleCategory.name = "Food"
        sampleCategory.iconName = "fork.knife"

        let sampleTransaction = Transaction(context: viewContext)
        sampleTransaction.amount = 50.0
        sampleTransaction.date = Date()
        sampleTransaction.note = "Lunch"
        sampleTransaction.type = "Outcome"
        sampleTransaction.toCategory = sampleCategory

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved preview error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "EasyBudget")

        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Pomocnicza funkcja zapisu kontekstu
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Save error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
