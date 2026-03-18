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
    
    struct AppLanguage {
        let code: String
        let displayName: String
    }
    
    let languages: [AppLanguage] = [
        .init(code: "ru", displayName: "Русский"),
        .init(code: "en", displayName: "English")
    ]
    
    // ❗ Вот здесь должен быть translations
    private let translations: [String: [String: String]] = [
        
        "tasksTitle": [
            "ru": "Задачи",
            "en": "Tasks"
        ],
        
        "searchPlaceholder": [
            "ru": "Поиск задач",
            "en": "Search tasks"
        ],
        
        "speechPlaceholder": [
            "ru": "Говорите...",
            "en": "Speak..."
        ],
        
        "doneButton": [
            "ru": "Выполнено",
            "en": "Done"
        ],
        "undoneButton": [
            "ru": "Снять",
            "en": "Undo"
        ],
        "deleteButton": [
            "ru": "Удалить",
            "en": "Delete"
        ],
        
        "tasksCountDone": [
            "ru": "Завершено задач",
            "en": "Completed tasks"
        ],
        
        "tasksCountNotDone": [
            "ru": "Не завершено задач",
            "en": "Incomplete tasks"
        ],
        
        "tasksCountAll": [
            "ru": "Всего задач",
            "en": "Total tasks"
        ],
        
        "sortAZ": [
            "ru": "От А до Я",
            "en": "A → Z"
        ],
        
        "sortZA": [
            "ru": "От Я до А",
            "en": "Z → A"
        ],
        
        "sortDateUp": [
            "ru": "По дате ↑",
            "en": "Date ↑"
        ],
        
        "sortDateDown": [
            "ru": "По дате ↓",
            "en": "Date ↓"
        ],
        
        "sortCustom": [
            "ru": "Свой порядок",
            "en": "Custom order"
        ],
        
        "sortMenuTitle": [
            "ru": "Сортировка",
            "en": "Sort"
        ],
        
        "searchMenuTitle": [
            "ru": "Язык",
            "en": "Language"
        ],
        
        "errorMicrophoneAccessTitle": [
            "ru": "Ошибка",
            "en": "Error"
        ],
        "errorMicrophoneAccessMessage": [
            "ru": "Доступ к микрофону запрещён",
            "en": "Microphone access is denied"
        ],
        
        "faceIDReason": [
            "ru": "Авторизуйтесь с помощью Face ID",
            "en": "Authenticate with Face ID"
        ],
        
        "faceIDErrorTitle": [
            "ru": "Ошибка",
            "en": "Error"
        ],
        
        "faceIDUnavailableMessage": [
            "ru": "Ваше устройство не поддерживает Face ID или разрешение не предоставлено",
            "en": "Your device does not support Face ID or permission was denied"
        ],
        
        "faceIDFailedTitle": [
            "ru": "Ошибка Face ID",
            "en": "Face ID Error"
        ],
        
        "faceIDFailedMessage": [
            "ru": "Не удалось пройти аутентификацию",
            "en": "Authentication failed"
        ],
        
        "closeButton": [
            "ru": "Закрыть",
            "en": "Close"
        ],
        
        "passwordButton": [
            "ru": "Пароль",
            "en": "Password"
        ],
        
        "okButton": [
            "ru": "Ок",
            "en": "OK"
        ],
        
        // Сell
        "addedDateTitle": [
            "ru": "Добавлено",
            "en": "Added"
        ],
        
        "reminderTitle": [
            "ru": "Напоминание",
            "en": "Reminder"
        ],
        
        // AddTask
        
        "taskTitleLabel": [
            "ru": "Задача:",
            "en": "Task:"
        ],
        
        "taskNamePlaceholder": [
            "ru": "Название задачи",
            "en": "Task name"
        ],
        
        "descriptionLabel": [
            "ru": "Описание:",
            "en": "Description:"
        ],
        
        "descriptionPlaceholder": [
            "ru": "Описание задачи...",
            "en": "Task description..."
        ],
        
        "reminderLabel": [
            "ru": "Напоминание:",
            "en": "Reminder:"
        ],
        
        "reminderPlaceholder": [
            "ru": "Время напоминания",
            "en": "Reminder time"
        ],
        
        "completedSwitchLabel": [
            "ru": "Отметить как выполнено:",
            "en": "Mark as completed:"
        ],
        
        "importantSwitchLabel": [
            "ru": "Отметить как важное:",
            "en": "Mark as important:"
        ],
        
        "addButton": [
            "ru": "Добавить",
            "en": "Add"
        ],
        
        "editButton": [
            "ru": "Изменить",
            "en": "Edit"
        ],
        
        "cancelButton": [
            "ru": "Отмена",
            "en": "Cancel"
        ],
        
        "dateTitle": [
            "ru": "Дата:",
            "en": "Date:"
        ],
        
        "faceIDSettingsTitle": [
            "ru": "Face ID отключен",
            "en": "Face ID Disabled"
        ],

        "faceIDSettingsMessage": [
            "ru": "Чтобы использовать Face ID, включите доступ в настройках приложения",
            "en": "To use Face ID, please enable access in Settings"
        ],

        "openSettingsButton": [
            "ru": "Открыть настройки",
            "en": "Open Settings"
        ],
        
        "microphoneAccessTitle": [
            "ru": "Доступ к микрофону",
            "en": "Microphone Access"
        ],

        "microphoneAccessMessage": [
            "ru": "Разрешите доступ к микрофону в настройках приложения",
            "en": "Please enable microphone access in Settings"
        ],
        
        "notificationAccessTitle": [
            "ru": "Уведомления выключены",
            "en": "Notifications Disabled"
        ],

        "notificationAccessMessage": [
            "ru": "Разрешите уведомления в настройках, чтобы использовать напоминания",
            "en": "To set reminders, please enable notifications in Settings"
        ],
        
        "errorTitle": [
            "ru": "Ошибка",
            "en": "Error"
        ],

        "invalidDateMessage": [
            "ru": "Дата напоминания должна быть в будущем",
            "en": "Reminder date must be in the future"
        ]

    ]
    
    func localizedText(for key: String) -> String {
        
        let lang = HeaderButtonsManager.shared.selectedLanguage
        
        return translations[key]?[lang]
        ?? translations[key]?["en"]
        ?? key
    }
}



