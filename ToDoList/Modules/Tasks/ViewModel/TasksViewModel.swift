//
//  TasksViewModel.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

class TasksViewModel {

    private let networkService = NetworkService()

    // Массив задач
    var tasks: [TodoDTO] = []

    // Загрузка задач
    func loadTasks(completion: @escaping () -> Void) {
        networkService.fetchTodosFromFile { [weak self] result in
            switch result {
            case .success(let todos):
                self?.tasks = todos
            case .failure(let error):
                print("Ошибка загрузки: \(error)")
            }
            completion()
        }
    }

    // Добавление задачи
    func addTask(_ task: TodoDTO) {
        tasks.append(task)
    }

    // Удаление задачи
    func deleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        tasks.remove(at: index)
    }

    // Поиск
    func searchTasks(keyword: String) -> [TodoDTO] {
        tasks.filter { $0.todo.lowercased().contains(keyword.lowercased()) }
    }
}
