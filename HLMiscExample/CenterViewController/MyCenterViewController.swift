//
//  MyCenterViewController.swift
//  HLUIsExample
//
//  Created by 钟浩良 on 2018/5/16.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class MyCenterViewController: CenterViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func instantiatePagingViews(_ viewController: CenterViewController) -> [UIView] {
        let v = MyView()
        v.backgroundColor = .red
        return [ContentTableView(), ContentTableView(), v]
    }
    
    override func headerView(CenterViewController viewController: CenterViewController) -> HLPagingHeaderView {
        return CustomHeaderView()
    }
}

class MyView: UIView {
    
}
