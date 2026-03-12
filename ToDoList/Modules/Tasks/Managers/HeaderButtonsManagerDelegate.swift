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
    func toggleDoneOnly() { isDoneOnlyEnabled.toggle() }
    func toggleNotDoneOnly() { isNotDoneOnlyEnabled.toggle() }
    func setLanguage(_ code: String) { selectedLanguage = code }
}
