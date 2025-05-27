import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview do SwiftUI canvasów (np. z przykładowym użytkownikiem)
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let sampleUser = User(context: viewContext)
        sampleUser.name = "Test User"
        sampleUser.profilePicture = "person.crop.circle"

        let category = Category(context: viewContext)
        category.name = "Food"
        category.iconName = "fork.knife"

        let transaction = Transaction(context: viewContext)
        transaction.amount = 50.0
        transaction.date = Date()
        transaction.note = "Lunch"
        transaction.type = "Outcome"
        transaction.toCategory = category

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
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

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
