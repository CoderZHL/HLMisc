//
//  DateConvertDemoMainViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class DateConvertDemoMainViewController: UIViewController {
    
    var demo1ViewController: DateConvertDemoViewController!
    var demo2ViewController: DateConvertDemo2ViewController!
    var demo3ViewController: DateConvertDemo3ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .some("Demo1"):
            self.demo1ViewController = segue.destination as! DateConvertDemoViewController
            self.demo1ViewController.delegate = self
        case .some("Demo2"):
            self.demo2ViewController = segue.destination as! DateConvertDemo2ViewController
            self.demo2ViewController.delegate = self
        case .some("Demo3"):
            self.demo3ViewController = segue.destination as! DateConvertDemo3ViewController
            self.demo3ViewController.delegate = self
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension DateConvertDemoMainViewController: DateConvertDemoViewControllerDelegate {
    func dateConvertDemoViewController(_ viewController: DateConvertDemoViewController, convert text: String, format: String, in timeZone: DateConvert.TimeZoneType) -> Date? {
        return DateConvert.date(from: text, timeZoneOfString: timeZone, format: format)
    }
}

extension DateConvertDemoMainViewController: DateConvertDemo2ViewControllerDelegate {
    func dateForConvert(_ viewController: DateConvertDemo2ViewController) -> Date? {
        return self.demo1ViewController.date
    }
    
    func dateConvertDemo2ViewController(_ viewController: DateConvertDemo2ViewController, convert date: Date, in timeZone: DateConvert.TimeZoneType) -> String? {
        return DateConvert.string(from: date, timeZoneOffset: timeZone, format: "yyyyMMddHHmmss")
    }
}

extension DateConvertDemoMainViewController: DateConvertDemo3ViewControllerDelegate {
    func DateConvertDemo3ViewController(_ viewController: DateConvertDemo3ViewController, convertHour hour: Int, minute: Int, second: Int, at date: Date, in timeZone: DateConvert.TimeZoneType) -> Date? {
        return DateConvert.zoneDate(atHour: hour, min: minute, sec: second, day: date, inTimeZone: timeZone)
    }
}

extension DateConvertDemoMainViewController {
    static func instantiate() -> DateConvertDemoMainViewController {
        return UIStoryboard(name: "Date", bundle: nil).instantiateViewController(withIdentifier: "DateConvertDemoMainViewController") as! DateConvertDemoMainViewController
    }
}
