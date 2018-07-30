//
//  PopoverTest2ViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

protocol AlertViewDelegate: class {
    func didClickCancleButton(alertView: AlertView)
    func didClickConfirmButton(alertView: AlertView)
}

class AlertView: EasyLayoutView {
    weak var delegate: AlertViewDelegate?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.setupUIs()
    }
    deinit {
        print(self.self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIs() {
        let header = UILabel()
        header.text = "Alert title!"
        header.textAlignment = .center
        header.backgroundColor = .lightGray
        self.addView(header, topView: nil, topMargin: 5, leadingMargin: 5, trailingMargin: 5, height: 35, in: nil)
        
        let body = UILabel()
        body.text = "Alert message"
        body.textAlignment = .center
        self.addView(body, topView: header, topMargin: 5, leadingMargin: 5, trailingMargin: 5, height: 80, in: nil)
        
        let footer = UIView()
        footer.backgroundColor = .lightGray
        self.addView(footer, topView: body, topMargin: 3, leadingMargin: 0, trailingMargin: 0, height: 40, in: nil)
        self.setupSubviewsLastBottomConstraint(in: self)
        
        let cancleButton = UIButton()
        cancleButton.setTitle("cancel", for: .normal)
        self.addView(cancleButton, leadingView: nil, leadingMargin: 0, in: footer)
        let confirmButton = UIButton()
        confirmButton.setTitle("confirm", for: .normal)
        self.addView(confirmButton, leadingView: cancleButton, leadingMargin: 0, in: footer)
        footer.addConstraint(NSLayoutConstraint(item: cancleButton, attribute: .width, relatedBy: .equal, toItem: confirmButton, attribute: .width, multiplier: 1, constant: 0))
        self.setupSubviewsLastTrainingConstraint(in: footer)
        
        cancleButton.addTarget(self, action: #selector(self.didClickCancleButton), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.didClickConfirmButton), for: .touchUpInside)
    }
    
    @objc func didClickCancleButton() {
        self.delegate?.didClickCancleButton(alertView: self)
    }
    
    @objc func didClickConfirmButton() {
        self.delegate?.didClickConfirmButton(alertView: self)
    }
}
