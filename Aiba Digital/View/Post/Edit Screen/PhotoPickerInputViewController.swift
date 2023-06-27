//
//  CCViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/21.
//

import UIKit
import Combine

class PhotoPickerInputViewController: UIInputViewController {
    
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingButton: UIButton!
    
    enum Section { case all }
    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>!
    private let viewModel: MediaPickerViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: MediaPickerViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        inputView!.allowsSelfSizing = true
        inputView!.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = Bundle.main.loadNibNamed(String(describing: PhotoPickerInputViewController.self), owner : self)!.first as! UIView // owner has to be self or will error
        contentView.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            inputView!.heightAnchor.constraint(equalTo: inputView!.widthAnchor, multiplier: 2.7/3),
            contentView.topAnchor.constraint(equalTo: inputView!.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: inputView!.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: inputView!.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: inputView!.trailingAnchor)
        ])
        
       // collectionView.prefetchDataSource = self
        collectionView.collectionViewLayout = .squareGridLayout(itemsPerRow: 3)
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.backgroundColor = .white
        configureCollectionViewDataSource()
        
        bindViewModelOutput()
        configureButtonActions()
    }

    private func configureCollectionViewDataSource(){
        
        let cellRegistration = UICollectionView.CellRegistration<MediaPickerCell, MediaPickerCellViewModel>(cellNib: UINib(nibName: String(describing: MediaPickerCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>(collectionView: collectionView) { collectionView, indexPath, viewModel in
            return collectionView.dequeueConfiguredReusableCell(using:  cellRegistration, for: indexPath, item: viewModel)
        }
    }
    
    private func bindViewModelOutput(){
        
        viewModel.output.galleryMediaViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section,MediaPickerCellViewModel>()
                snapshot.appendSections([.all])
                snapshot.appendItems(viewModels)
                dataSource.apply(snapshot,animatingDifferences: true)
            }.store(in: &subscriptions)
        
        viewModel.output.hasPhotoLibraryAccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasAccess in
                self?.requestView.isHidden = hasAccess
               // self?.requestPhotoAccessView.isHidden = hasAccess
            }.store(in: &subscriptions)
        
    }
    
    private func configureButtonActions(){
        
        settingButton.publisher(for: .touchUpInside)
            .map{_ in}
            .bind(to: viewModel.input.requestPhotoLibraryAccess)
            .store(in: &subscriptions)
    }
    
}

extension PhotoPickerInputViewController: UICollectionViewDataSourcePrefetching{
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
}



