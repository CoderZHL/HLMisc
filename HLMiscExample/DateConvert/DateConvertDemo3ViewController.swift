//
//  DateConvertDemo3ViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

protocol DateConvertDemo3ViewControllerDelegate: class {
    func DateConvertDemo3ViewController(_ viewController: DateConvertDemo3ViewController, convertHour hour: Int, minute: Int, second: Int, at date: Date, in timeZone: DateConvert.TimeZoneType) -> Date?
}

class DateConvertDemo3ViewController: UIViewController {
    struct Model {
        var hour: Int?
        var min: Int?
        var sec: Int?
    }
    
    @IBOutlet weak var gmtButton: UIButton!
    @IBOutlet weak var beijingButton: UIButton!
    @IBOutlet weak var systemZoneButton: UIButton!
    @IBOutlet weak var timeZoneTextFiled: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: DateConvertDemo3ViewControllerDelegate?
    
    private var model: Model = Model(hour: nil, min: nil, sec: nil)
    
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
            self.view.endEditing(true)
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
    @IBAction func didEditHourTextField(_ sender: UITextField) {
        self.model.hour = sender.text.flatMap({ Int($0) })
    }
    @IBAction func didEditMinuteTextField(_ sender: UITextField) {
        self.model.min = sender.text.flatMap({ Int($0) })
    }
    @IBAction func didEditSecondTextField(_ sender: UITextField) {
        self.model.sec = sender.text.flatMap({ Int($0) })
    }
    
    @IBAction func didEditInputTextField(_ sender: UITextField) {
    }
    @IBAction func didClickConvert(_ sender: Any) {
        self.view.endEditing(true)
        guard let hour = self.model.hour, let min = self.model.min, let sec = self.model.sec else {
            return
        }
        let now = Date()
        let date = self.delegate?.DateConvertDemo3ViewController(self, convertHour: hour, minute: min, second: sec, at: now, in: self.timeZoneType)
        
        let str1 = "日期：" + now.debugDescription + "这天在" + self.timeZoneType.timeZone.debugDescription + "时区的\(hour)时\(min)分\(sec)秒的Date是 "
        self.textView.append(text: str1 + " :\n" + (date?.debugDescription ?? "nil"))
    }
    
    @IBAction func didTapOnView(_ sender: Any) {
        self.view.endEditing(true)
    }
}

extension DateConvertDemo3ViewController {
    static func instantiate() -> DateConvertDemo3ViewController {
        return UIStoryboard(name: "DateConvert", bundle: nil).instantiateViewController(withIdentifier: "DateConvertDemo3ViewController") as! DateConvertDemo3ViewController
    }
}
