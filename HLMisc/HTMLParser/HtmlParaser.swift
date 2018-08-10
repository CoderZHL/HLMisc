//
//  HtmlParaser.swift
//  Forum
//
//  Created by 钟浩良 on 2018/3/1.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import Foundation

/// HTML内容数据
public struct HtmlTextModel {
    let kind: Kind
    let info: [ContentInfo: String]
}

extension HtmlTextModel {
    public enum Kind: Int {
        case text = 0
        case image
        case paragraph
        case strong
        case link
        case table
    }
    
    public enum ContentInfo: Int {
        case text = 0
        case link
        case userID
    }
}

/// HTML文本解析器
open class HtmlParser {
    public static let shared = HtmlParser()
    
    private init() {
    }
    
    open func parser(html: String, isRemoveContinuouslyNewLine: Bool = false) -> [HtmlTextModel] {
        let string = NSString(string: html)
        let reg = try! NSRegularExpression(pattern: Constant.tag_pattern, options: NSRegularExpression.Options.init(rawValue: 0))
        let results = reg.matches(in: html.lowercased(), options: .reportCompletion, range: NSMakeRange(0, string.length))
        var previousTag: String? = nil
        var htmlTextModels: [HtmlTextModel] = []
        
        if (results.isEmpty) {
            let t = string.replacingOccurrences(of: Constant.whitespace, with: " ")
            htmlTextModels.append(HtmlTextModel(kind: .text, info: [.text: t]))
        } else {
            var index = 0
            var currentOffset = -1
            for offset in 0 ..< results.count {
                guard offset > currentOffset else {
                    continue
                }
                currentOffset = offset
                
                var result = results[offset]
                var text = string.substring(with: NSMakeRange(index, result.range.location - index)).trimmingCharacters(in: .whitespacesAndNewlines)
                
                text = text.replacingOccurrences(of: Constant.whitespace, with: " ")
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let model = HtmlTextModel(kind: .text, info: [.text: text])
                    htmlTextModels.append(model)
                }
                
                let tag = string.substring(with: result.range)
                if tag.hasPrefix("<img") {
                    if let ranges = tag.range(of: "bf_img/in.gif"), !ranges.isEmpty {
                        let model = HtmlTextModel(kind: .text, info: [.text: "'"])
                        htmlTextModels.append(model)
                    } else {
                        if let model = self.parserImageText(string: String(tag)) {
                            htmlTextModels.append(model)
                        }
                    }
                } else if tag.hasPrefix("<p") || tag.hasPrefix("<br") {
                    if !(previousTag?.hasPrefix("<p") ?? false) {
                        if isRemoveContinuouslyNewLine {
                            if let content = htmlTextModels.last?.info[.text], content == "\n" {
                            } else {
                                htmlTextModels.append(HtmlTextModel(kind: .paragraph, info: [.text: "\n"]))
                            }
                        } else {
                            htmlTextModels.append(HtmlTextModel(kind: .paragraph, info: [.text: "\n"]))
                        }
                    }
                    
                } else if tag.hasPrefix("<a") {
                    let j = offset + 1
                    var newResult = result
                    var aString = ""
                    for i in j ..< results.count {
                        let re = results[i]
                        
                        let nextTag = string.substring(with: re.range)
                        
                        if let text = self.text(betweenTag: newResult, result2: re, in: string) {
                            aString.append(text)
                        }
                        newResult = re
                        if nextTag == "</a>" {
                            aString = aString.trimmingCharacters(in: .whitespacesAndNewlines)
                            aString = aString.replacingOccurrences(of: Constant.whitespace, with: " ")
                            
                            let model = self.aTagModel(tag: String(tag), text: aString)
                            htmlTextModels.append(model)
                            result = re
                            currentOffset = i
                            break
                        }
                    }
                } else if tag.hasPrefix("<strong") {
                    let j = offset + 1
                    var newResult = result
                    var strongStr = ""
                    
                    for i in j ..< results.count {
                        let re = results[i]
                        let nextTag = string.substring(with: re.range)
                        
                        if let text = self.text(betweenTag: newResult, result2: re, in: string) {
                            strongStr.append(text)
                        }
                        newResult = re
                        if nextTag.hasPrefix("<a") || nextTag.hasPrefix("<img") {
                            break
                        } else if nextTag == "</strong>" {
                            strongStr = strongStr.trimmingCharacters(in: .whitespacesAndNewlines)
                            strongStr = strongStr.replacingOccurrences(of: Constant.whitespace, with: " ")
                            
                            let model = HtmlTextModel(kind: .strong, info: [.text: strongStr])
                            htmlTextModels.append(model)
                            result = re
                            currentOffset = i
                            break
                        }
                    }
                } else if tag.hasPrefix("<table") {
                    let j = offset + 1
                    
                    for i in j ..< results.count {
                        let re = results[i]
                        let nextTag = string.substring(with: re.range)
                        
                        if nextTag == "</table>" {
                            if let text = self.text(betweenTag: result, result2: re, in: string), let model = self.tableTagModel(tag: String(tag), text: text) {
                                htmlTextModels.append(model)
                                result = re
                                currentOffset = i
                            }
                            
                            break
                        }
                    }
                }
                
                index = result.range.location + result.range.length
                
                if offset == results.count - 1 {
                    if var text = self.text(betweenTag: result, result2: nil, in: string)?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                        text = text.replacingOccurrences(of: Constant.whitespace, with: " ")
                        htmlTextModels.append(HtmlTextModel(kind: .text, info: [.text: text]))
                    }
                }
                
                previousTag = tag
            }
        }
        
        if isRemoveContinuouslyNewLine {
            htmlTextModels = self.removeContinuouslyParagraphModel(models: htmlTextModels)
        }
        return htmlTextModels
    }
    
    private func parserImageText(string: String) -> HtmlTextModel? {
        let reg = try! NSRegularExpression(pattern: Constant.imagePattern, options: NSRegularExpression.Options.init(rawValue: 0))
        let results = reg.matches(in: string, options: .reportCompletion, range: NSMakeRange(0, string.endIndex.encodedOffset))
        
        guard !results.isEmpty else {
            return nil
        }
        let range = results[0].range(at: 1)
        let source = string[Range<String.Index>(range, in: string)!]
        return HtmlTextModel(kind: .image, info: [.link: String(source)])
    }
    
    private func text(betweenTag result1: NSTextCheckingResult?, result2: NSTextCheckingResult?, in string: NSString) -> String? {
        let start = result1.map({ $0.range.location + $0.range.length }) ?? 0
        let lenght = result2.map({ $0.range.location - start }) ?? string.length - start
        return string.substring(with: NSMakeRange(start, lenght))
    }
    
    private func aTagModel(tag: String, text: String) -> HtmlTextModel {
        let reg = try! NSRegularExpression(pattern: Constant.atSomeOnePattern, options: NSRegularExpression.Options.init(rawValue: 0))
        let results = reg.matches(in: tag, options: .reportCompletion, range: NSMakeRange(0, tag.endIndex.encodedOffset))
        
        guard !results.isEmpty else {
            return HtmlTextModel(kind: .strong, info: [.text: text])
        }
        let range = results[0].range(at: 1)
        let userID = tag[Range<String.Index>(range, in: tag)!]
        return HtmlTextModel(kind: .link, info: [.userID: String(userID), .text: text])
    }
    
    private func tableTagModel(tag: String, text: String) -> HtmlTextModel? {
        let reg = try! NSRegularExpression(pattern: Constant.tableTagPattern, options: NSRegularExpression.Options.init(rawValue: 0))
        let results = reg.matches(in: tag, options: .reportCompletion, range: NSMakeRange(0, tag.endIndex.encodedOffset))
        
        guard !results.isEmpty else {
            return nil
        }
        
        return HtmlTextModel(kind: .table, info: [.text: text])
    }
    
    private func removeContinuouslyParagraphModel(models: [HtmlTextModel]) -> [HtmlTextModel] {
        var array: [HtmlTextModel] = []
        var continueCount = 0
        for model in models {
            if model.kind == .paragraph {
                if array.isEmpty {
                    continue
                }
                continueCount += 1
            } else {
                continueCount = 0
            }
            
            if continueCount > 2 {
                continue
            }
            
            if !array.isEmpty {
                switch model.kind {
                case .image:
                    if let last = array.last, last.kind == .paragraph {
                        array.remove(at: array.count - 1)
                    }
                case .paragraph:
                    if let last = array.last, last.kind == .image {
                        continue
                    }
                case .text, .link, .strong, .table:
                    ()
                }
            }
            
            array.append(model)
        }
        return array
    }
}

extension HtmlParser {
    struct Constant {
        static let tag_pattern = "<[^>]+?>"
        static let whitespace = "&nbsp;"
        static let imagePattern = "<img.+?src=\"(.*?)\".*?>"
        static let atSomeOnePattern = "<a[^>]+?href=\"[^\"]*?userid=(\\d+)[^>]*?>"
        static let tableTagPattern = "<table[^>]*?class=\"mytable\"[^>]*?>"
    }
}

extension Array where Element == HtmlTextModel {
    public func asText() -> String {
        return self.reduce("") { (result, textModel) -> String in
            var temp = result
            if let text = textModel.info[.text] {
                temp.append(text)
            }
            return temp
        }
    }
}
