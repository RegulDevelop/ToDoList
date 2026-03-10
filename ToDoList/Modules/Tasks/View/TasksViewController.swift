//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Anton Tyurin on 09.03.2026.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDataSource {

    private let tableView = UITableView()
        private let viewModel = TasksViewModel()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white

            tableView.frame = view.bounds
            tableView.dataSource = self
            view.addSubview(tableView)

            // Загружаем задачи
            viewModel.loadTasks { [weak self] in
                self?.tableView.reloadData()
            }
        }

        // MARK: UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            viewModel.tasks.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            let task = viewModel.tasks[indexPath.row]
            cell.textLabel?.text = task.todo
            cell.detailTextLabel?.text = "UserID: \(task.userId) - Completed: \(task.completed)"
            return cell
        }

}
