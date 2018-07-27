//
//  PopoverTestViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

extension AlertView: PopoverViewProtocol {
    var popoverController: PopoverController {
        get {
            return self.controller
        }
        set(newValue) {
            self.controller = newValue
        }
    }
    
    func preferredSize(for popoverView: PopoverView, in controller: PopoverController) -> CGSize {
        let targetSize = CGSize(width: 300, height: UILayoutFittingExpandedSize.height)
        let size = popoverView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return size
    }
}

class PopoverTestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Popover"
        
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Show", for: .normal)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(didClickShowButton), for: .touchUpInside)
        self.view.addSubview(button)
        
        let button2 = UIButton()
        button2.setTitleColor(.blue, for: .normal)
        button2.setTitle("Show2", for: .normal)
        button2.sizeToFit()
        button2.center = button.center.applying(CGAffineTransform(translationX: 0, y: 50))
        button2.addTarget(self, action: #selector(didClickShow2Button), for: .touchUpInside)
        self.view.addSubview(button2)
    }
    
    @objc func didClickShowButton() {
        let vc = TextViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self.popover
        vc.preferredContentSize = CGSize(width: 200, height: 200)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func didClickShow2Button() {
        let view = AlertView()
        view.delegate = self
        let vc = PopoverController.instantiate(with: view)
        vc.show(in: self)
    }
    
    lazy var popover: Popover = {
        let p = Popover()
        return p
    }()
}
extension PopoverTestViewController: TextViewControllerDelegate {
    fileprivate func didClickCancleButton(viewController: TextViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension PopoverTestViewController: AlertViewDelegate {
    func didClickCancleButton(alertView: AlertView) {
        alertView.popoverController.dismiss(animated: true, completion: nil)
    }
    func didClickConfirmButton(alertView: AlertView) {
        alertView.popoverController.dismiss(animated: true, completion: nil)
    }
}


fileprivate protocol TextViewControllerDelegate: class {
    func didClickCancleButton(viewController: TextViewController)
}

fileprivate class TextViewController: UIViewController {
    weak var delegate: TextViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green
        
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.frame = self.view.bounds.divided(atDistance: 44, from: .maxYEdge).slice
        button.autoresizingMask = UIViewAutoresizing.flexibleTopMargin.union(.flexibleWidth)
        button.addTarget(self, action: #selector(didClickDissButton), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func didClickDissButton() {
        self.delegate?.didClickCancleButton(viewController: self)
    }
}
