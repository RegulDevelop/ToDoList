//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

final class NetworkService {

    func fetchTodosFromFile(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {

        // Путь к файлу
        guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
            completion(.failure(NSError(domain: "FileNotFound", code: 404)))
            return
        }

        // Работаем в фоновом потоке
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: url)

                // JSONDecoder может ругаться в Swift 6, поэтому делаем Sendable
                let decoder = JSONDecoder()
                let response = try decoder.decode(TodoResponse.self, from: data)

                // Возврат результата на главный поток
                DispatchQueue.main.async {
                    completion(.success(response.todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
