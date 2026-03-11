//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

final class NetworkService {
    
    // Загрузка из локального файла (если нужно)
    func fetchTodosFromFile(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "FileNotFound", code: 404)))
                }
                return
            }
            
            do {
                
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(decoded.todos))
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    // Загрузка из API
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NoData", code: 500)))
                }
                return
            }
            
            do {
                
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(decoded.todos))
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
            
        }.resume()
    }
}
