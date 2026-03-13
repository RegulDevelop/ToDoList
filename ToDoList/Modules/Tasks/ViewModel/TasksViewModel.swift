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

               networkService.fetchTodos { [weak self] result in
                   guard let self = self else { return }

                   switch result {

                   case .success(let todos):

                       self.storage.saveTodosFromAPI(todos)

                       UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")

                   case .failure(let error):

                       print("Ошибка загрузки JSON:", error)

                   }

                   self.tasks = self.storage.fetchTasks()
                   completion()
               }

           } else {

               tasks = storage.fetchTasks()
               completion()

           }
    }

    // MARK: - Добавление новой задачи
    func addTask(title: String, userId: Int, description: String, isCompleted: Bool, isImportant: Bool) {
        
        // Сохраняем задачу в CoreData и получаем объект
        let task = storage.saveTask(title: title, description: description, isCompleted: isCompleted, isImportant: isImportant)

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
            tasks[index] = task
    }

    // MARK: - Поиск задач
    func searchTasks(keyword: String) -> [TaskEntity] {
        tasks.filter { $0.title?.lowercased().contains(keyword.lowercased()) ?? false }
    }
}
