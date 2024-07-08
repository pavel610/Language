//
//  TableCell.swift
//  Language
//
//  Created by Павел on 07.07.2024.
//

import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        wordLabel.text = nil
        translateLabel.text = nil
    }
    
    func config(word : Word) {
        wordLabel.text = word.spelling
        translateLabel.text = word.translation
        wordLabel.textColor = .black
        translateLabel.textColor = .black
    }
}
