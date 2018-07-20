//
//  DateConvertDemoViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

protocol DateConvertDemoViewControllerDelegate: class {
    func dateConvertDemoViewController(_ viewController: DateConvertDemoViewController, convert text: String, format: String, in timeZone: DateConvert.TimeZoneType) -> Date?
}

class DateConvertDemoViewController: UIViewController {
    @IBOutlet weak var gmtButton: UIButton!
    @IBOutlet weak var beijingButton: UIButton!
    @IBOutlet weak var systemZoneButton: UIButton!
    @IBOutlet weak var timeZoneTextFiled: UITextField!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: DateConvertDemoViewControllerDelegate?
    
    var date: Date? = nil
    
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
        guard let text = self.inputTextField.text, !text.isEmpty, let date = self.delegate?.dateConvertDemoViewController(self, convert: text, format: "yyyyMMddHHmmss", in: self.timeZoneType) else {
            return
        }
        self.date = date
        self.textView.append(text: self.timeZoneType.timeZone.debugDescription + "时间-" + text + " :\n" + date.debugDescription)
    }
    @IBAction func didTapOnView(_ sender: Any) {
        self.timeZoneTextFiled.resignFirstResponder()
    }
}

extension DateConvertDemoViewController {
    static func instantiate() -> DateConvertDemoViewController {
        return UIStoryboard(name: "Date", bundle: nil).instantiateViewController(withIdentifier: "DateConvertDemoViewController") as! DateConvertDemoViewController
    }
}

extension UITextView {
    func append(text: String) {
        self.text = self.text + "\n" + text
        self.scrollRangeToVisible(NSMakeRange(0, self.text.count))
    }
}
