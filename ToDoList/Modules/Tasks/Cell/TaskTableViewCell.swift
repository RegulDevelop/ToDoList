//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import UIKit
//
//class TaskTableViewCell: UITableViewCell {
//    
//    static let identifier = "TaskTableViewCell"
//    
//    private var titleWithCheckConstraint: NSLayoutConstraint!
//    private var titleWithoutCheckConstraint: NSLayoutConstraint!
//    
//    // Контейнер задачи
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.systemGray6
//        view.layer.cornerRadius = 10
//        return view
//    }()
//    
//    // Заголовок задачи
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 18)
//        label.textColor = .white
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    // Галочка слева
//    private let checkmarkImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "checkmark.circle.fill")
//        imageView.tintColor = .systemYellow
//        imageView.isHidden = true
//        return imageView
//    }()
//    
//    private let descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .white
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        return label
//    }()
//    
//    // Дата создания
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 12)
//        label.textColor = .gray
//        return label
//    }()
//    
//    //    private let checkmarkLabel: UILabel = {
//    //        let label = UILabel()
//    //        label.font = .systemFont(ofSize: 18)
//    //        label.text = "✅" // изначально пусто или по умолчанию скрыто
//    //        label.isHidden = true
//    //        return label
//    //    }()
//    
//    // Статус выполнения
//    //    private let statusLabel: UILabel = {
//    //        let label = UILabel()
//    //        label.font = .systemFont(ofSize: 14)
//    //        label.textColor = .systemGreen
//    //        return label
//    //    }()
//    
//    // MARK: - Инициализация
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        contentView.addSubview(containerView)
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(descriptionLabel)
//        containerView.addSubview(dateLabel)
//        containerView.addSubview(checkmarkImageView)
//        
//        setupConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupConstraints() {
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        titleWithCheckConstraint = titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 10)
//        titleWithoutCheckConstraint = titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
//        
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
//            
//            // Галочка слева
//            checkmarkImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
//            checkmarkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
//            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
//            
//            // Заголовок
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
//            //                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 44),
//            titleWithoutCheckConstraint,
//            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
//            
//            // Описание
//            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            
//            // Дата
//            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
//        ])
//    }
//    
//    // Сброс констрейнтов
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        // Сброс видимости галочки
//        checkmarkImageView.isHidden = true
//        checkmarkImageView.transform = .identity // важный момент!
//        
//        // Сброс текста
//        titleLabel.text = nil
//        descriptionLabel.text = nil
//        dateLabel.text = nil
//        
//        // Сброс атрибутов
//        titleLabel.attributedText = nil
//        descriptionLabel.attributedText = nil
//        
//        // Сброс констрейнтов
//        titleWithCheckConstraint.isActive = false
//        titleWithoutCheckConstraint.isActive = true
//        
//        // Сброс альфа контейнера
//        containerView.alpha = 1.0
//    }
//    
//    // MARK: - Настройка ячейки
//    func configure(with task: TaskEntity) {
//        
//        //        containerView.alpha = 1.0
//        //        checkmarkImageView.isHidden = true
//        //        titleWithoutCheckConstraint.isActive = true
//        //        titleWithCheckConstraint.isActive = false
//        //        titleLabel.attributedText = nil
//        //        descriptionLabel.attributedText = nil
//        //
//        //        // дата
//        //        if let date = task.createdAt {
//        //            let formatter = DateFormatter()
//        //            formatter.locale = Locale(identifier: "ru_RU")
//        //            formatter.dateStyle = .medium
//        //            formatter.timeStyle = .short
//        //            dateLabel.text = "Добавлено: \(formatter.string(from: date))"
//        //        } else {
//        //            dateLabel.text = ""
//        //        }
//        //
//        //
//        //        if task.isCompleted {
//        //
//        //            checkmarkImageView.isHidden = false
//        //            checkmarkImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//        //
//        //            UIView.animate(withDuration: 0.25) {
//        //                self.checkmarkImageView.transform = .identity
//        //            }
//        //
//        //        } else {
//        //
//        //            checkmarkImageView.isHidden = true
//        //        }
//        //
//        //        if task.isCompleted {
//        //            titleWithoutCheckConstraint.isActive = false
//        //            titleWithCheckConstraint.isActive = true
//        //        } else {
//        //            titleWithCheckConstraint.isActive = false
//        //            titleWithoutCheckConstraint.isActive = true
//        //        }
//        //
//        //        containerView.alpha = task.isCompleted ? 0.7 : 1.0
//        //
//        //        let titleText = task.title ?? ""
//        //        let descText = task.taskDescription ?? ""
//        //
//        //        if task.isCompleted {
//        //
//        //            let titleAttr = NSMutableAttributedString(string: titleText)
//        //            titleAttr.addAttribute(.strikethroughStyle,
//        //                                   value: NSUnderlineStyle.single.rawValue,
//        //                                   range: NSRange(location: 0, length: titleText.count))
//        //            titleAttr.addAttribute(.foregroundColor,
//        //                                   value: UIColor.systemGray,
//        //                                   range: NSRange(location: 0, length: titleText.count))
//        //
//        //            let descAttr = NSMutableAttributedString(string: descText)
//        //            descAttr.addAttribute(.strikethroughStyle,
//        //                                  value: NSUnderlineStyle.single.rawValue,
//        //                                  range: NSRange(location: 0, length: descText.count))
//        //            descAttr.addAttribute(.foregroundColor,
//        //                                  value: UIColor.systemGray,
//        //                                  range: NSRange(location: 0, length: descText.count))
//        //
//        //            UIView.transition(with: titleLabel,
//        //                              duration: 0.25,
//        //                              options: .transitionCrossDissolve) {
//        //                self.titleLabel.attributedText = titleAttr
//        //            }
//        //
//        //            UIView.transition(with: descriptionLabel,
//        //                              duration: 0.25,
//        //                              options: .transitionCrossDissolve) {
//        //                self.descriptionLabel.attributedText = descAttr
//        //            }
//        //
//        //        } else {
//        //
//        //            let titleAttr = NSAttributedString(
//        //                string: titleText,
//        //                attributes: [.foregroundColor: UIColor.white]
//        //            )
//        //
//        //            let descAttr = NSAttributedString(
//        //                string: descText,
//        //                attributes: [.foregroundColor: UIColor.white]
//        //            )
//        //
//        //            UIView.transition(with: titleLabel,
//        //                              duration: 0.25,
//        //                              options: .transitionCrossDissolve) {
//        //                self.titleLabel.attributedText = titleAttr
//        //            }
//        //
//        //            UIView.transition(with: descriptionLabel,
//        //                              duration: 0.25,
//        //                              options: .transitionCrossDissolve) {
//        //                self.descriptionLabel.attributedText = descAttr
//        //            }
//        //        }
//        //    }
//        
//        // 1️⃣ Полный сброс состояния ячейки
//           containerView.alpha = 1.0
//           checkmarkImageView.isHidden = true
//           checkmarkImageView.transform = .identity
//           titleWithoutCheckConstraint.isActive = true
//           titleWithCheckConstraint.isActive = false
//
//           // Сброс текста и атрибутов
//           titleLabel.text = nil
//           descriptionLabel.text = nil
//           dateLabel.text = nil
//           titleLabel.attributedText = nil
//           descriptionLabel.attributedText = nil
//
//           // 2️⃣ Дата
//           if let date = task.createdAt {
//               let formatter = DateFormatter()
//               formatter.locale = Locale(identifier: "ru_RU")
//               formatter.dateStyle = .medium
//               formatter.timeStyle = .short
//               dateLabel.text = "Добавлено: \(formatter.string(from: date))"
//           } else {
//               dateLabel.text = ""
//           }
//
//           // 3️⃣ Галочка и констрейнты
//           if task.isCompleted {
//               checkmarkImageView.isHidden = false
//               titleWithoutCheckConstraint.isActive = false
//               titleWithCheckConstraint.isActive = true
//               containerView.alpha = 0.7
//           } else {
//               checkmarkImageView.isHidden = true
//               titleWithCheckConstraint.isActive = false
//               titleWithoutCheckConstraint.isActive = true
//               containerView.alpha = 1.0
//           }
//
//           // 4️⃣ Настройка текста с атрибутами
//           let titleText = task.title ?? ""
//           let descText = task.taskDescription ?? ""
//
//           let titleAttr = NSMutableAttributedString(string: titleText)
//           let descAttr = NSMutableAttributedString(string: descText)
//
//           if task.isCompleted {
//               titleAttr.addAttribute(.strikethroughStyle,
//                                      value: NSUnderlineStyle.single.rawValue,
//                                      range: NSRange(location: 0, length: titleText.count))
//               titleAttr.addAttribute(.foregroundColor,
//                                      value: UIColor.systemGray,
//                                      range: NSRange(location: 0, length: titleText.count))
//
//               descAttr.addAttribute(.strikethroughStyle,
//                                     value: NSUnderlineStyle.single.rawValue,
//                                     range: NSRange(location: 0, length: descText.count))
//               descAttr.addAttribute(.foregroundColor,
//                                     value: UIColor.systemGray,
//                                     range: NSRange(location: 0, length: descText.count))
//           } else {
//               titleAttr.addAttribute(.foregroundColor,
//                                      value: UIColor.white,
//                                      range: NSRange(location: 0, length: titleText.count))
//               descAttr.addAttribute(.foregroundColor,
//                                     value: UIColor.white,
//                                     range: NSRange(location: 0, length: descText.count))
//           }
//
//           // 5️⃣ Присваиваем
//           titleLabel.attributedText = titleAttr
//           descriptionLabel.attributedText = descAttr
//    }
//}

class TaskTableViewCell: UITableViewCell {
    
    static let identifier = "TaskTableViewCell"
    
    private var titleWithCheckConstraint: NSLayoutConstraint!
    private var titleWithoutCheckConstraint: NSLayoutConstraint!
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemYellow
        imageView.isHidden = true
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(checkmarkImageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleWithCheckConstraint = titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 10)
        titleWithoutCheckConstraint = titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            checkmarkImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            checkmarkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleWithoutCheckConstraint,
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        containerView.alpha = 1.0
        checkmarkImageView.isHidden = true
        checkmarkImageView.transform = .identity
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        
        titleWithCheckConstraint.isActive = false
        titleWithoutCheckConstraint.isActive = true
    }
    
    // MARK: - Конфигурация
    func configure(with task: TaskEntity) {
        //
        //        // 1️⃣ Сброс состояния (чтобы ячейка была "чистой")
        //        containerView.alpha = 1.0
        //        checkmarkImageView.isHidden = true
        //        titleWithoutCheckConstraint.isActive = true
        //        titleWithCheckConstraint.isActive = false
        //
        //        titleLabel.attributedText = nil
        //        descriptionLabel.attributedText = nil
        //
        //        // 2️⃣ Дата
        //        if let date = task.createdAt {
        //            let formatter = DateFormatter()
        //            formatter.locale = Locale(identifier: "ru_RU")
        //            formatter.dateStyle = .medium
        //            formatter.timeStyle = .short
        //            dateLabel.text = "Добавлено: \(formatter.string(from: date))"
        //        } else {
        //            dateLabel.text = ""
        //        }
        //
        //        // 3️⃣ Галочка и constraints
        //        if task.isCompleted {
        //            checkmarkImageView.isHidden = false
        //            titleWithoutCheckConstraint.isActive = false
        //            titleWithCheckConstraint.isActive = true
        //            containerView.alpha = 0.7
        //        } else {
        //            checkmarkImageView.isHidden = true
        //            titleWithCheckConstraint.isActive = false
        //            titleWithoutCheckConstraint.isActive = true
        //            containerView.alpha = 1.0
        //        }
        //
        //        // 4️⃣ Текст и атрибуты
        //        let titleText = task.title ?? ""
        //        let descText = task.taskDescription ?? ""
        //
        //        let titleAttr = NSMutableAttributedString(string: titleText)
        //        let descAttr = NSMutableAttributedString(string: descText)
        //
        //        if task.isCompleted {
        //            titleAttr.addAttribute(.strikethroughStyle,
        //                                   value: NSUnderlineStyle.single.rawValue,
        //                                   range: NSRange(location: 0, length: titleText.count))
        //            titleAttr.addAttribute(.foregroundColor, value: UIColor.systemGray,
        //                                   range: NSRange(location: 0, length: titleText.count))
        //
        //            descAttr.addAttribute(.strikethroughStyle,
        //                                  value: NSUnderlineStyle.single.rawValue,
        //                                  range: NSRange(location: 0, length: descText.count))
        //            descAttr.addAttribute(.foregroundColor, value: UIColor.systemGray,
        //                                  range: NSRange(location: 0, length: descText.count))
        //        } else {
        //            titleAttr.addAttribute(.foregroundColor, value: UIColor.white,
        //                                   range: NSRange(location: 0, length: titleText.count))
        //            descAttr.addAttribute(.foregroundColor, value: UIColor.white,
        //                                  range: NSRange(location: 0, length: descText.count))
        //        }
        //
        //        // 5️⃣ Присваиваем лейблам
        //        titleLabel.attributedText = titleAttr
        //        descriptionLabel.attributedText = descAttr
        //    }
        
        // 1️⃣ Сброс состояния ячейки
        containerView.alpha = 1.0
        checkmarkImageView.isHidden = true
        titleWithoutCheckConstraint.isActive = true
        titleWithCheckConstraint.isActive = false
        
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        
        // 2️⃣ Настройка даты
        if let date = task.createdAt {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = "Добавлено: \(formatter.string(from: date))"
        } else {
            dateLabel.text = ""
        }
        
        // 3️⃣ Галочка и constraints
        if task.isCompleted {
            checkmarkImageView.isHidden = false
            titleWithoutCheckConstraint.isActive = false
            titleWithCheckConstraint.isActive = true
            containerView.alpha = 0.7
        } else {
            checkmarkImageView.isHidden = true
            titleWithCheckConstraint.isActive = false
            titleWithoutCheckConstraint.isActive = true
            containerView.alpha = 1.0
        }
        
        // 4️⃣ Настройка текста и атрибутов
        let titleText = task.title ?? ""
        let descText = task.taskDescription ?? ""
        
        let textColor: UIColor = task.isCompleted ? .systemGray : .white
        let strikethrough: NSUnderlineStyle = task.isCompleted ? .single : []
        
        let titleAttr = NSMutableAttributedString(
            string: titleText,
            attributes: [
                .foregroundColor: textColor,
                .strikethroughStyle: strikethrough.rawValue
            ]
        )
        
        let descAttr = NSMutableAttributedString(
            string: descText,
            attributes: [
                .foregroundColor: textColor,
                .strikethroughStyle: strikethrough.rawValue
            ]
        )
        
        // 5️⃣ Присваиваем лейблам
        titleLabel.attributedText = titleAttr
        descriptionLabel.attributedText = descAttr
    }
    
}
