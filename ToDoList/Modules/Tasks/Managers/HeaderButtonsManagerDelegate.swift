//
//  HeaderButtonsManagerDelegate.swift
//  ToDoList
//
//  Created by Anton Tyurin on 12.03.2026.
//

import UIKit

protocol HeaderButtonsManagerDelegate: AnyObject {
    func didUpdateButtonStates()
}

class HeaderButtonsManager {
    
    static let shared = HeaderButtonsManager()
    
    private init() {}
    
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
    
    var selectedLanguage: String {
        get { UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
            delegate?.didUpdateButtonStates()
        }
    }
    
    // MARK: - Методы переключения
    func toggleFaceID() { isFaceIDEnabled.toggle() }
    
    // MARK: - Методы переключения
    func toggleDoneOnly() {
        if !isDoneOnlyEnabled {
            isNotDoneOnlyEnabled = false // отключаем противоположную
        }
        isDoneOnlyEnabled.toggle()
        delegate?.didUpdateButtonStates()
    }

    func toggleNotDoneOnly() {
        if !isNotDoneOnlyEnabled {
            isDoneOnlyEnabled = false // отключаем противоположную
        }
        isNotDoneOnlyEnabled.toggle()
        delegate?.didUpdateButtonStates()
    }
    
    func setLanguage(_ code: String) { selectedLanguage = code }
}
