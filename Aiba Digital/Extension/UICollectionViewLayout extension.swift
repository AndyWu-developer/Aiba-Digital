//
//  UICollectionViewLayout Extension.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/22.
//

import UIKit

extension UICollectionViewLayout {
    
    static func squareGridLayout(itemsPerRow: Int, spacing: CGFloat = 1) -> UICollectionViewLayout {
        /// there are exactly n cells per row and they have equal widths; the item’s layoutSize: width dimension is effectively ignored
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/CGFloat(itemsPerRow)))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
     
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/CGFloat(itemsPerRow)))
    
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item,count: itemsPerRow)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
      
        section.interGroupSpacing = spacing / CGFloat(itemsPerRow)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    static func threeGridLayout() -> UICollectionViewLayout{
        
        let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)

        let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalWidth(1.7/2.7))

        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                       subitem: topItem, count: 1)

        let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/CGFloat(2)))
        let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
     
        let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/CGFloat(2)))
    
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitem: bottomItem,count: 2)
        bottomGroup.interItemSpacing = .fixed(1)
        

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomGroup])
        group.interItemSpacing = .fixed(1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1/2

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
    static var oneItemGridLayout: UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(300))
        let groupSize = itemSize
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    static func scrollableGridLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 1
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
                if sectionIndex == 0{
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                    let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                                      subitems: [item])
                    let section = NSCollectionLayoutSection(group: topGroup)
                    return section
                }else{
                    let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
                    let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
                    let pages: CGFloat = 2 + 0.7
                    let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/pages), heightDimension: .fractionalWidth(1/pages))
                    let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitems: [bottomItem])
                    let section = NSCollectionLayoutSection(group: bottomGroup)
                    section.interGroupSpacing = 1
                    section.orthogonalScrollingBehavior = .continuous
                    return section
                }
        }, configuration: configuration)
        return layout
    }
    
    
    static var pageCarouselLayout: UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
            
        section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, environment in
            let rect = CGRect(origin: contentOffset, size: environment.container.contentSize)
            let visibleCells = visibleItems.filter {$0.representedElementCategory == .cell}
                visibleCells.forEach { cell in
                    let d = abs(rect.midX - cell.center.x)
                    let act = cell.frame.width / 2
                    let nd = d/act
                    let scale = 0.9 + 0.1*(1-abs(nd))
                    cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
           
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none //Key! https://stackoverflow.com/a/68475321/21419169
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
   
    
    
    static var threeItemHorizontalGridLayout: UICollectionViewLayout {
        
        let leftItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let leftItem = NSCollectionLayoutItem(layoutSize: leftItemSize)
        

        let leftGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.5/2.5),
                                                  heightDimension: .fractionalHeight(1))

        let leftGroup = NSCollectionLayoutGroup.horizontal(layoutSize: leftGroupSize,
                                                        subitems: [leftItem])
        leftGroup.contentInsets.trailing = 0.5
 
        let rightItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2))
        let rightItem = NSCollectionLayoutItem(layoutSize: rightItemSize)
     
        let rightGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2.5), heightDimension: .fractionalHeight(1))
    
        let rightGroup = NSCollectionLayoutGroup.vertical(layoutSize: rightGroupSize,
                                                        subitem: rightItem,
                                                        count: 2)
        rightGroup.interItemSpacing = .fixed(1)
        rightGroup.contentInsets.leading = 0.5
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                            heightDimension:  .fractionalWidth(2/2.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                    subitems: [leftGroup, rightGroup])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    static var threeItemVerticalGridLayout: UICollectionViewLayout {
        
        let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)

        let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1/1.75))

        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                       subitem: topItem, count: 1)
        topGroup.contentInsets.bottom = 0.5

        let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .fractionalWidth(1/2))
        let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
     
        let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.75/1.75))
    
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitem: bottomItem,count: 2)
        bottomGroup.interItemSpacing = .fixed(1)
        bottomGroup.contentInsets.top = 0.5

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(1.75/1.5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomGroup])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
}

//    private let tableViewLayout: UICollectionViewLayout = {
//        // To acheive a tableview dynamic height layout, make sure to:
//        // 1. use .estimated height dimension for BOTH NSCollectionLayoutItem and NSCollectionLayoutGroup
//        // 2. the group must be .horizontal not .vertical, so the group's heightDimension can be .estimated :)
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                  heightDimension: .estimated(300))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                   heightDimension: .estimated(300))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitem: item,
//              count: 1)
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 5
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }()
