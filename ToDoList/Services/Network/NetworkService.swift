//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

final class NetworkService {

    func fetchTodosFromFile(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: nil)))
                }
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded.todos)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
