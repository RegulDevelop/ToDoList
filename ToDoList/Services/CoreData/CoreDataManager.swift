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
//    func saveTask(title: String, description: String) -> TaskEntity {
//
////        let task = TaskEntity(context: context)
////
////        task.id = Int64(Date().timeIntervalSince1970)
////        task.title = title
////        task.taskDescription = description
////        task.createdAt = Date()
////        task.isCompleted = false
////
////        saveContext()
//        
//        let task = TaskEntity(context: context)
//
//        task.title = title
//        task.taskDescription = description
//        task.createdAt = Date()
//        task.isCompleted = isCompleted
//
//        saveContext()
//
//        return task
//    }
    
    func saveTask(title: String, description: String, isCompleted: Bool) -> TaskEntity {
        let task = TaskEntity(context: context)
        task.title = title
        task.taskDescription = description
        task.isCompleted = isCompleted
        task.createdAt = Date()
        saveContext()
        return task
    }
    
    // Метод получения задачи
    func fetchTasks() -> [TaskEntity] {

        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        // Сортируем сначала по order (если используешь drag&drop), потом по дате создания
        request.sortDescriptors = [
            NSSortDescriptor(key: "order", ascending: true),        // порядок из drag&drop
            NSSortDescriptor(key: "createdAt", ascending: false)    // новые сверху
        ]

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
    
    // метод сохранения API задач в CoreData
    func saveTodosFromAPI(_ todos: [TodoDTO]) {

        for todo in todos {

            let task = TaskEntity(context: context)

            task.title = todo.todo
            task.taskDescription = ""
            task.isCompleted = todo.completed
            task.createdAt = Date()
            task.order = Int64(todo.id)

        }

        saveContext()
    }
    
}
