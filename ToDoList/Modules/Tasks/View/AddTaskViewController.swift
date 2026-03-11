//
//  AddTaskViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import UIKit
import CoreData 

//protocol AddTaskViewControllerDelegate: AnyObject {
//    func didAddTask(title: String, description: String, isCompleted: Bool)
//}
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
        tl.font = .systemFont(ofSize: 22, weight: .bold)
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
        dl.font = .systemFont(ofSize: 22, weight: .bold)
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

    private let completedSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = .systemYellow
        return sw
    }()

    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнено:"
        label.textColor = .systemYellow
        label.font = .systemFont(ofSize: 22, weight: .bold)
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
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
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
        
        // Заполняем поля, если редактируем
        if let task = existingTask {
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
            completedSwitch.isOn = task.isCompleted
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
        
        // Добавляем subviews
        [titleTextField, descriptionTextView, completedLabel, completedSwitch, saveButton, cancelButton, titleLabel, descriptionLabel, descriptionPlaceholder, shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            shareButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 10),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 15),

            completedLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 75),
            completedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            completedSwitch.centerYAnchor.constraint(equalTo: completedLabel.centerYAnchor),
            completedSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            cancelButton.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 50),
            cancelButton.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.widthAnchor.constraint(equalToConstant: 150),
            
            saveButton.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            
        ])

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
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
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let description = descriptionTextView.text ?? ""
        let isCompleted = completedSwitch.isOn
//        delegate?.didAddTask(title: title, description: description, isCompleted: isCompleted)
//        dismiss(animated: true)
        
        if isEditingTask, let task = existingTask {
                // Редактируем существующую задачу
                task.title = title
                task.taskDescription = description
                task.isCompleted = isCompleted
                CoreDataManager.shared.saveContext()
                delegate?.didAddTask(task)
            } else {
                // Создаем новую задачу
                let newTask = TaskEntity(context: CoreDataManager.shared.context)
                newTask.title = title
                newTask.taskDescription = description
                newTask.isCompleted = isCompleted
                newTask.order = Int64(CoreDataManager.shared.fetchTasks().count)
                CoreDataManager.shared.saveContext()
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
