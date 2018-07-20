//
//  FeedbackGenerator.swift
//  OfficialAccounts
//
//  Created by 钟浩良 on 2018/3/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

/// 创建枚举
public enum FeedbackType: Int {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case none
}

/// 创建类方法，随时调用
public func impactFeedback(style: FeedbackType) {
    
    if #available(iOS 10.0, *) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        default:
            break
        }
        
    }
    
}
