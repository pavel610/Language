import UIKit

class CardViewController: UIViewController {
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var remeberLabel: UILabel!
    
    lazy private var ifEmptyLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Все выучено"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 24)
        label.isHidden = true
        return label
    }()
    
    lazy private var retryButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Повторить", for: .normal)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var cardViews: [CardView] = []
    var currentCardIndex = 0
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewWordNotification(_:)), name: .didAddNewWord, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDeleteWordsNotification), name: .didDeleteWords, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCards()
        setupIfEmptyLabel()
        setupRetryButton()
    }
    
    private func setupIfEmptyLabel() {
        view.addSubview(ifEmptyLabel)
        
        NSLayoutConstraint.activate([
            ifEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ifEmptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ifEmptyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            ifEmptyLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupRetryButton() {
        view.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: ifEmptyLabel.bottomAnchor, constant: 20),
            retryButton.widthAnchor.constraint(equalToConstant: 150),
            retryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func retryButtonTapped() {
        loadCards()
    }
    
    @objc private func didReceiveDeleteWordsNotification() {
        clearCards()
        checkIfEmpty()
    }
    
    
    @objc private func didReceiveNewWordNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let word = userInfo["word"] as? Word else { return }
        addCard(with: word)
    }
    
    private func addCard(with word: Word) {
        let cardView = CardView()
        cardView.configure(with: word)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
        
        cardViews.append(cardView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cardView.addGestureRecognizer(panGesture)
        
        checkIfEmpty()
    }
    
    private func loadCards() {
        clearCards()
        WordManager.shared.loadWords { [weak self] result in
            switch result {
            case .success(let words):
                self?.setupCards(with: words)
            case .failure(let error):
                print("Failed to load words: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupCards(with words: [Word]) {
        for word in words.reversed() {
            addCard(with: word)
        }
    }
    
    private func clearCards() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
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
            if translation.x < -50 {
                self.repeatLabel.textColor = .peach
                self.remeberLabel.textColor = .black
            } else if translation.x > 50 {
                self.remeberLabel.textColor = .peach
                self.repeatLabel.textColor = .black
            } else {
                self.repeatLabel.textColor = .black
                self.remeberLabel.textColor = .black
            }
        case .ended:
            if translation.x > 70 {
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: translation.x > 0 ? self.view.bounds.width * 2 : -self.view.bounds.width * 2, y: center.y + translation.y)
                }) { _ in
                    cardView.removeFromSuperview()
                    self.cardViews.removeAll(where: { $0 == cardView })
                    self.checkIfEmpty()
                }
            } else if translation.x < -70 {
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: translation.x > 0 ? self.view.bounds.width * 2 : -self.view.bounds.width * 2, y: center.y + translation.y)
                }) { _ in
                    cardView.transform = .identity
                    cardView.removeFromSuperview()
                    self.cardViews.removeAll(where: { $0 == cardView })
                    self.cardViews.insert(cardView, at: 0)
                    self.repositionCards()
                    self.checkIfEmpty()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    cardView.center = center
                    cardView.transform = .identity
                }
            }
            self.repeatLabel.textColor = .black
            self.remeberLabel.textColor = .black
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
                cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
            ])
            
            if index == cardViews.count - 1 {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                cardView.addGestureRecognizer(panGesture)
            }
        }
    }
    
    private func checkIfEmpty() {
        if cardViews.isEmpty && !WordManager.shared.getWords().isEmpty{
            ifEmptyLabel.isHidden = false
            retryButton.isHidden = false
            
        } else {
            ifEmptyLabel.isHidden = true
            retryButton.isHidden = true
        }
    }
    

}

