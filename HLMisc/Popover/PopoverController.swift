//
//  PopoverController.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

open class PopoverController: UIViewController {
    
    private var contentView: PopoverView!
    
    public var popover: Popover?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let size = self.contentView.preferredSize(for: self.contentView, in: self)
        self.contentView.frame = CGRect(origin: .zero, size: size)
        self.view.addSubview(self.contentView)
        self.preferredContentSize = size
    }
    deinit {
        print(self.self)
    }
    
    open func show(in viewContoller: UIViewController) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.popover ?? self._popover
        viewContoller.present(self, animated: true, completion: nil)
    }
    
    lazy var _popover: Popover = {
        let p = Popover()
        return p
    }()
}
extension PopoverController {
    open static func instantiate(with contentView: PopoverView) -> PopoverController {
        let vc = PopoverController()
        vc.contentView = contentView
        vc.contentView.popoverController = vc
        return vc
    }
}
