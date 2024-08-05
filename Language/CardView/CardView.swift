//
//  CardView.swift
//  Language
//
//  Created by Павел Калинин on 04.07.2024.
//

import UIKit

class CardView: UIView {
    
    private lazy var spellingLabel = UILabel()
    private lazy var translationLabel = UILabel()
    private var isFlipped = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        spellingLabel.textAlignment = .center
        translationLabel.textAlignment = .center
        spellingLabel.textColor = .black
        translationLabel.textColor = .black
        spellingLabel.font = UIFont.systemFont(ofSize: 24)
        translationLabel.font = UIFont.systemFont(ofSize: 24)
                
        spellingLabel.frame = self.bounds
        translationLabel.frame = self.bounds
        translationLabel.isHidden = true

        backgroundColor = .white
        layer.borderWidth = 2
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2

        
        spellingLabel.translatesAutoresizingMaskIntoConstraints = false
        spellingLabel.textAlignment = .center
        addSubview(spellingLabel)
        
        translationLabel.textAlignment = .center
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(translationLabel)
        
        NSLayoutConstraint.activate([
            spellingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            spellingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            translationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            translationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        self.addGestureRecognizer(tapGesture)
    }
    
    func configure(with word: Word) {
        spellingLabel.text = word.spelling
        translationLabel.text = word.translation
    }
    
    @objc private func flipCard() {
        let toView = isFlipped ? spellingLabel : translationLabel
        let fromView = isFlipped ? translationLabel : spellingLabel
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        
        isFlipped.toggle()
    }
}
