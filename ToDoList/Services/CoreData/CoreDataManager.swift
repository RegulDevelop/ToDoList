//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "TaskModel")
        container.loadPersistentStores { _, error in

            if let error = error {
                fatalError("CoreData error: \(error)")
            }

        }

        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error:", error)
            }
        }
    }
    
    // Метод сохранения задачи
    func saveTask(title: String, description: String) {

        let task = TaskEntity(context: context)

        task.id = Int64(Date().timeIntervalSince1970)
        task.title = title
        task.taskDescription = description
        task.createdAt = Date()
        task.isCompleted = false

        saveContext()
    }
    
    // Метод получения задачи
    func fetchTasks() -> [TaskEntity] {

        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error:", error)
            return []
        }
    }
    
    // Метод удаления задачи
    func deleteTask(_ task: TaskEntity) {

        context.delete(task)
        saveContext()
    }
    
    // Метод обновления задачи
    func updateTask(_ task: TaskEntity, completed: Bool) {

        task.isCompleted = completed
        saveContext()
    }
    
}
