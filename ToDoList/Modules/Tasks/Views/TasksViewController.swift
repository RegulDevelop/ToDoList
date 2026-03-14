//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import UIKit
import LocalAuthentication
import Speech
import AVFoundation
import UserNotifications

class TasksViewController: UIViewController,
                           UITableViewDataSource,
                           UITableViewDelegate,
                           UISearchBarDelegate {
    
    enum SortType: String {
        case dateDown
        case dateUp
        case az
        case za
        case customOrder
    }
    
    private var languageSelectionView: LanguageSelectionView!
    
    private let tableView = UITableView()
    private let viewModel = TasksViewModel()
    private var currentSort: SortType = .dateDown
    
    private let searchBar = UISearchBar()
    private var filteredTasks: [TaskEntity] = []
    private var isSearching = false
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isVoiceSearching = false
    
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
        let image = UIImage(systemName: "circle.square", withConfiguration: config)
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
    
    // Кнопка сортировки
    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "list.bullet.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    // Количество задач
    private let tasksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        // Настройка меню языка
        setupLanguageButtonMenu()
        
        updateHeaderButtonUI()
        
        applyLanguage()
        
        view.addSubview(authOverlayView)
        authOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            authOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            authOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            authOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Разрешение на уведомления получено")
                } else {
                    print("Уведомления запрещены")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTaskUpdate(_:)),
                                               name: .taskUpdated,
                                               object: nil)
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let visibleIndexPaths = self.tableView.indexPathsForVisibleRows else { return }
            self.tableView.reloadRows(at: visibleIndexPaths, with: .none)
        }
        
        // Загрузка сохраненной сортировки
        if let savedSort = UserDefaults.standard.string(forKey: "tasksSort"),
           let sort = SortType(rawValue: savedSort) {
            currentSort = sort
        }
        
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
                                //                                    self.tableView.reloadData()
                                //                                    self.updateTasksCount()
                                self.applySorting()
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
        }
        
        viewModel.loadTasks { [weak self] in
            DispatchQueue.main.async {
                self?.applySorting()   // ← применяем сохранённый фильтр
                self?.tableView.dragInteractionEnabled = self?.currentSort == .customOrder
                self?.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyLanguage),
            name: .languageChanged,
            object: nil
        )
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        filterTasks()
    }
    
    @objc private func handleTaskUpdate(_ notification: Notification) {
        guard let task = notification.object as? TaskEntity else { return }
        
        if let index = filteredTasks.firstIndex(of: task) {
            let indexPath = IndexPath(row: index, section: 0)
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Добавление языка
    
    @objc func applyLanguage() {
        let langCode = HeaderButtonsManager.shared.selectedLanguage

            switch langCode {
            case "ru":
                headerLabel.text = "Задачи"
                searchBar.placeholder = "Поиск задач"
            case "en":
                headerLabel.text = "Tasks"
                searchBar.placeholder = "Search tasks"
            default:
                break
            }

            updateTasksCount()
            tableView.reloadData() // если текст в ячейках зависит от языка
    }
    
//    private func applyLanguage() {
//        headerLabel.text = LanguageManager.shared.localizedText(for: "tasksTitle")
//        searchBar.placeholder = LanguageManager.shared.localizedText(for: "searchPlaceholder")
//        updateTasksCount()
//    }
    
    // Меню выбора языка
    
    private func setupLanguageButtonMenu() {
        headerLanguageButton.showsMenuAsPrimaryAction = true
        updateLanguageButtonMenu()
    }
    
    private func updateLanguageButtonMenu() {
//        let langCode = HeaderButtonsManager.shared.selectedLanguage
//
//           // Создаём действия для меню
//           let russian = UIAction(
//               title: "Русский",
//               state: langCode == "ru" ? .on : .off
//           ) { [weak self] _ in
//               HeaderButtonsManager.shared.selectedLanguage = "ru"
//               self?.applyLanguage()
//           }
//
//           let english = UIAction(
//               title: "English",
//               state: langCode == "en" ? .on : .off
//           ) { [weak self] _ in
//               HeaderButtonsManager.shared.selectedLanguage = "en"
//               self?.applyLanguage()
//           }
//
//           let menu = UIMenu(title: "Язык", children: [russian, english])
//           headerLanguageButton.menu = menu
        
        let langCode = HeaderButtonsManager.shared.selectedLanguage

           // Создаём действия для меню
           let russian = UIAction(
               title: "Русский",
               state: langCode == "ru" ? .on : .off
           ) { [weak self] _ in
               HeaderButtonsManager.shared.selectedLanguage = "ru"
               self?.applyLanguage()      // обновляем UI
               self?.updateLanguageButtonMenu() // пересоздаём меню для галочек
           }

           let english = UIAction(
               title: "English",
               state: langCode == "en" ? .on : .off
           ) { [weak self] _ in
               HeaderButtonsManager.shared.selectedLanguage = "en"
               self?.applyLanguage()
               self?.updateLanguageButtonMenu()
           }

           let menu = UIMenu(title: "Язык", children: [russian, english])
           headerLanguageButton.menu = menu
    }
    
    // MARK: - Настройки поиска
    // Когда меняется текст в поиске
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Пока идет голосовой поиск, не фильтруем вручную
        guard !isVoiceSearching else { return }
        
        if searchText.isEmpty {
            isSearching = false
            filterTasks()
            return
        }
        
        isSearching = true
        filteredTasks = viewModel.tasks.filter { task in
            task.title?.lowercased().contains(searchText.lowercased()) ?? false
        }
        tableView.reloadData()
    }
    
    // Нажатие на кнопку "Отмена"
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if isVoiceSearching {
            stopVoiceSearch()
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isVoiceSearching = true
                    self?.startRecording()
                case .denied, .restricted, .notDetermined:
                    let alert = UIAlertController(title: "Ошибка", message: "Доступ к микрофону запрещён", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    self?.present(alert, animated: true)
                @unknown default: break
                }
            }
        }
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
        
        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        
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
        tableView.dragInteractionEnabled = false // Включаем drag
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
        view.addSubview(sortButton)
        view.addSubview(tasksCountBackground)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        tasksCountBackground.isUserInteractionEnabled = true
        tasksCountBackground.addGestureRecognizer(tapGesture)
        
        tasksCountBackground.addSubview(tasksCountLabel)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountBackground.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            sortButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            sortButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            tasksCountBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tasksCountBackground.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            tasksCountBackground.heightAnchor.constraint(equalToConstant: 40),
            tasksCountBackground.widthAnchor.constraint(equalToConstant: 190),
            
            tasksCountLabel.centerXAnchor.constraint(equalTo: tasksCountBackground.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: tasksCountBackground.centerYAnchor)
        ])
        
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
        
        setupSortButtonMenu()
        
        //        sortButton.addTarget(self, action: #selector(showSortMenu), for: .touchUpInside)
    }
    
    private func setupSortButtonMenu() {
        sortButton.showsMenuAsPrimaryAction = true
        updateSortButtonMenu()
    }
    
    private func updateSortButtonMenu() {
        let sortAZ = UIAction(title: "От А до Я", image: UIImage(systemName: "textformat.abc"), state: currentSort == .az ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.currentSort = .az
            UserDefaults.standard.set(self.currentSort.rawValue, forKey: "tasksSort")
            self.applySorting()
            self.updateSortButtonMenu() // обновляем галочку
        }
        
        let sortZA = UIAction(title: "От Я до А", image: UIImage(systemName: "textformat.abc.dottedunderline"), state: currentSort == .za ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.currentSort = .za
            UserDefaults.standard.set(self.currentSort.rawValue, forKey: "tasksSort")
            self.applySorting()
            self.updateSortButtonMenu()
        }
        
        let sortByDateUp = UIAction(title: "По дате ↑", image: UIImage(systemName: "calendar"), state: currentSort == .dateUp ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.currentSort = .dateUp
            UserDefaults.standard.set(self.currentSort.rawValue, forKey: "tasksSort")
            self.applySorting()
            self.updateSortButtonMenu()
        }
        
        let sortByDateDown = UIAction(title: "По дате ↓", image: UIImage(systemName: "calendar"), state: currentSort == .dateDown ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.currentSort = .dateDown
            UserDefaults.standard.set(self.currentSort.rawValue, forKey: "tasksSort")
            self.applySorting()
            self.updateSortButtonMenu()
        }
        
        let customOrder = UIAction(title: "Свой порядок", image: UIImage(systemName: "arrow.up.arrow.down.square"), state: currentSort == .customOrder ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.currentSort = .customOrder
            UserDefaults.standard.set(self.currentSort.rawValue, forKey: "tasksSort")
            self.applySorting()
            self.updateSortButtonMenu()
        }
        
        let menu = UIMenu(title: "Сортировка", children: [sortByDateUp, sortByDateDown, sortZA, sortAZ, customOrder])
        sortButton.menu = menu
    }
    
    // Настраиваем действия кнопок Footer
    private func setupHeaderButtonActions() {
        headerFaceIdButton.addTarget(self, action: #selector(faceIDTapped), for: .touchUpInside)
        headerDoneOnlyButton.addTarget(self, action: #selector(doneOnlyTapped), for: .touchUpInside)
        headerNotDoneOnlyButton.addTarget(self, action: #selector(notDoneOnlyTapped), for: .touchUpInside)
        //        headerLanguageButton.addTarget(self, action: #selector(languageTapped), for: .touchUpInside)
    }
    
    // делегатский метод UISearchBarDelegate
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        // Проверяем доступ к микрофону и распознаванию речи
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.startRecording()
                case .denied, .restricted, .notDetermined:
                    let alert = UIAlertController(title: "Ошибка", message: "Доступ к микрофону запрещён", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    self?.present(alert, animated: true)
                @unknown default:
                    break
                }
            }
        }
    }
    
    // Микрофон
    private func startRecording() {
        if audioEngine.isRunning {
            stopRecording()
            return
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        let node = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.searchBar.text = result.bestTranscription.formattedString
                self.searchBar(self.searchBar, textDidChange: result.bestTranscription.formattedString)
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        searchBar.placeholder = "Говорите..."
    }
    
    // Микрофон
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        searchBar.placeholder = "Поиск задач"
    }
    
    // Сброс микрофона
    private func stopVoiceSearch() {
        if audioEngine.isRunning {
            stopRecording()
        }
        isVoiceSearching = false
        searchBar.text = ""
        isSearching = false
        filterTasks()
    }
    
    // faceID
    @objc private func faceIDTapped() {
        
#if targetEnvironment(simulator)
        print("Face ID недоступен на симуляторе")
        return
#endif
        
        guard FaceIDManager.shared.isFaceIDAvailable() else {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Face ID недоступен на этом устройстве.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
            return
        }
        
        FaceIDManager.shared.authenticateUser { success, error in
            DispatchQueue.main.async {
                if success {
                    
                    HeaderButtonsManager.shared.isFaceIDEnabled.toggle()
                    self.updateHeaderButtonUI()
                    
                } else {
                    
                    HeaderButtonsManager.shared.isFaceIDEnabled = false
                    self.updateHeaderButtonUI()
                }
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
    
    // doneOnly
    @objc private func doneOnlyTapped() {
        HeaderButtonsManager.shared.toggleDoneOnly()
        filterTasks()
        updateHeaderButtonUI()
    }
    
    // notDoneOnly
    @objc private func notDoneOnlyTapped() {
        HeaderButtonsManager.shared.toggleNotDoneOnly()
        filterTasks()
        updateHeaderButtonUI()
    }
    
    // Обновление цвета кнопок по состоянию
    private func updateHeaderButtonUI() {
        headerFaceIdButton.tintColor = HeaderButtonsManager.shared.isFaceIDEnabled ? .systemYellow : .systemGray
            headerDoneOnlyButton.tintColor = HeaderButtonsManager.shared.isDoneOnlyEnabled ? .systemYellow : .systemGray
            headerNotDoneOnlyButton.tintColor = HeaderButtonsManager.shared.isNotDoneOnlyEnabled ? .systemYellow : .systemGray
            
            // Кнопка языка всегда желтая
            headerLanguageButton.tintColor = .systemYellow
    }
    
    // Фильтрация задач для Done/NotDone
    private func filterTasks() {
        if HeaderButtonsManager.shared.isDoneOnlyEnabled {
            filteredTasks = viewModel.tasks.filter { $0.isCompleted }
        } else if HeaderButtonsManager.shared.isNotDoneOnlyEnabled {
            filteredTasks = viewModel.tasks.filter { !$0.isCompleted }
        } else {
            filteredTasks = viewModel.tasks
        }
        
        isSearching = false
        tableView.reloadData()
        updateTasksCount()
    }
    
    private func updateTasksCount() {
        let count: Int
        let text: String

        if HeaderButtonsManager.shared.isDoneOnlyEnabled {
            count = viewModel.tasks.filter { $0.isCompleted }.count
            text = "\(LanguageManager.shared.localizedText(for: "tasksCountDone")): \(count)"
        } else if HeaderButtonsManager.shared.isNotDoneOnlyEnabled {
            count = viewModel.tasks.filter { !$0.isCompleted }.count
            text = "\(LanguageManager.shared.localizedText(for: "tasksCountNotDone")): \(count)"
        } else {
            count = viewModel.tasks.count
            text = "\(LanguageManager.shared.localizedText(for: "tasksCountAll")): \(count)"
        }

        tasksCountLabel.text = text
    }
    
    // MARK: - Сортировка
    // Скрол таблицы при нажатии на tasksCountBackground
    @objc private func scrollToTop() {
        guard !viewModel.tasks.isEmpty else { return }
        let topIndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
    }
    
    // метод применения сортировки
    private func applySorting() {
        
        // Сортируем основной массив
        switch currentSort {
        case .az:
            viewModel.tasks.sort {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
            }
        case .za:
            viewModel.tasks.sort {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
        case .dateUp:
            viewModel.tasks.sort {
                ($0.createdAt ?? Date()) < ($1.createdAt ?? Date())
            }
        case .dateDown:
            viewModel.tasks.sort {
                ($0.createdAt ?? Date()) > ($1.createdAt ?? Date())
            }
        case .customOrder:
            viewModel.tasks.sort { $0.order < $1.order } // ← сортируем по сохранённому порядку
        }
        
        filterTasks()
        
        tableView.dragInteractionEnabled = currentSort == .customOrder
    }
    
    
    // MARK: - Добавление новой задачи
    @objc private func addTaskTapped() {
        
        let addVC = AddTaskViewController()
        addVC.delegate = self
        addVC.isEditingTask = false  // Добавление новой задачи
        
        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(addVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        //        let task = isSearching ? filteredTasks[indexPath.row] : viewModel.tasks[indexPath.row]
        let task = filteredTasks[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(with: task)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    // Удаление свайпом
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = filteredTasks[indexPath.row]
        
        let completeAction = UIContextualAction(
            style: .normal,
            title: task.isCompleted ? "Снять" : "Выполнено"
        ) { [weak self] _, _, completionHandler in
            
            guard let self = self else { return }
            
            if let index = self.viewModel.tasks.firstIndex(of: task) {
                self.viewModel.updateTaskCompleted(at: index, completed: !task.isCompleted)
            }
            
            self.filterTasks()
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
            
            // Берём задачу из отображаемого массива
            let task = self.filteredTasks[indexPath.row]
            
            // Преобразуем Int64 в String для идентификатора уведомления
            let taskId = String(task.id)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
            
            // Находим её в основном массиве и удаляем
            if let index = self.viewModel.tasks.firstIndex(of: task) {
                self.viewModel.deleteTask(at: index)
            }
            
            // Обновляем отображаемые задачи
            self.filterTasks()
            self.updateTasksCount()
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        
        return config
        
    }
    
    // Отмечаем/снимаем задачу как выполненную
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = filteredTasks[indexPath.row]
        
        // Если задача завершена — не открываем редактирование
        if task.isCompleted {
            tableView.deselectRow(at: indexPath, animated: true) // снимаем выделение
            return
        }
        
        // Только незавершённые задачи можно редактировать
        let addVC = AddTaskViewController()
        addVC.delegate = self
        addVC.isEditingTask = true
        addVC.existingTask = task
        addVC.showCompletedSwitch = true
        addVC.showShareButton = true
        
        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(addVC, animated: true)
        
    }
    
    // Разрешаем редактирование ячеек (чтобы включить drag & drop)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return currentSort == .customOrder && !isSearching
    }
    
    // Обновляем модель при перемещении
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard currentSort == .customOrder else { return }
        
        let movedTask = filteredTasks[sourceIndexPath.row]
        
        // индексы в основном массиве
        guard let sourceIndex = viewModel.tasks.firstIndex(of: movedTask) else { return }
        
        let destinationTask = filteredTasks[destinationIndexPath.row]
        guard let destinationIndex = viewModel.tasks.firstIndex(of: destinationTask) else { return }
        
        viewModel.tasks.remove(at: sourceIndex)
        viewModel.tasks.insert(movedTask, at: destinationIndex)
        
        // обновляем order
        for (index, task) in viewModel.tasks.enumerated() {
            task.order = Int64(index)
        }
        
        CoreDataManager.shared.saveContext()
        
        filterTasks()
    }
    
    
}

extension TasksViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        
        guard currentSort == .customOrder else {
            return []
        }
        
        let task = filteredTasks[indexPath.row]
        
        let itemProvider = NSItemProvider(object: (task.title ?? "") as NSString)
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
                
                // Находим индекс для вставки
                let destinationTask = filteredTasks[min(destinationIndexPath.row, filteredTasks.count - 1)]
                let destinationIndex = viewModel.tasks.firstIndex(of: destinationTask) ?? viewModel.tasks.count
                
                viewModel.tasks.insert(task, at: destinationIndex)
                
                // Обновляем order
                for (index, task) in viewModel.tasks.enumerated() {
                    task.order = Int64(index)
                }
                
                CoreDataManager.shared.saveContext()
                filterTasks()
                updateTasksCount()
            }
        }
    }
    
    // Разрешаем перемещение только внутри таблицы
    func tableView(_ tableView: UITableView,
                   canHandle session: UIDropSession) -> Bool {
        
        return currentSort == .customOrder &&
        !isSearching &&
        session.localDragSession != nil
    }
    
    
}

extension TasksViewController: AddTaskViewControllerDelegate {
    
    func didAddTask(_ task: TaskEntity) {
        
        if let index = viewModel.tasks.firstIndex(of: task) {
            
            // РЕДАКТИРОВАНИЕ
            viewModel.tasks[index] = task
            
            if let filteredIndex = filteredTasks.firstIndex(of: task) {
                let indexPath = IndexPath(row: filteredIndex, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        } else {
            
            // ДОБАВЛЕНИЕ НОВОЙ ЗАДАЧИ
            viewModel.tasks.insert(task, at: 0)
            filterTasks()
            tableView.reloadData()
            
            if !filteredTasks.isEmpty {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
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

// Уведомления
extension TasksViewController: UNUserNotificationCenterDelegate {
    
    // Вызывается, когда уведомление приходит, пока приложение активно
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Получаем идентификатор уведомления
        let id = notification.request.identifier
        
        let tasks = CoreDataManager.shared.fetchTasks()
        if let task = tasks.first(where: { $0.notificationId == id }) {
            task.hasReminderTriggered = true
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(name: .taskUpdated, object: task)
        }
        
        // Показываем баннер + звук
        completionHandler([.banner, .sound])
    }
}

extension Notification.Name {
    static let taskUpdated = Notification.Name("taskUpdated")
}

// Язык
extension TasksViewController: LanguageSelectionViewDelegate {
    func didSelectLanguage(_ code: String) {
        applyLanguage()
    }
}
