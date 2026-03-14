//
//  LanguageSelectionView.swift
//  ToDoList
//
//  Created by Anton Tyurin on 14.03.2026.
//

import Foundation

import UIKit

protocol LanguageSelectionViewDelegate: AnyObject {
    func didSelectLanguage(_ code: String)
}

class LanguageSelectionView: UIView {

    weak var delegate: LanguageSelectionViewDelegate?

    private let stackView = UIStackView()
    private let languages = [("Русский", "ru"), ("English", "en")]
    private var buttons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStack()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStack() {
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }

    private func setupButtons() {
        for (title, code) in languages {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = code == "ru" ? 0 : 1
            button.setTitleColor(.systemYellow, for: .normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemYellow.cgColor
            button.addTarget(self, action: #selector(languageTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        updateSelected()
    }

    @objc private func languageTapped(_ sender: UIButton) {
        let code = sender.tag == 0 ? "ru" : "en"
        HeaderButtonsManager.shared.setLanguage(code)
        updateSelected()
        delegate?.didSelectLanguage(code)
    }

    private func updateSelected() {
        let code = HeaderButtonsManager.shared.selectedLanguage
        for button in buttons {
            let isSelected = (button.tag == 0 && code == "ru") || (button.tag == 1 && code == "en")
            button.backgroundColor = isSelected ? .systemYellow : .clear
            button.setTitleColor(isSelected ? .white : .systemYellow, for: .normal)
        }
    }
}
