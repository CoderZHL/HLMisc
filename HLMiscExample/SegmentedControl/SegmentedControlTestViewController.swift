//
//  TestViewController.swift
//  Forum
//
//  Created by 钟浩良 on 2018/6/5.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

public class SegmentedControlTestViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    var segmentedControl: SegmentedControl<String>!
    
    var segementedControl2: SegmentedControl<Tab2CellModelProtocol>!
    
    var cellModels: [Tab2CellModelProtocol] = [] {
        didSet {
            self.segementedControl2.items = cellModels
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSegmented()
        self.setupSegmented2()
    }
    
    private func setupSegmented() {
        self.segmentedControl = SegmentedControl<String>(with: self.collectionView)
        
        self.segmentedControl.cellForModel = { collectionView, indexPath, text in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TabCell
            cell.label.text = text
            return cell
        }
        
        self.segmentedControl.selectedIndexDidChange = { collectionView, indexPath, item in
            print(indexPath, item)
        }
        
        self.segmentedControl.items = ["1", "2"]
    }
    
    private func setupSegmented2() {
        self.segementedControl2 = SegmentedControl<Tab2CellModelProtocol>(with: self.collectionView2)
        
        self.segementedControl2.cellForModel =  { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Tab2Cell
            cell.label.text = model.title
            cell.badgeView.isHidden = !model.isShowBadge
            cell.backgroundColor = model.isSelected ? UIColor.brown : UIColor.cyan
            return cell
        }
        self.segementedControl2.selectedIndexDidChange = { [unowned self] collectionView, indexPath, model in
            var arr = [Tab2CellModelProtocol]()
            self.cellModels.enumerated().forEach({ (offset, item) in
                var t = item
                t.isSelected = offset == indexPath.item
                arr.append(t)
            })
            self.cellModels = arr
        }
        
        self.cellModels = [Tab2CellModel(title: "比分", isShowBadge: false, isSelected: true), Tab2CellModel(title: "赛程", isShowBadge: false, isSelected: false), Tab2CellModel(title: "关注", isShowBadge: true, isSelected: false)]
    }
}

extension SegmentedControlTestViewController {
    public static func instantiate() -> SegmentedControlTestViewController {
        let vc = UIStoryboard(name: "SegmentedControl", bundle: nil).instantiateViewController(withIdentifier: "SegmentedControlTestViewController") as! SegmentedControlTestViewController
        return vc
    }
}
