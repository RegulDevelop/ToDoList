//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let viewModel = TasksViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Регистрируем кастомную ячейку
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        // Кнопка "Добавить задачу"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskTapped))

        // Загружаем задачи
        viewModel.loadTasks { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
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
        }))

        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        let task = viewModel.tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }

    // MARK: - UITableViewDelegate

    // Удаление свайпом
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // Отмечаем/снимаем задачу как выполненную
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.tasks[indexPath.row]
        viewModel.updateTaskCompleted(at: indexPath.row, completed: !task.isCompleted)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
