//
//  TasksViewModel.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation
import CoreData

class TasksViewModel {

    private let networkService = NetworkService()
    private let storage = CoreDataManager.shared

    // Массив задач для UI
    var tasks: [TaskEntity] = []

    // MARK: - Загрузка задач
    func loadTasks(completion: @escaping () -> Void) {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if isFirstLaunch {
            // Первый запуск → загружаем JSON
            networkService.fetchTodosFromFile { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let todos):
                    // Сохраняем задачи в CoreData
                    for todo in todos {
                        _ = self.storage.saveTask(
                            title: todo.todo,
                            description: "UserID: \(todo.userId)",
                            isCompleted: false   // например, новые задачи считаем невыполненными
                        )
                    }
                    // Ставим флаг, что первый запуск уже был
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")

                case .failure(let error):
                    print("Ошибка загрузки API: \(error)")
                }

                // Загружаем все задачи из CoreData
                self.tasks = self.storage.fetchTasks()
                completion()
            }
        } else {
            // Не первый запуск → просто грузим задачи из CoreData
            tasks = storage.fetchTasks()
            completion()
        }
    }

    // MARK: - Добавление новой задачи
    func addTask(title: String, userId: Int, description: String, isCompleted: Bool) {
//        // Сохраняем в CoreData
//        storage.saveTask(title: title, description: "UserID: \(userId)")
//        // Обновляем локальный массив
//        tasks = storage.fetchTasks()
//        let task = storage.saveTask(
//            title: title,
//            description: "UserID: \(userId)"
//        )
//        
//        storage.saveTask(title: title, description: "UserID: \(userId)")
//        // Загружаем новые задачи с сортировкой по createdAt descending
//        tasks = storage.fetchTasks()
//
//        // добавляем в начало массива
//        tasks.insert(task, at: 0)
        
        // Сохраняем задачу в CoreData и получаем объект
        let task = storage.saveTask(title: title, description: description, isCompleted: isCompleted)

        // Загружаем все задачи с сортировкой по createdAt descending
        tasks = storage.fetchTasks()

        // Вставляем только что созданную задачу в начало массива
        // (если fetchTasks не возвращает её сверху автоматически)
        if !tasks.contains(task) {
            tasks.insert(task, at: 0)
        }
    }

    // MARK: - Удаление задачи
    func deleteTask(at index: Int) {
//        guard tasks.indices.contains(index) else { return }
//        let task = tasks[index]
//        storage.deleteTask(task)
//        tasks = storage.fetchTasks()
        
        guard tasks.indices.contains(index) else { return }
        let task = tasks[index]
        storage.deleteTask(task)
            
        // удаляем из массива
        tasks.remove(at: index)
    }

    // MARK: - Обновление статуса задачи
    func updateTaskCompleted(at index: Int, completed: Bool) {
        guard tasks.indices.contains(index) else { return }
        let task = tasks[index]
        storage.updateTask(task, completed: completed)
        tasks = storage.fetchTasks()
    }

    // MARK: - Поиск задач
    func searchTasks(keyword: String) -> [TaskEntity] {
        tasks.filter { $0.title?.lowercased().contains(keyword.lowercased()) ?? false }
    }
}
