//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import UIKit
import LocalAuthentication

class TasksViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate,
                            UISearchBarDelegate {

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
    
    // Кнопка выбора языка
    private let headerLanguageButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "globe", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    // Кнопка Face-Id
    private let headerFaceIdButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "faceid", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    // Кнопка сортировки только завершенные задачи
    private let headerDoneOnlyButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "checkmark.square", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    // Кнопка сортировки только не завершенные задачи
    private let headerNotDoneOnlyButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "xmark.square", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        return button
    }()

    // Кнопка добавления задачи
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    // Количество задач
    private let tasksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // Фон для количества задач
    private let tasksCountBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow
        view.layer.cornerRadius = 14
        //view.alpha = 0.7
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
//        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.keyboardDismissMode = .onDrag
        
        setupHeader()
        setupSearchBar()
        setupTableView()
        setupFooter()
        setupHeaderButtonActions()
        
        updateHeaderButtonUI()
        
        view.addSubview(authOverlayView)
            authOverlayView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                authOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
                authOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                authOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                authOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
        // Авто-авторизация Face ID
            if HeaderButtonsManager.shared.isFaceIDEnabled {
                FaceIDManager.shared.authenticateUser { [weak self] success, error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if success {
                            // Скрываем overlay только после успешной проверки
                            self.authOverlayView.removeFromSuperview()
                            
                            // Загружаем задачи
                            self.viewModel.loadTasks {
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.updateTasksCount()
                                }
                            }
                        } else {
                            // Если Face ID не прошёл — оставляем overlay и показываем alert
                            self.showFaceIDFailedAlert()
                        }
                    }
                }
            } else {
                // Face ID выключен — сразу скрываем overlay и показываем задачи
                authOverlayView.removeFromSuperview()
                viewModel.loadTasks { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.updateTasksCount()
                    }
                }
            }
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
        // Добавляем заголовок и кнопки
        [headerLabel, headerLanguageButton, headerFaceIdButton, headerDoneOnlyButton, headerNotDoneOnlyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        // Создаем горизонтальный стек только для кнопок
        let headerButtonsStack = UIStackView(arrangedSubviews: [
            headerFaceIdButton,
            headerDoneOnlyButton,
            headerNotDoneOnlyButton,
            headerLanguageButton
        ])
        headerButtonsStack.axis = .horizontal
        headerButtonsStack.spacing = 12
        headerButtonsStack.alignment = .center
        headerButtonsStack.distribution = .equalSpacing
        headerButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerButtonsStack)

        NSLayoutConstraint.activate([
            // Заголовок слева
            headerLabel.centerYAnchor.constraint(equalTo: headerButtonsStack.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Стек кнопок справа
            headerButtonsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerButtonsStack.heightAnchor.constraint(equalToConstant: 40)
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

        view.addSubview(addButton)
        view.addSubview(tasksCountBackground)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        tasksCountBackground.isUserInteractionEnabled = true
        tasksCountBackground.addGestureRecognizer(tapGesture)
        
        tasksCountBackground.addSubview(tasksCountLabel)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountBackground.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            tasksCountBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tasksCountBackground.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            tasksCountBackground.heightAnchor.constraint(equalToConstant: 40),
            tasksCountBackground.widthAnchor.constraint(equalToConstant: 180),

            tasksCountLabel.centerXAnchor.constraint(equalTo: tasksCountBackground.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: tasksCountBackground.centerYAnchor)
        ])

        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
       }
    
    // Настраиваем действия кнопок Footer
    private func setupHeaderButtonActions() {
        headerFaceIdButton.addTarget(self, action: #selector(faceIDTapped), for: .touchUpInside)
//        headerDoneOnlyButton.addTarget(self, action: #selector(doneOnlyTapped), for: .touchUpInside)
//        headerNotDoneOnlyButton.addTarget(self, action: #selector(notDoneOnlyTapped), for: .touchUpInside)
//        headerLanguageButton.addTarget(self, action: #selector(languageTapped), for: .touchUpInside)
    }
    
    // faceID
    @objc private func faceIDTapped() {
        HeaderButtonsManager.shared.toggleFaceID()
            updateHeaderButtonUI()
            
            // Проверяем симулятор
            #if targetEnvironment(simulator)
            print("Face ID недоступен на симуляторе")
            HeaderButtonsManager.shared.isFaceIDEnabled = false
            updateHeaderButtonUI()
            return
            #endif
            
            // Проверяем доступность Face ID
            guard FaceIDManager.shared.isFaceIDAvailable() else {
                let alert = UIAlertController(title: "Ошибка", message: "Face ID недоступен на этом устройстве.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                present(alert, animated: true)
                HeaderButtonsManager.shared.isFaceIDEnabled = false
                updateHeaderButtonUI()
                return
            }
            
            // Запуск Face ID
            FaceIDManager.shared.authenticateUser { success, error in
                if success {
                    print("Face ID прошёл успешно")
                } else {
                    print("Face ID не прошёл или отменён")
                    HeaderButtonsManager.shared.isFaceIDEnabled = false
                    self.updateHeaderButtonUI()
                }
            }
    }
    
    // Скрывает экран пока не прошла проверку face id
    private let authOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.alpha = 1.0
        return view
    }()
    
    // Показываем alert при неудаче face id
    private func showFaceIDFailedAlert() {
        let alert = UIAlertController(title: "Ошибка Face ID",
                                      message: "Не удалось пройти аутентификацию",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .destructive) { _ in
            exit(0) // можно закрыть приложение
        })
        present(alert, animated: true)
    }

//    // doneOnly
//    @objc private func doneOnlyTapped() {
//        HeaderButtonsManager.shared.toggleDoneOnly()
//        filterTasks()
//        updateHeaderButtonUI()
//    }
//
//    // notDoneOnly
//    @objc private func notDoneOnlyTapped() {
//        HeaderButtonsManager.shared.toggleNotDoneOnly()
//        filterTasks()
//        updateHeaderButtonUI()
//    }
//
//    // languageTapped
//    @objc private func languageTapped() {
//        // Пример переключения языка
//        let newLang = HeaderButtonsManager.shared.selectedLanguage == "en" ? "ru" : "en"
//        HeaderButtonsManager.shared.setLanguage(newLang)
//        updateHeaderButtonUI()
//    }
    
    // Обновление цвета кнопок по состоянию
    private func updateHeaderButtonUI() {
        headerFaceIdButton.tintColor = HeaderButtonsManager.shared.isFaceIDEnabled ? .systemYellow : .systemGray
        headerDoneOnlyButton.tintColor = HeaderButtonsManager.shared.isDoneOnlyEnabled ? .systemYellow : .systemGray
        headerNotDoneOnlyButton.tintColor = HeaderButtonsManager.shared.isNotDoneOnlyEnabled ? .systemYellow : .systemGray
        headerLanguageButton.tintColor = HeaderButtonsManager.shared.selectedLanguage == "en" ? .systemGray : .systemYellow
    }
    
    // Фильтрация задач для Done/NotDone
    private func filterTasks() {
        var tasks = viewModel.tasks
        
        if HeaderButtonsManager.shared.isDoneOnlyEnabled {
            tasks = tasks.filter { $0.isCompleted }
        }
        
        if HeaderButtonsManager.shared.isNotDoneOnlyEnabled {
            tasks = tasks.filter { !$0.isCompleted }
        }
        
        filteredTasks = tasks
        tableView.reloadData()
    }
    
    private func updateTasksCount() {
        let count = viewModel.tasks.count
        tasksCountLabel.text = "Всего задач: \(count)"
    }
    
    // Скрол таблицы при нажатии на tasksCountBackground
    @objc private func scrollToTop() {
        guard !viewModel.tasks.isEmpty else { return }
        let topIndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
    }


    // MARK: - Добавление новой задачи
    @objc private func addTaskTapped() {
        
        let addVC = AddTaskViewController()
            addVC.delegate = self

            if let sheet = addVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }

            present(addVC, animated: true)
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
        cell.selectionStyle = .none
        cell.configure(with: task)
        //cell.showsReorderControl = true
        return cell
    }

    // MARK: - UITableViewDelegate

    // Удаление свайпом
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = viewModel.tasks[indexPath.row]
            let completeAction = UIContextualAction(
                style: .normal,
                title: task.isCompleted ? "Снять" : "Выполнено"
            ) { [weak self] _, _, completionHandler in
                guard let self = self else { return }
                self.viewModel.updateTaskCompleted(at: indexPath.row, completed: !task.isCompleted)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            completeAction.backgroundColor = .systemYellow
            completeAction.image = UIImage(systemName: task.isCompleted ? "xmark.circle" : "checkmark.circle")
            
            let config = UISwipeActionsConfiguration(actions: [completeAction])
            config.performsFirstActionWithFullSwipe = true
            return config
    }
    
    // Свайп влево → удаление задачи
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.viewModel.deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTasksCount()
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    
    }

    // Отмечаем/снимаем задачу как выполненную
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Выбираем задачу в зависимости от поиска
        let task = isSearching ? filteredTasks[indexPath.row] : viewModel.tasks[indexPath.row]
            
        let addVC = AddTaskViewController()
        addVC.isEditingTask = true
        addVC.existingTask = task
        addVC.showCompletedSwitch = true
        addVC.showShareButton = true
        addVC.delegate = self

        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(addVC, animated: true)
    }
    
    // Разрешаем редактирование ячеек (чтобы включить drag & drop)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Обновляем модель при перемещении
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard sourceIndexPath != destinationIndexPath else { return }

        let movedTask = viewModel.tasks.remove(at: sourceIndexPath.row)
        viewModel.tasks.insert(movedTask, at: destinationIndexPath.row)
            
        // Обновляем порядок
        for (index, task) in viewModel.tasks.enumerated() {
            task.order = Int64(index)
        }
            
        CoreDataManager.shared.saveContext()
            
        // Не нужно reloadData, UIKit сам обновляет позицию ячейки
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

extension TasksViewController: AddTaskViewControllerDelegate {

    func didAddTask(_ task: TaskEntity) {
        if let index = viewModel.tasks.firstIndex(of: task) {
            // Если задача уже есть → редактируем
            viewModel.tasks[index] = task
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            // Добавление новой
            viewModel.tasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        updateTasksCount()
        
    }
    
}

extension TasksViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Если тапнули по TableViewCell, SearchBar или кнопке — жест не срабатывает
        if let view = touch.view, view is UITableViewCell || view is UIButton || view is UISearchBar {
            return false
        }
        return true
    }
}
