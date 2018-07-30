//
//  PopoverView.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

public protocol PopoverViewProtocol {
    func preferredSize(for popoverView: PopoverView, in controller: PopoverController) -> CGSize
}

extension PopoverViewProtocol {
    public var popoverController: PopoverController? {
        get {
            return objc_getAssociatedObject(self, &associatedKeys.popoverController) as? PopoverController
        }
        set {
            objc_setAssociatedObject(self, &associatedKeys.popoverController, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

public typealias PopoverView = UIView & PopoverViewProtocol

struct associatedKeys {
    static var popoverController = "popoverController_associatedKey"
}
