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
                        self.storage.saveTask(title: todo.todo, description: "UserID: \(todo.userId)")
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
    func addTask(title: String, userId: Int) {
        // Сохраняем в CoreData
        storage.saveTask(title: title, description: "UserID: \(userId)")
        // Обновляем локальный массив
        tasks = storage.fetchTasks()
    }

    // MARK: - Удаление задачи
    func deleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        let task = tasks[index]
        storage.deleteTask(task)
        tasks = storage.fetchTasks()
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
