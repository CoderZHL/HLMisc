//
//  HTMLParserDemoViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/8/10.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class HTMLParserDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let currentBundle = Bundle(for: HTMLParserDemoViewController.self)
        let htmlPath = currentBundle.path(forResource: "test", ofType: "html")!
        let htmlContent = try! String.init(contentsOfFile: htmlPath, encoding: .utf8)
        print(htmlContent)
        
        let textModels = HtmlParser.shared.parser(html: htmlContent, isRemoveContinuouslyNewLine: true)
        if let contentView = HtmlParserView(contents: textModels, delegate: nil) {
            self.view.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 10))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v]-10-|", options: .init(rawValue: 0), metrics: nil, views: ["v": contentView]))
        }
    }
}
