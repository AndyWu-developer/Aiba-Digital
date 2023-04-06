//
//  CollectionViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/6.
//

import UIKit

private let reuseIdentifier = "Cell"


class CollectionViewController: UICollectionViewController {

    
    init(){
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let postListLayout: UICollectionViewLayout = {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let headerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(50)), subitem: item, count: 1)
        let mediaGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalWidth(1.0)), subitem: item, count: 1)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(500)), subitems: [headerGroup, mediaGroup])
        //group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private func registerCellClasses(){
        collectionView.register(UINib(nibName: PostHeaderCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostHeaderCell.reuseIdentifier)
        collectionView.register(UINib(nibName: PostMediaCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostMediaCell.reuseIdentifier)
        collectionView.register(UINib(nibName: PostTextCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostTextCell.reuseIdentifier)
        collectionView.register(UINib(nibName: PostActionCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostActionCell.reuseIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellClasses()
        collectionView!.collectionViewLayout = postListLayout
        collectionView.backgroundColor = .backgroundWhite
       
       
        
    }

   
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("called \(indexPath)")
        switch indexPath.row{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostHeaderCell.reuseIdentifier, for: indexPath) as! PostHeaderCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostMediaCell.reuseIdentifier, for: indexPath) as! PostMediaCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostTextCell.reuseIdentifier, for: indexPath) as! PostTextCell
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCell.reuseIdentifier, for: indexPath) as! PostActionCell
            return cell
        default: fatalError("ooo")
        }
        
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        collectionView.performBatchUpdates(nil)
    }

}
