//
//  TableCell.swift
//  Language
//
//  Created by Павел on 07.07.2024.
//

import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var WordLabel: UILabel!
    @IBOutlet weak var TranslateLabel: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        WordLabel.text = nil
        TranslateLabel.text = nil
    }
    
    func config(word : Word) {
        WordLabel.text = word.spelling
        TranslateLabel.text = word.translation
        }
}
