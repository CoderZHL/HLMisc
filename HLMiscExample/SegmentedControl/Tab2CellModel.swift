
//
//  Tab2CellModel.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/20.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

protocol Tab2CellModelProtocol {
    var title: String { get }
    var isShowBadge: Bool { get set }
    var isSelected: Bool { get set }
}

struct Tab2CellModel: Tab2CellModelProtocol {
    let title: String
    var isShowBadge: Bool
    var isSelected: Bool
}
