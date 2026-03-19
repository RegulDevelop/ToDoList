//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import CoreData
import UserNotifications

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
    
    func saveTask(title: String, description: String, isCompleted: Bool, isImportant: Bool) -> TaskEntity {
        let task = TaskEntity(context: context)
        task.title = title
        task.taskDescription = description
        task.isCompleted = isCompleted
        task.isImportant = isImportant
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
    
    func updateAppBadge() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {

                let now = Date()

                let validRequests = requests.filter { request in
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                       let triggerDate = Calendar.current.date(from: trigger.dateComponents) {
                        return triggerDate > now
                    }
                    return false
                }

                UNUserNotificationCenter.current().setBadgeCount(validRequests.count)
            }
        }
    }
    
//    // Планирование уведомления
//    func scheduleNotification(for task: TaskEntity) {
//        guard let remindDate = task.remindAt, !task.isCompleted else { return }
//
//        let soundName = UNNotificationSoundName("mixkit-flute-mobile-phone-notification-alert-2316.caf")
//        let content = UNMutableNotificationContent()
//        content.title = task.title ?? "Напоминание"
//        content.body = task.taskDescription ?? ""
//        content.sound = UNNotificationSound(named: soundName)
//
//        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//
//        let request = UNNotificationRequest(identifier: task.notificationId,
//                                            content: content,
//                                            trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Ошибка при добавлении уведомления: \(error)")
//            } else {
//                print("Уведомление запланировано на \(remindDate)")
//            }
//        }
//    }
    
    func scheduleNotification(for task: TaskEntity) {
            // Проверяем дату напоминания и статус задачи
            guard let remindDate = task.remindAt, !task.isCompleted else { return }
        
            CoreDataManager.shared.updateAppBadge()

            // Устанавливаем контент уведомления
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Напоминание"
        content.body = task.taskDescription ?? ""
//        content.badge = NSNumber(value: 1)
            
            // Используем пользовательский звук
            // Имя файла должно быть точным и включать расширение
            let soundFileName = "mixkit-flute-mobile-phone-notification-alert-2316.caf"
            if let _ = Bundle.main.url(forResource: soundFileName, withExtension: nil) {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundFileName))
            } else {
                print("⚠️ Файл звука не найден в бандле, используется стандартный звук")
                content.sound = .default
            }

            // Настройка триггера
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            // Запрос на уведомление
            let request = UNNotificationRequest(identifier: task.notificationId,
                                                content: content,
                                                trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error)")
            } else {
                print("✅ Уведомление запланировано на \(remindDate)")
                self.updateAppBadge()
            }
        }
        }

    // Удаление уведомления
    func removeNotification(for task: TaskEntity) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.notificationId])
        updateAppBadge()
    }
    
}

