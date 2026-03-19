//
//  TodoDTO.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import Foundation

struct TodoDTO: Codable, @unchecked Sendable {
    
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
}
