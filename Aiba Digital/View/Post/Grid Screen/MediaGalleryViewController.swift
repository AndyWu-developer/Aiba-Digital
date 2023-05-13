//
//  MediaGalleryViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/22.
//

import UIKit
import Combine

class MediaGalleryViewController: UIViewController,ImageViewerTransitionViewControllerConvertible {
    
    var sourceView: UIView?
    var targetView: UIView?
    
    
    var start = false
    private let viewModel = MediaGalleryViewModel()
    private var embeddedPageViewController: UIPageViewController!
    var currentPageIndex: Int! = 0
    private let pageSpacing = 30
    
    let pan = UIPanGestureRecognizer()
    
    private var currentViewController: MediaZoomViewController {
        return self.embeddedPageViewController.viewControllers![0] as! MediaZoomViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
      
        extendedLayoutIncludesOpaqueBars = true //underlapped tabbar even it's isTranslucent = false
    }

    private func setupPageViewController(){
        
        embeddedPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal,options: [.interPageSpacing : pageSpacing])
        embeddedPageViewController.dataSource = self
        embeddedPageViewController.delegate = self
        addChild(embeddedPageViewController)
        embeddedPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(embeddedPageViewController.view, at: 0)
        NSLayoutConstraint.activate([
            embeddedPageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            embeddedPageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            embeddedPageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            embeddedPageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        embeddedPageViewController.didMove(toParent: self)

        
        guard let currentPageIndex else { return }
        let pageVC = MediaZoomViewController()
        pageVC.pageIndex = currentPageIndex
        embeddedPageViewController.setViewControllers([pageVC], direction: .forward, animated: false)
    }
}

extension MediaGalleryViewController: UIPageViewControllerDataSource {
    //A .scroll style page view controller may cache some of its view controllers in advance. Therefore you should make no assumptions about when these data source methods will be called. If you need to be notified when the user is actually turning the page, use the delegate, not the data source.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       
        let currentIndex = (viewController as! MediaZoomViewController).pageIndex
        let nextIndex = currentIndex - 1
        if nextIndex < 0 || nextIndex > 4 { return nil }
        let pageVC = MediaZoomViewController()
        pageVC.pageIndex = nextIndex
        return pageVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       
        let currentIndex = (viewController as! MediaZoomViewController).pageIndex
        let nextIndex = currentIndex + 1
        if nextIndex < 0 || nextIndex > 4 { return nil }
        let pageVC = MediaZoomViewController()
        pageVC.pageIndex = nextIndex
        pageVC.delegate = self
        return pageVC
    }
}

extension MediaGalleryViewController: UIPageViewControllerDelegate{
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

           guard finished, let currentPageController = pageViewController.viewControllers?.last as? MediaZoomViewController else {
               return
           }
           
           currentPageIndex = currentPageController.pageIndex
           
           print(currentPageIndex!)
       }
}

extension MediaGalleryViewController: MediaZoomViewControllerDelegate{
    func zoomViewZoomed(_ vc: MediaZoomViewController) {
        
    }
    
    func zoomViewTapped(_ vc: MediaZoomViewController) {
        
    }
}

extension MediaGalleryViewController: UIGestureRecognizerDelegate {
    
    
    
   
}


class MediaGalleryViewModel{
    
    func getMediaViewModel(at index: Int) -> MediaViewModel?{
        if index < 0 || index > 4 { return nil }
        let url = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fbike%20(1).png?alt=media&token=743bbd8e-8fe9-4a1f-82ee-e351d580334a"
        let ext = ".jpg"
        let viewModel = MediaViewModel(url: url, fileExtension: ext)
        return viewModel
    }
    
}
