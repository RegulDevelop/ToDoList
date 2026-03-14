//
//  AddTaskViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import UIKit
import CoreData
import UserNotifications

protocol AddTaskViewControllerDelegate: AnyObject {
    func didAddTask(_ task: TaskEntity)
}

class AddTaskViewController: UIViewController, UITextViewDelegate {
    
    var existingTask: TaskEntity?
    var isEditingTask = false
    var showCompletedSwitch = false
    var showShareButton = false
    
    weak var delegate: AddTaskViewControllerDelegate?
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = .systemYellow
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let tl = UILabel()
        tl.text = "Задача:"
        tl.textColor = .systemYellow
        tl.font = .systemFont(ofSize: 18, weight: .bold)
        return tl
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название задачи"
        tf.layer.cornerRadius = 20
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.setLeftPaddingPoints(10)
        return tf
    }()
    
    private let descriptionLabel: UILabel = {
        let dl = UILabel()
        dl.text = "Описание:"
        dl.textColor = .systemYellow
        dl.font = .systemFont(ofSize: 18, weight: .bold)
        return dl
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .black
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 20
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return tv
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Описание задачи..."
        label.textColor = .systemGray3
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let remindLabel: UILabel = {
        let label = UILabel()
        label.text = "Напоминание:"
        label.textColor = .systemYellow
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let remindTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Время напоминания"
        tf.layer.cornerRadius = 20
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.setLeftPaddingPoints(10)
        return tf
    }()
    
    private let remindDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU") // <-- русский язык
        picker.minimumDate = Date() // нельзя выбрать прошедшую дату
        picker.tintColor = .systemYellow
        return picker
    }()
    
    private let completedSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = .systemYellow
        return sw
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Отметить как выполнено:"
        label.textColor = .systemYellow
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let importantSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = .systemYellow
        return sw
    }()
    
    private let importantLabel: UILabel = {
        let label = UILabel()
        label.text = "Отметить как важное:"
        label.textColor = .systemYellow
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 22)
        btn.backgroundColor = .systemYellow
        btn.tintColor = .white
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Отмена", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 22)
        btn.backgroundColor = .systemYellow
        btn.tintColor = .white
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        descriptionTextView.delegate = self
        setupViews()
        setupRemindPicker()
        
        // Заполняем поля, если редактируем
        if let task = existingTask {
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
            completedSwitch.isOn = task.isCompleted
            importantSwitch.isOn = task.isImportant
        }
        
        if isEditingTask {
            saveButton.setTitle("Изменить", for: .normal)
        } else {
            saveButton.setTitle("Добавить", for: .normal)
        }
        
        completedSwitch.isHidden = !showCompletedSwitch
        completedLabel.isHidden = !showCompletedSwitch
        
        shareButton.isHidden = !showShareButton
        
        // Добавляем распознаватель жестов
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // чтобы не блокировать другие нажатия
        view.addGestureRecognizer(tapGesture)
    }
    
    // Метод для скрытия клавиатуры
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupViews() {
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        [titleLabel, titleTextField, descriptionLabel, descriptionTextView, descriptionPlaceholder, completedLabel, completedSwitch, shareButton, cancelButton, saveButton, remindLabel, remindTextField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // MARK: - Верхние поля
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 10),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 15),
            
            remindLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            remindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            remindTextField.topAnchor.constraint(equalTo: remindLabel.bottomAnchor, constant: 8),
            remindTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            remindTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            remindTextField.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        // Switch stack
        let switchStack = UIStackView(arrangedSubviews: [])
        switchStack.axis = .horizontal
        switchStack.spacing = 10
        switchStack.alignment = .center
        switchStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchStack)
        if showCompletedSwitch {
            switchStack.addArrangedSubview(completedLabel)
            switchStack.addArrangedSubview(completedSwitch)
        }
        
        switchStack.isHidden = !showCompletedSwitch
        
        let switchImportantStack = UIStackView(arrangedSubviews: [])
        switchImportantStack.axis = .horizontal
        switchImportantStack.spacing = 10
        switchImportantStack.alignment = .center
        switchImportantStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchImportantStack)
        switchImportantStack.addArrangedSubview(importantLabel)
        switchImportantStack.addArrangedSubview(importantSwitch)
        
        // Buttons stack
        let buttonsStack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 40
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)
        [saveButton, cancelButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 150).isActive = true
        }
        
        // ✅ Разные отступы для добавления и редактирования
        let switchTopOffset: CGFloat = isEditingTask ? 20 : 20
        let switchImportantTopOffset: CGFloat = isEditingTask ? 50 : 5
        let buttonsTopOffset: CGFloat = isEditingTask ? 40 : 40
        
        NSLayoutConstraint.activate([
            switchStack.topAnchor.constraint(equalTo: remindTextField.bottomAnchor, constant: switchTopOffset),
            switchStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            switchStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            switchImportantStack.topAnchor.constraint(equalTo: switchStack.topAnchor, constant: switchImportantTopOffset),
            switchImportantStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            switchImportantStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            buttonsStack.topAnchor.constraint(equalTo: switchImportantStack.bottomAnchor, constant: buttonsTopOffset),
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    // Напоминание
    private func setupRemindPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = .systemBackground // фон тулбара (можно светлый)
        toolbar.tintColor = .systemYellow       // цвет кнопок на тулбаре
        
        // Кнопка Done с галочкой
        let doneButton = UIBarButtonItem(title: "✓", style: .prominent, target: self, action: #selector(donePickingDate))
        doneButton.tintColor = .systemYellow
        toolbar.setItems([doneButton], animated: true)
        
        remindTextField.inputAccessoryView = toolbar
        remindTextField.inputView = remindDatePicker
    }
    
    @objc private func donePickingDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        remindTextField.text = dateFormatter.string(from: remindDatePicker.date)
        remindTextField.resignFirstResponder()
    }
    
    @objc private func shareTapped() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let description = descriptionTextView.text ?? ""
        let date = Date()
        
        // Форматируем дату в строку
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        
        // Формируем текст для шаринга
        let shareText = """
        Задача: \(title)
        Описание: \(description)
        Дата: \(dateString)
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view // для iPad
        present(activityVC, animated: true)
    }
    
    @objc private func saveTapped() {
        
        //        guard let title = titleTextField.text, !title.isEmpty else { return }
        //        let description = descriptionTextView.text ?? ""
        //        let isCompleted = completedSwitch.isOn
        //        let isImportant = importantSwitch.isOn
        //
        //        if isEditingTask, let task = existingTask {
        //            // Редактируем существующую задачу
        //            task.title = title
        //            task.taskDescription = description
        //            task.isCompleted = isCompleted
        //            task.isImportant = isImportant
        //            CoreDataManager.shared.saveContext()
        //            delegate?.didAddTask(task)
        //        } else {
        //            // Создаём новую задачу сверху
        //            let newTask = TaskEntity(context: CoreDataManager.shared.context)
        //            newTask.title = title
        //            newTask.taskDescription = description
        //            newTask.isCompleted = isCompleted
        //            newTask.isImportant = isImportant
        //            newTask.createdAt = Date()
        //            newTask.remindAt = remindDatePicker.date
        //            newTask.order = 0  // <-- новая задача в начале
        //
        //            // Смещаем все существующие задачи вниз
        //            let tasks = CoreDataManager.shared.fetchTasks()
        //            for task in tasks {
        //                task.order += 1
        //            }
        //
        //            CoreDataManager.shared.saveContext()
        //            delegate?.didAddTask(newTask)
        //        }
        //
        //        dismiss(animated: true)
        
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let description = descriptionTextView.text ?? ""
        let isCompleted = completedSwitch.isOn
        let isImportant = importantSwitch.isOn
        let remindDate: Date?

        if remindTextField.text?.isEmpty == false {
            remindDate = remindDatePicker.date
        } else if isEditingTask {
            remindDate = existingTask?.remindAt
        } else {
            remindDate = nil
        }
        
        if isEditingTask, let task = existingTask {
            // Удаляем старое уведомление
            CoreDataManager.shared.removeNotification(for: task)
            
            // Обновляем данные
            task.title = title
            task.taskDescription = description
            task.isCompleted = isCompleted
            task.isImportant = isImportant
            task.remindAt = remindDate
            
            CoreDataManager.shared.saveContext()
            
            // Планируем новое уведомление, если задача не выполнена
            if let _ = remindDate, !isCompleted {
                CoreDataManager.shared.scheduleNotification(for: task)
            } else {
                CoreDataManager.shared.removeNotification(for: task)
            }
            
            delegate?.didAddTask(task)
        } else {
            // Новая задача
            let newTask = TaskEntity(context: CoreDataManager.shared.context)
            newTask.title = title
            newTask.taskDescription = description
            newTask.isCompleted = isCompleted
            newTask.isImportant = isImportant
            newTask.createdAt = Date()
            newTask.remindAt = remindDate
            newTask.order = 0
            
            // Сдвигаем остальные задачи вниз
            let tasks = CoreDataManager.shared.fetchTasks()
            for task in tasks {
                task.order += 1
            }
            
            CoreDataManager.shared.saveContext()
            
            // Планируем уведомление
            if remindDate != nil && !isCompleted {
                CoreDataManager.shared.scheduleNotification(for: newTask)
            }
            
            delegate?.didAddTask(newTask)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    // Скрываем placeholder TextView
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
