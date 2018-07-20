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
