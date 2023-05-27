//
//  CountryCell.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/6.
//

import UIKit

class CountryCell: UITableViewCell {
    
    static let reuseIdentifier = "country-cell-reuse-identifier"
    
    var viewModel: CountryCellViewModel!{
        didSet{
            configure(with: viewModel)
        }
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = UIBackgroundConfiguration.listPlainCell().updated(for: state)
        let customView = UIView()
        customView.backgroundColor = .backgroundWhite //set cell backgroundColor
        config.customView = customView
     
        if state.isHighlighted || state.isSelected {
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = .gray.withAlphaComponent(0.15)
            selectedBackgroundView.frame = customView.bounds
            selectedBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            customView.addSubview(selectedBackgroundView)
        }
        // config.backgroundColor = nil (default) // in order to use the cell's tintColor
        backgroundConfiguration = config
        tintColor = .systemOrange.withAlphaComponent(0.8) // won't work if this line is written in awakeFromNib()!
    }
    
    private func configure(with viewModel: CountryCellViewModel){
        accessoryType = viewModel.isSelected ? .checkmark : .none
        var config = defaultContentConfiguration()
        config.image = viewModel.flag.image()
        config.text = viewModel.labelText
        config.textProperties.color = .black
        config.textProperties.font = UIFont.systemFont(ofSize: 17)
        contentConfiguration = config
    }
 
}
