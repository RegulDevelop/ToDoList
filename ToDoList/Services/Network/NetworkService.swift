//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

import Foundation

final class NetworkService {
    
    // MARK: - Загрузка задач из API
    func fetchTodos() async throws -> [TodoDTO] {
        // Проверяем URL
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            throw NSError(domain: "InvalidURL", code: 400)
        }
        
        // Выполняем сетевой запрос
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Декодируем JSON
        let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
        return decoded.todos
    }
    
    // MARK: - Загрузка задач из локального файла
    func fetchTodosFromFile() async throws -> [TodoDTO] {
        // Находим файл в bundle
        guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
            throw NSError(domain: "FileNotFound", code: 404)
        }
        
        // Загружаем данные
        let data = try Data(contentsOf: url)
        
        // Декодируем JSON
        let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
        return decoded.todos
    }
    
    func fetchTodosWithCompletion(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        Task {
            do {
                let todos = try await fetchTodos()
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

    // Загрузка из API
func fetchTodosWithCompletion(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
    guard let url = URL(string: "https://dummyjson.com/todos") else {
        completion(.failure(NSError(domain: "InvalidURL", code: 400)))
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }

        guard let data = data else {
            DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: 500))) }
            return
        }

        Task { @MainActor in
            do {
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(.success(decoded.todos))
            } catch {
                completion(.failure(error))
            }
        }
    }.resume()
}

