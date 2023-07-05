//
//  EditPostViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/19.
//

import UIKit
import Combine

class EditPostViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    var placeholderLabel: UILabel!
    enum Section { case main, sub }
    var textViewHeight: CGFloat?
    private var subscriptions = Set<AnyCancellable>()
    private var keyboardHeight: CGFloat = .zero
    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>!
  
    private var first = true
    private let viewModel: EditPostViewModel
    
    private lazy var accessoryView = EditAccessoryView()
    
    private var selectedAccessoryButton: UIButton? {
        didSet{
            oldValue?.isSelected = false
            selectedAccessoryButton?.isSelected = true
        }
    }
    
    private lazy var photoPickerViewController: UIInputViewController = {
        let viewModel = self.viewModel.pickerViewModel
        let inputViewController = PhotoPickerInputViewController(viewModel: viewModel)
        return inputViewController
    }()

    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
    override var inputViewController: UIInputViewController?{
        return selectedAccessoryButton === accessoryView.photoButton ? photoPickerViewController : nil
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
 
    init(viewModel: EditPostViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    private lazy var addPhotoBackgroundView: UIView = {
        let backgroundView = Bundle.main.loadNibNamed( "CollectionViewBackgroundView", owner : nil)!.first as! UIView // owner has to be self or will error
        let tap = UITapGestureRecognizer()
        backgroundView.addGestureRecognizer(tap)
        tap.publisher()
            .sink { [unowned self] _ in
                selectedAccessoryButton = accessoryView.photoButton
            }.store(in: &subscriptions)
        return backgroundView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewDataSource()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        bindViewModelInput()
        configureTextView()
        configureButtonActions()
        configureKeyboardActions()
   
     //   textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        textView.delegate = self
        textView.placeholder = "想說些什麼？"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout")
        if first{
            becomeFirstResponder() // show the input accessory view
            first = false
        }
        
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight != 0 {
            collectionView.backgroundView = nil
            collectionViewHeightConstraint.constant = contentHeight
        }else{
            collectionView.backgroundView = addPhotoBackgroundView
            collectionViewHeightConstraint.constant = 150
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedAccessoryButton = accessoryView.keyboardButton
    }

    private func configureCollectionViewDataSource(){
        
        let cellRegistration = UICollectionView.CellRegistration<MediaPickerPreviewCell, MediaPickerCellViewModel>(cellNib: UINib(nibName: String(describing: MediaPickerPreviewCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>(collectionView: collectionView) { collectionView, indexPath, viewModel in
            return collectionView.dequeueConfiguredReusableCell(using:  cellRegistration, for: indexPath, item: viewModel)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section,MediaPickerCellViewModel>()
        snapshot.appendSections([.main, .sub])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindViewModelInput(){
        
        dismissButton.publisher(for:.touchUpInside)
            .map{_ in}
            .bind(to: viewModel.input.cancelPosting)
            .store(in: &subscriptions)
        
        postButton.publisher(for:.touchUpInside)
            .map{_ in}
            .bind(to: viewModel.input.finishPosting)
            .store(in: &subscriptions)
        
        viewModel.output.selectedMediaViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModels in
                guard let self else { return }
                var oldSnapshot = dataSource.snapshot()
                
                
                if cellViewModels.count < oldSnapshot.numberOfItems {
                    print("delete")
                    let deletedItems = Set(oldSnapshot.itemIdentifiers).subtracting(Set(cellViewModels))
                    oldSnapshot.deleteItems(Array(deletedItems))

                    if oldSnapshot.numberOfItems > 4, oldSnapshot.itemIdentifiers(inSection: .main).count == 0{
                        let item = oldSnapshot.itemIdentifiers(inSection: .sub).first!
                        oldSnapshot.deleteItems([item])
                        oldSnapshot.appendItems([item], toSection: .main)
                    }

                    if oldSnapshot.numberOfItems <= 4, oldSnapshot.itemIdentifiers(inSection: .sub).count != 0{
                        print("here")
                        let items = oldSnapshot.itemIdentifiers(inSection: .sub)

                        oldSnapshot.deleteItems(items)
                        dataSource.apply(oldSnapshot,animatingDifferences: false)
                        oldSnapshot = dataSource.snapshot()
                        oldSnapshot.appendItems(items, toSection: .main)
                    }
                }

                else if cellViewModels.count > oldSnapshot.numberOfItems {

                    print("added")
                    let addedItems = Set(cellViewModels).subtracting(Set(oldSnapshot.itemIdentifiers))


                    if oldSnapshot.numberOfItems == 4 {
                        var items = Array(oldSnapshot.itemIdentifiers(inSection: .main).dropFirst(1))
                        oldSnapshot.deleteItems(items)
                        items += addedItems
                        oldSnapshot.appendItems(items, toSection: .sub)
                    }

                    if oldSnapshot.numberOfItems > 4 {
                        oldSnapshot.appendItems(Array(addedItems), toSection: .sub)
                    }

                    if oldSnapshot.numberOfItems < 4 {
                        oldSnapshot.appendItems(Array(addedItems), toSection: .main)
                    }
                }

                var layout: UICollectionViewLayout
               
                switch oldSnapshot.numberOfItems{
                case 0:
                    layout = .oneItemGridLayout
                case 1:
                    layout = .oneItemGridLayout
                case 2:
                    layout = .squareGridLayout(itemsPerRow: 2)
                case 3:
                    let item = cellViewModels.first!
                    if item.contentPixelHeight > item.contentPixelWidth {
                        layout = .threeItemHorizontalGridLayout
                    }else{
                        layout = .threeItemVerticalGridLayout
                    }
                case 4:
                    layout = .squareGridLayout(itemsPerRow: 2)
                default:
                    layout = .scrollableGridLayout()
                }
                
                collectionView.setCollectionViewLayout(layout, animated: true)
                dataSource.apply(oldSnapshot,animatingDifferences: true)
                view.setNeedsLayout()
            //    collectionView.scrollToItem(at: I, at: .left, animated: true)
                scrollView.contentOffset.y = -scrollView.adjustedContentInset.top
            }.store(in: &subscriptions)
    }
    
    
    private func configureKeyboardActions(){
    
        NotificationCenter.default.publisher(for: UITextView.keyboardWillShowNotification)
            .sink { [unowned self] in
                let keyboard = $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let screen = view.window!.windowScene!.screen
                let keyboardInView = screen.coordinateSpace.convert(keyboard, to: view)
                let overlapHeight = keyboardInView.intersection(view.bounds).height
    
                scrollView.contentInset.bottom = overlapHeight + 40
                scrollView.verticalScrollIndicatorInsets.bottom = overlapHeight
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [unowned self] _ in
                scrollView.contentInset.bottom = 0
                scrollView.verticalScrollIndicatorInsets.bottom = 0
                //  textView.invalidateIntrinsicContentSize()
            }
            .store(in: &subscriptions)
        
        //        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        //            .sink { [unowned self] in
        //                let keyboard = $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        //                let duration = $0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        //                let curveValue = $0.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        //                let screen = view.window!.windowScene!.screen.bounds
        //
        //                if keyboard.minY < screen.maxY { //show
        //
        //                    keyboardConstraint.constant = view.bounds.maxY - keyboard.minY
        //                    print(view.bounds.maxY - keyboard.minY)
        //                    keyboardHeight = view.bounds.maxY - keyboard.minY
        //                }else{
        //                    keyboardConstraint.constant = 0
        //                    keyboardHeight = 0
        //                }
        //
        //                UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curveValue)){
        //                    self.view.layoutIfNeeded()
        //                }
        //            }
        //            .store(in: &subscriptions)
    }
    
    
    private func configureButtonActions(){
        
        let accessoryViewButtons = [accessoryView.photoButton, accessoryView.keyboardButton]
        
        accessoryViewButtons.forEach { button in
            button?.publisher(for: .touchUpInside)
                .sink { [unowned self] button in
                    selectedAccessoryButton = button.isSelected ? nil : button
                }
                .store(in: &subscriptions)
        }
        
        accessoryView.photoButton.publisher(for: \.isSelected)
            .sink { [unowned self] isSelected in
                accessoryView.photoButton.tintColor = isSelected ? .darkYellow : .black
                reloadInputViews()
            }
            .store(in: &subscriptions)
    
        accessoryView.keyboardButton.publisher(for: \.isSelected)
            .sink { [unowned self] isSelected in
                accessoryView.keyboardButton.tintColor = isSelected ? .darkYellow : .black
                _ = isSelected ? textView.becomeFirstResponder() : textView.resignFirstResponder()
            }
            .store(in: &subscriptions)
        
        dismissButton.publisher(for:.touchUpInside)
            .sink { [unowned self] button in
                resignFirstResponder()
            }
            .store(in: &subscriptions)
    }
    
    private func configureTextView(){
        //textView.textContainer.lineFragmentPadding = .zero // will create unwanted right space
        textView.textContainerInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        textView.layoutManager.usesFontLeading = false
        textView.contentInsetAdjustmentBehavior = .never
        // textView.inputAccessoryView = inputAccessoryView
   
        NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification)
            .compactMap{
                let tv = $0.object as? UITextView
                return tv
            }
            .filter{ [unowned self] in $0 === textView }
            .map{ $0!.text }
            .prepend(textView.text)
            .bind(to: viewModel.input.text)
            .store(in: &subscriptions)
    }
}


extension EditPostViewController: UITextViewDelegate{

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //calculate height of the textView before user starts typing
        let fittingSize = textView.sizeThatFits(CGSize(width: textView.contentSize.width, height: .greatestFiniteMagnitude))
        textViewHeight = fittingSize.height
        
        if selectedAccessoryButton != accessoryView.keyboardButton {
            selectedAccessoryButton = accessoryView.keyboardButton
        }
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        //calculate the textViewHeight after user starts typing
        let fittingSize = textView.sizeThatFits(CGSize(width: textView.contentSize.width, height: .greatestFiniteMagnitude))
        if textViewHeight != fittingSize.height {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            textViewHeight = fittingSize.height
        }
        
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
   
}
