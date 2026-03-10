//
//  TodoResponse.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

struct TodoResponse: Decodable {
    
    let todos: [TodoDTO]
    let total: Int
    let skip: Int
    let limit: Int
    
}
