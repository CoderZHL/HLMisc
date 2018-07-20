//
//  DropDownMenuDemoViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class DropDownMenuDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func clickButton(_ sender: UIButton, event: UIEvent) {
        dropDownMenu.show(in: self, anchorView: sender)
    }
    
    @IBAction func clickButtonItem(_ sender: UIBarButtonItem, event: UIEvent) {
        let item1 = DropDownItem(title: "123", isSelected: true, info: nil, isRedPoint: true, selectedColor: UIColor.orange)
        let item2 = DropDownItem(title: "456", isSelected: true, info: nil, isRedPoint: false)
        let vc = DropDownMenuViewController.instance(with: [item1, item2])
        vc.cellHeight = 100
        vc.menuWidth = 50
        vc.menuColor = UIColor.yellow
        vc.menuSelectedColor = UIColor.blue
        vc.textColor = UIColor.green
        vc.textFont = UIFont.boldSystemFont(ofSize: 18)
        vc.itemSeparatorColor = UIColor.red
        vc.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vc.borderColor = UIColor.black
        vc.borderWidth = 1
        vc.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        vc.show(in: self, touchEvent: event)
    }
    
    lazy var dropDownMenu: DropDownMenuViewController = {
        let item1 = DropDownItem(title: "123", info: nil, isRedPoint: true)
        let item2 = DropDownItem(title: "456", info: nil, isRedPoint: false)
        let vc = DropDownMenuViewController.instance(with: [item1, item2])
        vc.cellHeight = 100
        vc.menuWidth = 50
        vc.menuColor = UIColor.yellow
        vc.textColor = UIColor.green
        vc.textFont = UIFont.boldSystemFont(ofSize: 18)
        vc.itemSeparatorColor = UIColor.red
        vc.delegate = self
        return vc
    }()
}

extension DropDownMenuDemoViewController: DropDownMenuViewControllerDelegate {
    func dropDownMenu(_ viewController: DropDownMenuViewController, didSelect item: DropDownItem) {
        print(item)
    }
}

extension DropDownMenuDemoViewController {
    static func instantiate() -> DropDownMenuDemoViewController {
        return UIStoryboard(name: "DropDownMenu", bundle: nil).instantiateViewController(withIdentifier: "DropDownMenuDemoViewController") as! DropDownMenuDemoViewController
    }
}
