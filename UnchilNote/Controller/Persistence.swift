//
//  Persistence.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//
import Foundation
import CoreData

struct PersistenceController {

	let container: NSPersistentContainer

	init(inMemory:Bool = false) {

		container = NSPersistentContainer(name: "UnchilNote")

		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}

		container.viewContext.automaticallyMergesChangesFromParent = true

		container.loadPersistentStores { nsPersistentStoreDescription, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
	}

	static var shared: PersistenceController {
		return PersistenceController(inMemory: false)
	}

	static var preview: PersistenceController {
		return PersistenceController(inMemory: true)
	}

}

func commitTrans(context: NSManagedObjectContext) {
	do {
		try context.save()
	} catch {
		let nsError = error as NSError
		fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
	}
}

func truncateEntity(context: NSManagedObjectContext,  entityName: String) {
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
	do {
		let objects = try context.fetch(fetchRequest)

		objects.forEach { it in
			context.delete(it)
		}
	}catch {
		let nsError = error as NSError
		fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
	}

	commitTrans(context: context)
}
