//
//  TaskEntity+Extensions.swift
//  ToDoList
//
//  Created by Anton Tyurin on 13.03.2026.
//

import Foundation
import CoreData

extension TaskEntity {
    var notificationId: String {
        return "task-\(self.objectID.uriRepresentation().absoluteString)"
    }
}
