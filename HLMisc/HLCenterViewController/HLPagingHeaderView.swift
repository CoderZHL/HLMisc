//
//  HLPagingHeaderView.swift
//  HupuHomePage
//
//  Created by 钟浩良 on 2018/5/16.
//  Copyright © 2018年 肇庆市华盈体育文化发展有限公司. All rights reserved.
//

import UIKit

public protocol HLPagingHeaderViewProtocol: class {
    /// 视图高度
    var height: CGFloat { get }
    /// 停留高度
    var stuckHeight: CGFloat { get }
    /// 当前页码
    var selectedIndex: Int { get set }
    /// 页码变化
    var didChangeSelectedIndexHanlder: ((Int) -> ())? { get }
}

open class HLPagingHeaderView: UIView, HLPagingHeaderViewProtocol {
    open var height: CGFloat {
        return 150
    }
    
    open var stuckHeight: CGFloat {
        return 30
    }
    
    open var selectedIndex: Int = 0
    
    open var didChangeSelectedIndexHanlder: ((Int) -> ())? = nil
}
