//
//  NotificationManager.swift
//  ToDoList
//
//  Created by Anton Tyurin on 16.03.2026.
//

import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    // Запрос разрешения
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            }
        }
    }

    // Планирование уведомления
    func scheduleNotification(title: String, body: String, date: Date) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
