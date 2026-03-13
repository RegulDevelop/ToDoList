//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Anton Tyurin on 10.03.2026.
//

import UIKit

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
    
    private let importantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "flag.fill")
        imageView.tintColor = .systemYellow
        imageView.isHidden = true
        return imageView
    }()
    
    private let remindIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "alarm.fill"))
        iv.tintColor = .systemYellow
        iv.isHidden = true
        return iv
    }()
    
    private let remindLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemYellow
        label.isHidden = true
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
        containerView.addSubview(importantImageView)
        containerView.addSubview(remindIcon)
        containerView.addSubview(remindLabel)
        
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
        importantImageView.translatesAutoresizingMaskIntoConstraints = false
        remindIcon.translatesAutoresizingMaskIntoConstraints = false
        remindLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
//            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            importantImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            importantImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            importantImageView.widthAnchor.constraint(equalToConstant: 16),
            importantImageView.heightAnchor.constraint(equalToConstant: 16),
            
            remindIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            remindIcon.centerYAnchor.constraint(equalTo: remindLabel.centerYAnchor),
            remindIcon.widthAnchor.constraint(equalToConstant: 16),
            remindIcon.heightAnchor.constraint(equalToConstant: 16),
            
            remindLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            remindLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            remindLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            remindLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
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
        
        // Сброс состояния ячейки
        containerView.alpha = 1.0
        checkmarkImageView.isHidden = true
        titleWithoutCheckConstraint.isActive = true
        titleWithCheckConstraint.isActive = false
        
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        
        // Настройка даты
        if let date = task.createdAt {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = "Добавлено: \(formatter.string(from: date))"
        } else {
            dateLabel.text = ""
        }
        
        // Важное
        if task.isImportant {
            titleLabel.textColor = .systemYellow
            importantImageView.isHidden = false
        } else {
            titleLabel.textColor = task.isCompleted ? .systemGray : .white
            importantImageView.isHidden = true
        }
        
        // Галочка и constraints
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
        
        // Настройка напоминания
        if let remindAt = task.remindAt {
            remindIcon.isHidden = false
            remindLabel.isHidden = false
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            remindLabel.text = "Напоминание: \(formatter.string(from: remindAt))"
        } else {
            remindIcon.isHidden = true
            remindLabel.isHidden = true
        }
            
            // Настройка текста и атрибутов
            let titleText = task.title ?? ""
            let descText = task.taskDescription ?? ""
            
            let textColor: UIColor
            
            if task.isImportant {
                textColor = .systemYellow
            } else {
                textColor = task.isCompleted ? .systemGray : .white
            }
            
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
            
            // Присваиваем лейблам
            titleLabel.attributedText = titleAttr
            descriptionLabel.attributedText = descAttr
        }
        
    }
    

