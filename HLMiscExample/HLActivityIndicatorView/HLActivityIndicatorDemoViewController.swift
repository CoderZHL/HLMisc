//
//  HLActivityIndicatorDemoViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/20.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class HLActivityIndicatorDemoViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicatorView: HLActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        self.indicatorView.backgroundColor = nil
        self.indicatorView.color = UIColor.brown
        self.indicatorView.delegate = self
    }

}

extension HLActivityIndicatorDemoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorView.updatePercent(with: scrollView.contentOffset.y)
    }
}

extension HLActivityIndicatorDemoViewController {
    static func instantiate() -> HLActivityIndicatorDemoViewController {
        let vc = UIStoryboard(name: "HLActivityIndicatorView", bundle: nil).instantiateViewController(withIdentifier: "HLActivityIndicatorDemoViewController") as! HLActivityIndicatorDemoViewController
        return vc
    }
}

extension HLActivityIndicatorDemoViewController: HLActivityIndicatorViewDelegate {
    func startAnimating(activityIndicatorView: HLActivityIndicatorView) {
        var inset = self.scrollView.contentInset
        inset.top += 50
        self.scrollView.contentInset = inset
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.indicatorView.stopAnimating(topInset: 50)
        }
    }
    
    func stopAnimating(activityIndicatorView: HLActivityIndicatorView) {
        var inset = self.scrollView.contentInset
        inset.top -= 50
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentInset = inset
        }) { (_) in
            self.scrollView.setContentOffset(self.scrollView.contentOffset, animated: false)
        }
    }
    
    
}
