//
//  DateConvert.swift
//  DateConvert
//
//  Created by kevin on 2017/4/18.
//  Copyright © 2017年 bet007. All rights reserved.
//

import UIKit

open class DateConvert {
    public enum TimeZoneType {
        case GMT
        case Beijing
        case System
        case Custom(TimeZone)
    }
    
    static var dateFormatter: DateFormatter {
        if let formatter = Thread.current.threadDictionary["cachedDateFormatter"] as? DateFormatter {
            return formatter
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        Thread.current.threadDictionary.setValue(formatter, forKey: "cachedDateFormatter")
        return formatter
    }
    
    /*
        字符串转为Date：
            - string： 日期字符串
            - timeZoneOfString: 字符串的时区
            - format： 字符串格式
            - formatLocale： 日期格式
         例如： 当string = “2018 01 01 00 00 00”， format = “yyyy MM dd HH mm ss”时，
                    timeZoneOfString设为GMT，则返回Date：2018-01-01 00:00:00 +0000；
                    timeZoneOfString设为Beijing，则返回Date: 2017-12-31 16:00:00 +0000;
     */
    
    public static func date(from string: String, timeZoneOfString: TimeZoneType = .System, format: String, formatLocale: Locale = Locale(identifier: "en_US")) -> Date? {
        dateFormatter.timeZone = timeZoneOfString.timeZone
        dateFormatter.dateFormat = format
        dateFormatter.locale = formatLocale
        return dateFormatter.date(from: string)
    }
    
    /*
     Date转为字符串：
     - date： 日期
     - timeZoneOffset: 指定输出字符串的时区
     - format： 字符串格式
     - formatLocale： 日期格式
     例如： 当date = 2018-01-01 00:00:00 +0000， format = “yyyy MM dd HH mm ss”时，
     timeZoneOffset设为GMT，则返回Date：2018-01-01 00:00:00 +0000；
     timeZoneOffset设为Beijing，则返回Date: 2018-01-01 00:08:00 +0000;
     */
    
    public static func string(from date: Date, timeZoneOffset: TimeZoneType = .System, format: String, formatLocale: Locale = Locale(identifier: "en_US")) -> String {
        dateFormatter.timeZone = timeZoneOffset.timeZone
        dateFormatter.dateFormat = format
        dateFormatter.locale = formatLocale
        return dateFormatter.string(from: date)
    }
    
    public static func components(of date: Date, timeZone: TimeZoneType = .System) -> DateComponents {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents(in: timeZone.timeZone, from: date)
        return components
    }
    
    /* 输出指定日期零点的GMT时间 */
    public static func zero(of day: Date) -> Date {
        return self.date(atHour: 0, min: 0, sec: 0, day: day)
    }
    
    /* 输出在某日期指定的时分秒GMT时间 */
    public static func date(atHour hour: Int, min: Int, sec: Int, day: Date) -> Date {
        let timeZone = TimeZoneType.System
        var components = self.components(of: day, timeZone: timeZone)
        components.hour = hour
        components.minute = min
        components.second = sec
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let ts = floor((calendar.date(from: components)?.timeIntervalSince1970)!) + Double(timeZone.timeZone.secondsFromGMT())
        return Date(timeIntervalSince1970: ts)
    }
    
    /*
     输出指定时区零点时刻的GMT时间 ：
     例如： 当day = 2018-01-01 00:00:00 +0000 时，
     zone设为GMT，则返回Date：2018-01-01 00:00:00 +0000；
     zone设为Beijing，则返回Date: 2017-12-31 16:00:00 +0000;
     */
    public static func zoneZero(of day: Date, inTimeZone zone: TimeZoneType = .System) -> Date {
        return self.zoneDate(atHour: 0, min: 0, sec: 0, day: day, inTimeZone: zone)
    }
    
    /*
     输出指定时区某个时刻的GMT时间 ：
     例如： 当hour = 10， min = 0， sec = 0， day = 2018-01-01 00:00:00 +0000 时，
     zone设为GMT，则返回Date：2018-01-01 10:00:00 +0000；
     zone设为Beijing，则返回Date: 2018-01-01 02:00:00 +0000;
     */
    public static func zoneDate(atHour hour: Int, min: Int, sec: Int, day: Date, inTimeZone zone: TimeZoneType = .System) -> Date {
        var components = self.components(of: day, timeZone: zone)
        components.hour = hour
        components.minute = min
        components.second = sec
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let ts = floor((calendar.date(from: components)?.timeIntervalSince1970)!)
        return Date(timeIntervalSince1970: ts)
    }
}

extension DateConvert.TimeZoneType {
    public var timeZone: TimeZone {
        switch self {
        case .GMT:
            return TimeZone(secondsFromGMT: 0)!
        case .Beijing:
            return TimeZone(identifier: "Asia/Shanghai")!
        case .Custom(let timeZone):
            return timeZone
        case .System:
            return TimeZone.current
        }
    }
}

public func isBefore(hour: Int, minute: Int) -> Bool {
    let criticalTime = DateConvert.date(atHour: hour, min: minute, sec: 0, day: Date())
    return Date().timeIntervalSince(criticalTime) < 0
}

public func isZoneBefore(hour: Int, minute: Int, inTimeZone timeZone: DateConvert.TimeZoneType = .System) -> Bool {
    let criticalTime = DateConvert.zoneDate(atHour: hour, min: minute, sec: 0, day: Date(), inTimeZone: .GMT).addingTimeInterval(TimeInterval(-1 * timeZone.timeZone.secondsFromGMT()))
    return Date().timeIntervalSince(criticalTime) < 0
}
