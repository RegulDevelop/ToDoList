//
//  TodoResponse.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

struct TodoResponse: Codable, @unchecked Sendable {
    let todos: [TodoDTO]
}
