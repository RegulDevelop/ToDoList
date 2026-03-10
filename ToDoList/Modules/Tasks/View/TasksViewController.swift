//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let tableView = UITableView()
    private let viewModel = TasksViewModel()
    
    private let searchBar = UISearchBar()
    private var filteredTasks: [TaskEntity] = []
    private var isSearching = false
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        label.textAlignment = .left
        return label
    }()
    
    // Нижний фон
//    private let footerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.systemGray6
//        view.layer.cornerRadius = 20
//        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // скругление сверху
//        //view.alpha = 0.8
//        return view
//    }()

    // Кнопка добавления задачи
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    // Количество задач
    private let tasksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    // Фон для количества задач
    private let tasksCountBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 14
        view.alpha = 0.7
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
//        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        
        setupHeader()
        setupSearchBar()
        setupTableView()
        setupFooter()
        
        // Добавляем тап для закрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // чтобы TableView и другие элементы тоже работали при тапе
        view.addGestureRecognizer(tapGesture)

        // Загружаем задачи
        viewModel.loadTasks { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateTasksCount()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Настройки поиска
    // Когда меняется текст в поиске
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredTasks = viewModel.tasks.filter {
                $0.title?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        tableView.reloadData()
    }

    // Нажатие на кнопку "Отмена"
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder() // скрываем клавиатуру
        tableView.reloadData()
    }

    // Нажатие "Search" на клавиатуре
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // скрываем клавиатуру
    }
    
    // MARK: - Метод для скрытия клавиатуры
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Заголовок
    private func setupHeader() {
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Настройка SearchBar
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск задач"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Настройка TableView
    private func setupTableView() {
        tableView.dragInteractionEnabled = true // Включаем drag
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = 80
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Footer
    private func setupFooter() {
//        view.addSubview(footerView)
//        footerView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            footerView.heightAnchor.constraint(equalToConstant: 80)
//        ])

//        footerView.addSubview(addButton)
//        footerView.addSubview(tasksCountBackground)
        view.addSubview(addButton)
        view.addSubview(tasksCountBackground)
        tasksCountBackground.addSubview(tasksCountLabel)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountBackground.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
//            addButton.centerYAnchor.constraint(equalToSystemSpacingBelow: footerView.centerYAnchor, multiplier: 1),
//            addButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            // Фон для tasksCountLabel
//            tasksCountBackground.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
//            tasksCountBackground.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            tasksCountBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tasksCountBackground.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            tasksCountBackground.heightAnchor.constraint(equalToConstant: 40),
            tasksCountBackground.widthAnchor.constraint(equalToConstant: 180),

            tasksCountLabel.centerXAnchor.constraint(equalTo: tasksCountBackground.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: tasksCountBackground.centerYAnchor)
        ])

        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
       }
    
    private func updateTasksCount() {
        let count = viewModel.tasks.count
        tasksCountLabel.text = "Всего задач: \(count)"
    }



    // MARK: - Добавление новой задачи
    @objc private func addTaskTapped() {
        let alert = UIAlertController(title: "Новая задача", message: "Введите название задачи", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Название задачи"
        }
        alert.addTextField { textField in
            textField.placeholder = "UserID"
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let title = alert.textFields?[0].text ?? "Без названия"
            let userId = Int(alert.textFields?[1].text ?? "0") ?? 0
            self.viewModel.addTask(title: title, userId: userId)
            self.tableView.reloadData()
            self.updateTasksCount()
            self.tableView.reloadData()
                self.updateTasksCount()
                if self.isSearching {
                    self.searchBar.text = ""
                    self.isSearching = false
                }
        }))

        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        viewModel.tasks.count
        return isSearching ? filteredTasks.count : viewModel.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        // let task = viewModel.tasks[indexPath.row]
        let task = isSearching ? filteredTasks[indexPath.row] : viewModel.tasks[indexPath.row]
        cell.configure(with: task)
        //cell.showsReorderControl = true
        return cell
    }

    // MARK: - UITableViewDelegate

    // Удаление свайпом
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        if editingStyle == .delete {
//            viewModel.deleteTask(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            updateTasksCount()
//        }
        
//        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
//            guard let self = self else { return }
//
//            // Удаляем задачу из ViewModel
//            self.viewModel.deleteTask(at: indexPath.row)
//                
//            // Удаляем строку из таблицы с анимацией
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//                
//            // Обновляем счетчик задач
//            self.updateTasksCount()
//                
//            completionHandler(true)
        
        
//        }
//            
//        deleteAction.backgroundColor = .systemRed
//        deleteAction.image = UIImage(systemName: "trash.fill")
//            
//        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
//        configuration.performsFirstActionWithFullSwipe = true
//        return configuration
        
        
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
                guard let self = self else { return }
                self.viewModel.deleteTask(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.updateTasksCount()
                completionHandler(true)
            }

            deleteAction.backgroundColor = .systemRed
            deleteAction.image = UIImage(systemName: "trash.fill")
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // Отмечаем/снимаем задачу как выполненную
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.tasks[indexPath.row]
        viewModel.updateTaskCompleted(at: indexPath.row, completed: !task.isCompleted)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Разрешаем редактирование ячеек (чтобы включить drag & drop)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Обновляем модель при перемещении
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
//        // Получаем задачу, которую перемещаем
//        let movedTask = viewModel.tasks.remove(at: sourceIndexPath.row)
//        
//        // Вставляем её на новое место
//        viewModel.tasks.insert(movedTask, at: destinationIndexPath.row)
//        
//        // Обновляем CoreData порядок (опционально, если хочешь сохранять)
//        viewModel.updateTasksOrder()
//        
//        // Обновляем количество задач или UI, если нужно
//        updateTasksCount()
        
        // 1. Перемещаем элемент в массиве
        let movedTask = viewModel.tasks.remove(at: sourceIndexPath.row)
        viewModel.tasks.insert(movedTask, at: destinationIndexPath.row)
            
        // 2. Обновляем порядок всех задач
        for (index, task) in viewModel.tasks.enumerated() {
            task.order = Int64(index)
        }
            
        // 3. Сохраняем изменения в CoreData
        CoreDataManager.shared.saveContext()
            
        // 4. Обновляем UI, если нужно
        updateTasksCount()
    }
}

extension TasksViewController: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView,
                       itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem] {
            
        let task = viewModel.tasks[indexPath.row]
        let titleString: NSString = task.title as NSString? ?? "" // <-- явный тип
        let itemProvider = NSItemProvider(object: titleString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = task
        return [dragItem]
    }
}

extension TasksViewController: UITableViewDropDelegate {

    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        coordinator.items.forEach { dropItem in
            if let task = dropItem.dragItem.localObject as? TaskEntity {
                
                // Удаляем с исходного места
                if let sourceIndex = viewModel.tasks.firstIndex(of: task) {
                    viewModel.tasks.remove(at: sourceIndex)
                }
                
                // Вставляем на новое место
                viewModel.tasks.insert(task, at: destinationIndexPath.row)
                
                // Обновляем order
                for (index, task) in viewModel.tasks.enumerated() {
                    task.order = Int64(index)
                }
                
                CoreDataManager.shared.saveContext()
                
                tableView.reloadData()
                updateTasksCount()
            }
        }
    }

    // Разрешаем перемещение только внутри таблицы
    func tableView(_ tableView: UITableView,
                   canHandle session: UIDropSession) -> Bool {
        return session.localDragSession != nil
    }
}
