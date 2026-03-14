//
//  HeaderButtonsManagerDelegate.swift
//  ToDoList
//
//  Created by Anton Tyurin on 12.03.2026.
//

import UIKit

// Уведомление о смене языка
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

protocol HeaderButtonsManagerDelegate: AnyObject {
    func didUpdateButtonStates()
}

class HeaderButtonsManager {
    
    static let shared = HeaderButtonsManager()
    private init() {
        // Устанавливаем дефолтный язык при первом запуске
        if UserDefaults.standard.string(forKey: "selectedLanguage") == nil {
            UserDefaults.standard.set("en", forKey: "selectedLanguage")
        }
    }
    
    weak var delegate: HeaderButtonsManagerDelegate?
    
    // MARK: - Состояния кнопок
    var isFaceIDEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isFaceIDEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFaceIDEnabled")
            delegate?.didUpdateButtonStates()
        }
    }
    
    var isDoneOnlyEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isDoneOnlyEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDoneOnlyEnabled")
            delegate?.didUpdateButtonStates()
        }
    }
    
    var isNotDoneOnlyEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isNotDoneOnlyEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isNotDoneOnlyEnabled")
            delegate?.didUpdateButtonStates()
        }
    }
    
    // MARK: - Язык
    var selectedLanguage: String {
        get { UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    func setLanguage(_ code: String) {
        selectedLanguage = code
    }
    
    // MARK: - Методы переключения
    func toggleFaceID() { isFaceIDEnabled.toggle() }
    
    func toggleDoneOnly() {
        if !isDoneOnlyEnabled { isNotDoneOnlyEnabled = false }
        isDoneOnlyEnabled.toggle()
        delegate?.didUpdateButtonStates()
    }
    
    func toggleNotDoneOnly() {
        if !isNotDoneOnlyEnabled { isDoneOnlyEnabled = false }
        isNotDoneOnlyEnabled.toggle()
        delegate?.didUpdateButtonStates()
    }
}

