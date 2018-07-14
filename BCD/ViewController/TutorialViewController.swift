//
//  TutorialViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 19/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet weak var bottomConsOfBackButton: NSLayoutConstraint!
    private var pageController = UIPageViewController()
    private let pageImages = [#imageLiteral(resourceName: "tut1"), #imageLiteral(resourceName: "tut2"), #imageLiteral(resourceName: "tut3"), #imageLiteral(resourceName: "tut4"), #imageLiteral(resourceName: "tut5"), #imageLiteral(resourceName: "tut6"), #imageLiteral(resourceName: "tut7"), #imageLiteral(resourceName: "tut8")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = view.bounds.size
        
        pageController = storyboard?.instantiateViewController(withIdentifier: "page") as! TutorialPageViewController
        pageController.dataSource = self
        let viewControllers = [viewControllerAt(index: 0)]
        pageController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        pageController.view.frame = CGRect(x: 0, y: 20, width: size.width, height: size.height - 60)
        
        if UIDevice().isiPhoneX {
            // for iPhone X
            pageController.view.frame = CGRect(x: 0, y: -10, width: size.width, height: size.height - 20)
            bottomConsOfBackButton.constant = 20.0
            view.layoutIfNeeded()
        }
        
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        view.bringSubview(toFront: closeButton)
    }
    
    private func viewControllerAt(index: Int) -> TutorialContentViewController {
        if index >= pageImages.count {
            return TutorialContentViewController()
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "content") as! TutorialContentViewController
        vc.image = pageImages[index]
        vc.index = index
        
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialContentViewController
        let index = vc.index
        
        if index == 0 {
            return nil
        }
        
        return viewControllerAt(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialContentViewController
        let index = vc.index
        
        if index == pageImages.count - 1 {
            return nil
        }
        
        return viewControllerAt(index: index + 1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }
}
