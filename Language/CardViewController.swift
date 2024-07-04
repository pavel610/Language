//
//  CardViewController.swift
//  Language
//
//  Created by Павел Калинин on 04.07.2024.
//

import UIKit

class CardViewController: UIViewController {
    
    let cards: [Card] = [
        Card(title: "Card 1", image: UIImage(named: "image1")!),
        Card(title: "Card 2", image: UIImage(named: "image2")!),
        Card(title: "Card 3", image: UIImage(named: "image3")!)
    ]
    
    var cardViews: [CardView] = []
    var currentCardIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCards()
    }
    
    private func setupCards() {
        for card in cards.reversed() {
            let cardView = CardView()
            cardView.configure(with: card)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cardView)
            
            NSLayoutConstraint.activate([
                cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
            ])
            
            cardViews.append(cardView)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            cardView.addGestureRecognizer(panGesture)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? CardView else { return }
        
        let translation = gesture.translation(in: view)
        let center = view.center
        
        switch gesture.state {
        case .began, .changed:
            cardView.center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            let rotation = translation.x / view.bounds.width * 0.3
            cardView.transform = CGAffineTransform(rotationAngle: rotation)
        case .ended:
            if translation.x > 100 {
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: translation.x > 0 ? self.view.bounds.width * 2 : -self.view.bounds.width * 2, y: center.y + translation.y)
                }) { _ in
                    cardView.removeFromSuperview()
                    self.cardViews.removeAll(where: { $0 == cardView })
                }
            } else if translation.x < -100{
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: translation.x > 0 ? self.view.bounds.width * 2 : -self.view.bounds.width * 2, y: center.y + translation.y)
                }) { _ in
                    cardView.transform = .identity
                    cardView.removeFromSuperview()
                    self.cardViews.removeAll(where: { $0 == cardView })
                    self.cardViews.insert(cardView, at: 0)
                    self.repositionCards()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    cardView.center = center
                    cardView.transform = .identity
                }
            }
        default:
            UIView.animate(withDuration: 0.3) {
                cardView.center = center
                cardView.transform = .identity
            }
        }
        
    }
    
    private func repositionCards() {
            for (index, cardView) in cardViews.enumerated() {
                view.addSubview(cardView)
                
                NSLayoutConstraint.activate([
                    cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                    cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
                ])
                
                if index == cardViews.count - 1 {
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                    cardView.addGestureRecognizer(panGesture)
                }
            }
        }
    
}
