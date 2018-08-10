//
//  HtmlParserView.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/10.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

///  html内容视图
open class HtmlParserView: UIView {
    private weak var delegate: HtmlParserViewDelegate?
    
    let lineSpacing: CGFloat
    
    let emojiSize: CGSize
    
    let textColor: UIColor?
    
    public var imageURLs: [URL] {
        return self.subviews.reduce([], { (result, view) -> [URL] in
            if view.isKind(of: ImageButton.self), let url = (view as! ImageButton).url {
                var r = result
                r.append(url)
                return r
            } else {
                return result
            }
        })
    }
    
    var heightConstraintOfButton: [UIButton: NSLayoutConstraint] = [:]
    
    public init?(contents: [HtmlTextModel], textFontSize: CGFloat = 16, textColor: UIColor? = nil, lineSpacing: CGFloat = 2, emojiSize: CGSize = CGSize(width: 22, height: 22), delegate: HtmlParserViewDelegate?) {
        self.textColor = textColor
        self.lineSpacing = lineSpacing
        self.emojiSize = emojiSize
        self.delegate = delegate
        super.init(frame: .zero)
        
        var views = [UIView]()
        var attributedString = NSMutableAttributedString()
        contents.forEach { (htmlModel) in
            switch htmlModel.kind {
            case .text, .paragraph:
                if let text = htmlModel.info[.text] {
                    let start = attributedString.length
                    let newStr = NSAttributedString(string: text)
                    attributedString.append(newStr)
                    attributedString.addAttributes([.font: UIFont.systemFont(ofSize: textFontSize)], range: NSMakeRange(start, newStr.length))
                }
            case .image:
                if attributedString.length > 0 {
                    let label = self.createLabel(for: attributedString)
                    self.addLabel(label: label, topView: views.last)
                    views.append(label)
                    attributedString = NSMutableAttributedString()
                }
                if let _ = htmlModel.info[.link] {
                    let button = ImageButton()
                    self.addImageButton(button: button, topView: views.last)
                    button.delegate = self
                    button.config(with: htmlModel)
                    views.append(button)
                }
            case .strong:
                if let text = htmlModel.info[.text] {
                    let start = attributedString.length
                    let newStr = NSAttributedString(string: text)
                    attributedString.append(newStr)
                    attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: textFontSize)], range: NSMakeRange(start, newStr.length))
                }
            case .link:
                if let text = htmlModel.info[.text] {
                    let start = attributedString.length
                    let newStr = NSAttributedString(string: text)
                    attributedString.append(newStr)
                    attributedString.addAttributes([.font: UIFont.systemFont(ofSize: textFontSize)], range: NSMakeRange(start, newStr.length))
                }
            case .table:
                if attributedString.length > 0 {
                    let label = self.createLabel(for: attributedString)
                    self.addLabel(label: label, topView: views.last)
                    views.append(label)
                    attributedString = NSMutableAttributedString()
                }
            }
        }
        
        if attributedString.length > 0 {
            let label = self.createLabel(for: attributedString)
            self.addLabel(label: label, topView: views.last)
            views.append(label)
        }
        
        if let lastView = views.last {
            self.addConstraint(NSLayoutConstraint(item: lastView, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        } else {
            return nil
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLabel(label: UILabel, topView: UIView?) {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        let insets = self.delegate?.htmlParserView(self, label: label, edgenInsetsToTopView: topView) ?? .zero
        if let topView = topView {
            constraints.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: insets.top))
        } else {
            constraints.append(NSLayoutConstraint(item: label, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
        }
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[label]-\(insets.right)-|", options: .init(rawValue: 0), metrics: nil, views: ["label": label]))
        self.addConstraints(constraints)
    }
    
    private func createLabel(for string: NSMutableAttributedString) -> UILabel {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = self.lineSpacing
        string.addAttributes([NSAttributedStringKey.paragraphStyle: paragraph], range: NSMakeRange(0, string.length))
        let label = UILabel()
        label.attributedText = string
        label.numberOfLines = 0
        label.textColor = self.textColor
        return label
    }
    
    private func addImageButton(button: ImageButton, topView: UIView?) {
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        let insets = self.delegate?.htmlParserView(self, imageButton: button, edgenInsetsToTopView: topView) ?? .zero
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[button]-\(insets.right)-|", options: .init(rawValue: 0), metrics: nil, views: ["button": button]))
        if let topView = topView {
            constraints.append(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: insets.top))
        } else {
            constraints.append(NSLayoutConstraint(item: button, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
        }
        let cons = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        button.addConstraint(cons)
        self.heightConstraintOfButton[button] = cons
        self.addConstraints(constraints)
    }
}

extension HtmlParserView: ImageButtonDelegate {
    fileprivate func onTapImageButton(_ button: ImageButton) {
        self.delegate?.htmlParserView(self, onTapImage: button.url)
    }
    
    fileprivate func didLoadImage(imageButton button: ImageButton) {
        // 按钮高度没有根据图片尺寸来正确布局尺寸，所以需要代码计算。原因未知
        DispatchQueue.main.async {
            if let image = button.imageView?.image, let cons = self.heightConstraintOfButton[button] {
                if image.size.width > button.frame.width {
                    cons.constant = image.size.height / image.size.width * button.frame.width
                } else {
                    cons.constant = image.size.height
                }
            }
            self.delegate?.didLoadImages(HtmlParserView: self)
        }
    }
    
    fileprivate func imageButton(_ button: ImageButton, setImageURLString string: String, completion: @escaping (UIImage?, Error?, URL?) -> Void) {
        self.delegate?.htmlParserView(self, setButton: button, imageURLString: string, completion: completion)
    }
}

// MARK: - HtmlParserViewDelegate

public protocol HtmlParserViewDelegate: class {
    func didLoadImages(HtmlParserView view: HtmlParserView)
    
    func htmlParserView(_ view: HtmlParserView, onTapImage imageURL: URL?)
    
    func htmlParserView(_ view: HtmlParserView, setButton button: UIButton, imageURLString: String, completion: @escaping (UIImage?, Error?, URL?) -> Void)
    
    func htmlParserView(_ view: HtmlParserView, imageButton: UIButton, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets
    
    func htmlParserView(_ view: HtmlParserView, label: UILabel, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets
    
    func htmlParserView(_ view: HtmlParserView, attributedStringWithContent content: String) -> NSAttributedString
}

extension HtmlParserViewDelegate {
    func htmlParserView(_ view: HtmlParserView, imageButton: UIButton, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    func htmlParserView(_ view: HtmlParserView, label: UILabel, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    func htmlParserView(_ view: HtmlParserView, attributedStringWithContent content: String) -> NSAttributedString {
        return NSAttributedString(string: content)
    }
}

/// 图片元素
fileprivate class ImageButton: UIButton {
    weak var delegate: ImageButtonDelegate?
    
    var url: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.addTarget(self, action: Selector.imageButtonDidTapAction, for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with model: HtmlTextModel) {
        if let str = model.info[.link] {
            self.delegate?.imageButton(self, setImageURLString: str, completion: { [weak self] (image, _, url) in
                guard let _ = image, let `self` = self else { return }
                self.url = url
                self.delegate?.didLoadImage(imageButton: self)
            })
        }
    }
    
    @objc func didOnTapSelf(button: UIButton) {
        self.delegate?.onTapImageButton(self)
    }
}

// MARK: - ImageButtonDelegate

fileprivate protocol ImageButtonDelegate: class {
    func didLoadImage(imageButton button: ImageButton)
    
    func onTapImageButton(_ button: ImageButton)
    
    func imageButton(_ button: ImageButton, setImageURLString string: String, completion: @escaping (UIImage?, Error?, URL?) -> Void)
}

extension Selector {
    fileprivate static let imageButtonDidTapAction = #selector(ImageButton.didOnTapSelf(button:))
}

extension NSLayoutConstraint {
    convenience init(item: Any, toItem: Any, attribute: NSLayoutAttribute, multiplier: CGFloat = 0, constant: CGFloat = 0) {
        self.init(item: item, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: attribute, multiplier: multiplier, constant: constant)
    }
}
