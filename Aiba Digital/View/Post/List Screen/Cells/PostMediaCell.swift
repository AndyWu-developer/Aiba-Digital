//
//  PostMediaCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit
import Combine
import AVFoundation


protocol PostMediaCellDelegate: AnyObject{
    func mediaItemTapped(_ cell: PostMediaCell, mediaItem : UIView)
}
               

class PostMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var gridView: GridView!
    
    var player: AVPlayer?{
        didSet{
            
        }
    }
    
    func configure(with viewModel: PostMediaViewModel){
            
        
    }
    
    enum Mode {
        case view
        case edit
    }
    
    private var subscriptions = Set<AnyCancellable>()
    static let removeButtonTag = 111
    let maxHeightToWidthRatio: CGFloat = 4/3
    let minHeightToWidthRatio: CGFloat = 1/3
 
    var mode: Mode = .view {
        didSet{
            items.forEach { $0.viewWithTag(Self.removeButtonTag)?.isHidden = (mode == .view) }
        }
    }
    
    private var itemsInTopRow = 2
    
    var numberOfItemsOnTop: Int {
        get {
            itemsInTopRow
        }
        set {
            if items.count < 3 {
                itemsInTopRow = items.count
                updateLayout()
                return
            }

            if items.count == 3 {
                itemsInTopRow = 1
                updateLayout()
                return
            }
         
            if newValue < 1 {
                itemsInTopRow = 1
            }else if newValue > items.count/2 {
                itemsInTopRow = items.count
            }else {
                itemsInTopRow = 1
            }
            updateLayout()
        }
    }
    
    private var ratio = 0.0
    private var itemSizes: [(width: CGFloat, height: CGFloat)] = [(1920,1080)]

    var items: [UIView] = [] {
        didSet{
            itemsInTopRow = 1
            items.forEach(addRemoveButton)
            numberOfItemsOnTop = itemsInTopRow
        }
    }

    private var defaultHeightToWidthRatio: CGFloat {
        var ratio: CGFloat
        if itemsInTopRow == 1 {
            let bottomItems = items.count-1
            switch bottomItems {
            case 0 : ratio = 1
          //  case 1 : ratio = 2/3
            case 2 : ratio = 5/6
            case 3 : ratio = 2/3
            case 4... : ratio = 4.5/6
            default: ratio = 0
            }
        }else{
            ratio = 0
        }
        return ratio
    }

    func add(_ item: UIView, size: (width: Double, height: Double) = (1920.0,1080.0)){
//        itemSizes.append((1920,1680))
//        items.append(item)
    }
    
    func removeItem(at index: Int){
        print("remove item \(index)")
        items.remove(at: index)
    }
    
    func removeAll(){
        items.removeAll()
    }
    
    private func updateLayout() {
        subviews.forEach{ $0.removeFromSuperview() }
        guard !items.isEmpty else { return }
        
        let groupItems = [Array(items[0..<itemsInTopRow]), Array(items[itemsInTopRow..<items.count])].filter{!$0.isEmpty}
        let stackViews = groupItems.map(createScrollableStackView)
        
        
        let allStackView = newStackView(subviews: stackViews)
        allStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allStackView)
        NSLayoutConstraint.activate([
            allStackView.topAnchor.constraint(equalTo: topAnchor),
            allStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            allStackView.leftAnchor.constraint(equalTo: leftAnchor),
            allStackView.rightAnchor.constraint(equalTo: rightAnchor),
            allStackView.heightAnchor.constraint(lessThanOrEqualTo: widthAnchor,multiplier: maxHeightToWidthRatio)
        ])
        layoutIfNeeded()
    }
    
    private func createScrollableStackView(subviews: [UIView]) -> UIScrollView{
        subviews.forEach(addSquareConstraint) // must add constraint beforehand
        let sv = UIStackView(arrangedSubviews: subviews)
        //sv.arrangedSubviews.forEach(addSquareConstraint) won't work ???
        sv.spacing = 1
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(sv)
        
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            sv.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            sv.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            sv.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])
    
        if subviews.count < 4 {
            let bottomItems = items.count - itemsInTopRow
            ratio = bottomItems > 1 ? 1/Double(bottomItems) : 0
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }else {
            ratio = 1/(2+1/3)
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor,multiplier: ratio).isActive = true
        }
        return scrollView
    }
    
    private func newStackView(subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.spacing = 1
        if defaultHeightToWidthRatio != 0 {
            subviews[0].heightAnchor.constraint(equalTo: subviews[0].widthAnchor,multiplier: getLayoutRatio()).isActive = true
        }
        return stackView
    }
    
    private func addSquareConstraint(_ view : UIView){
        view.removeFromSuperview() //remove all constraints before adding new ones
        view.translatesAutoresizingMaskIntoConstraints = false
        let squareConstraint = view.widthAnchor.constraint(equalTo: view.heightAnchor)
        squareConstraint.priority = UILayoutPriority(999)
        squareConstraint.isActive = true
    }
    
    private func addRemoveButton(_ view: UIView){
        if view.viewWithTag(Self.removeButtonTag) != nil { return }
        let removeButton = UIButton()
        removeButton.tag = Self.removeButtonTag
        removeButton.isHidden = (mode == .view)
        let imageConfig = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage(systemName: "xmark")?.withTintColor(.white,renderingMode: .alwaysOriginal).withConfiguration(imageConfig)
        removeButton.setImage(image, for: .normal)
        removeButton.layer.cornerRadius = 13
        removeButton.backgroundColor = .black.withAlphaComponent(0.5)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(removeButton)
        view.isUserInteractionEnabled = true // otherwise the button cannot be touch if the view is an imageView :)
        NSLayoutConstraint.activate([
            removeButton.widthAnchor.constraint(equalToConstant: 26),
            removeButton.heightAnchor.constraint(equalToConstant: 26),
            removeButton.topAnchor.constraint(equalTo: view.topAnchor,constant: 5),
            removeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5)
        ])
     
        removeButton.publisher(for: .touchUpInside)
            .compactMap{ $0.superview }
            .compactMap{ [unowned self] in
                items.firstIndex(of:$0)
            }.sink { [unowned self] in
                removeItem(at: $0)
            }.store(in: &subscriptions)
    }
    
    private func getLayoutRatio() -> CGFloat {
        if let width = itemSizes.first?.width, let height = itemSizes.first?.height {
            let r = CGFloat(height) / CGFloat(width)
            let maxRatio = maxHeightToWidthRatio - ratio
            let minRatio = minHeightToWidthRatio
            return min(maxRatio, max(r, minRatio))
        }else{
            return defaultHeightToWidthRatio
        }
    }
    
}
