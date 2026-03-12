//
//  FaceIDManager.swift
//  ToDoList
//
//  Created by Anton Tyurin on 12.03.2026.
//

import LocalAuthentication
import UIKit

class FaceIDManager {

    static let shared = FaceIDManager()
    private init() {}

    // Проверяем доступность Face ID
    func isFaceIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return context.biometryType == .faceID
        }
        return false
    }

    // Запускаем Face ID авторизацию
    func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        context.localizedCancelTitle = "Отмена"
        context.localizedFallbackTitle = "Пароль" // исправлено
            
        // Проверка доступности прямо перед вызовом
        guard isFaceIDAvailable() else {
            completion(false, nil)
            return
        }
            
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: "Авторизуйтесь через Face ID") { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
