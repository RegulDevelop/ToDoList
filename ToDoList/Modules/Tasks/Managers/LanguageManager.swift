//
//  LanguageManager.swift
//  ToDoList
//
//  Created by Anton Tyurin on 14.03.2026.
//

import UIKit

final class LanguageManager {
    static let shared = LanguageManager()
    private init() {}

    // Список поддерживаемых языков
    struct AppLanguage {
        let code: String   // "ru", "en", "es" и т.д.
        let displayName: String // "Русский", "English", "Español"
    }

    let languages: [AppLanguage] = [
        .init(code: "ru", displayName: "Русский"),
        .init(code: "en", displayName: "English")
        // Добавляем новые языки сюда
    ]

    // Возвращает тексты по коду языка
    func localizedText(for key: String) -> String {
        let lang = HeaderButtonsManager.shared.selectedLanguage

        switch key {
        case "tasksTitle":
            switch lang {
            case "ru": return "Задачи"
            case "en": return "Tasks"
            default: return "Tasks"
            }
        case "searchPlaceholder":
            switch lang {
            case "ru": return "Поиск задач"
            case "en": return "Search tasks"
            default: return "Search tasks"
            }
        case "tasksCountDone":
            switch lang {
            case "ru": return "Завершено задач"
            case "en": return "Completed tasks"
            default: return "Completed tasks"
            }
        case "tasksCountNotDone":
            switch lang {
            case "ru": return "Не завершено задач"
            case "en": return "Incomplete tasks"
            default: return "Incomplete tasks"
            }
        case "tasksCountAll":
            switch lang {
            case "ru": return "Всего задач"
            case "en": return "Total tasks"
            default: return "Total tasks"
            }
        default:
            return key
        }
    }
}
