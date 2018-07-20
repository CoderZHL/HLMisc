//
//  DateConvertDemo2ViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

protocol DateConvertDemo2ViewControllerDelegate: class {
    func dateConvertDemo2ViewController(_ viewController: DateConvertDemo2ViewController, convert date: Date, in timeZone: DateConvert.TimeZoneType) -> String?
    
    func dateForConvert(_ viewController: DateConvertDemo2ViewController) -> Date?
}

class DateConvertDemo2ViewController: UIViewController {

    @IBOutlet weak var gmtButton: UIButton!
    @IBOutlet weak var beijingButton: UIButton!
    @IBOutlet weak var systemZoneButton: UIButton!
    @IBOutlet weak var timeZoneTextFiled: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: DateConvertDemo2ViewControllerDelegate?
    
    private var timeZoneButtons: [UIButton] {
        return [self.gmtButton, self.beijingButton, self.systemZoneButton]
    }
    
    private var timeZoneType: DateConvert.TimeZoneType = .System {
        didSet {
            [self.gmtButton, self.beijingButton, self.systemZoneButton].forEach { (btn) in
                btn?.isEnabled = true
            }
            switch timeZoneType {
            case .Beijing:
                self.beijingButton.isEnabled = false
                self.timeZoneTextFiled.text = nil
            case .GMT:
                self.gmtButton.isEnabled = false
                self.timeZoneTextFiled.text = nil
            case .System:
                self.systemZoneButton.isEnabled = false
                self.timeZoneTextFiled.text = nil
            case .Custom(_): ()
            }
            self.timeZoneTextFiled.resignFirstResponder()
            self.textView.append(text: timeZoneType.timeZone.debugDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        self.didClickSystemZoneButton(self.systemZoneButton)
    }
    
    @IBAction func didClickGMTButton(_ sender: Any) {
        self.timeZoneType = .GMT
    }
    @IBAction func didClickBeijingButton(_ sender: Any) {
        self.timeZoneType = .Beijing
    }
    @IBAction func didClickSystemZoneButton(_ sender: Any) {
        self.timeZoneType = .System
    }
    @IBAction func didEidtTimeZoneTextField(_ sender: UITextField) {
        if let text = sender.text, let timeZone = TimeZone(identifier: text) {
            self.timeZoneType = .Custom(timeZone)
        } else {
            self.timeZoneTextFiled.text = nil
            self.textView.append(text: "时区ID错误！")
        }
    }
    @IBAction func didEditInputTextField(_ sender: UITextField) {
    }
    @IBAction func didClickConvert(_ sender: Any) {
        self.timeZoneTextFiled.resignFirstResponder()
        guard let date = self.delegate?.dateForConvert(self) else { return }
        guard let text = self.delegate?.dateConvertDemo2ViewController(self, convert: date, in: self.timeZoneType) else {
            return
        }
        
        self.textView.append(text: "日期：" + date.debugDescription + " :\n" + self.timeZoneType.timeZone.debugDescription + "时区的文本是 " + text)
    }

    @IBAction func didTapOnView(_ sender: Any) {
        self.timeZoneTextFiled.resignFirstResponder()
    }
}

extension DateConvertDemo2ViewController {
    static func instantiate() -> DateConvertDemo2ViewController {
        return UIStoryboard(name: "DateConvert", bundle: nil).instantiateViewController(withIdentifier: "DateConvertDemo2ViewController") as! DateConvertDemo2ViewController
    }
}
