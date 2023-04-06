//
//  CountryPickerViewController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/6.
//

import UIKit
import Combine

protocol CountryPickerViewControllerDelegate: AnyObject{
    func countrySelected(_ countryPickerVC: CountryPickerViewController)
}

class CountryPickerViewController: UITableViewController {

    private let viewModel: CountryPickerViewModel
    private let countryViewModels: [CountryCellViewModel]
    private let selectedRowSubject = PassthroughSubject<Int,Never>()
    private var subscriptions = Set<AnyCancellable>()
    weak var flowDelegate: CountryPickerViewControllerDelegate?
    
    init(viewModel: CountryPickerViewModel){
        self.viewModel = viewModel
        countryViewModels = viewModel.output.countryCellViewModels
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInput()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.scrollToRow(at: IndexPath(row: viewModel.output.selectedRow, section: 0), at: .middle, animated: false)
    }
    
    private func setupTableView(){
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.reuseIdentifier)
        tableView.rowHeight = 50
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        tableView.backgroundColor = .backgroundWhite
        tableView.layoutIfNeeded()
    }
    
    private func bindViewModelInput(){
        selectedRowSubject.subscribe(viewModel.input.selectedNumber)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryViewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.reuseIdentifier, for: indexPath) as! CountryCell
        cell.viewModel = countryViewModels[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowSubject.send(indexPath.row)
        flowDelegate?.countrySelected(self)
    }
}
