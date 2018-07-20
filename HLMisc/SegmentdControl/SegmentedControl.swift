//
//  SegmentCollectionView.swift
//  Forum
//
//  Created by 钟浩良 on 2018/6/5.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

open class SegmentedControl<Item>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public weak var collectionView: UICollectionView!
    
    public var items: [Item] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    public var cellForModel: ((UICollectionView, IndexPath, Item) -> UICollectionViewCell)!
    
    public var selectedIndexDidChange: ((UICollectionView, IndexPath, Item) -> Void)? = nil
    
    public init(with collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.cellForModel(collectionView, indexPath, self.items[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexDidChange?(collectionView, indexPath, self.items[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let colums: CGFloat = CGFloat(self.items.count)
        let width = (collectionView.bounds.size.width - insets.left - insets.right - (colums - 1) * itemSpacing) / colums
        return CGSize(width: width, height: collectionView.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}
