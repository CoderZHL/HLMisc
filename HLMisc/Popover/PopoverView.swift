//
//  PopoverView.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

public protocol PopoverViewProtocol {
    func preferredSize(for popoverView: PopoverView, in controller: PopoverController) -> CGSize
    var popoverController: PopoverController { get set }
}

public typealias PopoverView = UIView & PopoverViewProtocol
