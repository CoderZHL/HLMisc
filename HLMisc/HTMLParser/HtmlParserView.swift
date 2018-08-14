//
//  HtmlParserView.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/10.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

///  html内容视图
open class HtmlParserView: UIView {
    private weak var delegate: HtmlParserViewDelegate!
    /// 是否代码计算图片尺寸，当图片加载完成的时候
    public var calculateImageSizeWhenDidLoad = true
    
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
    
    public var identifier: String {
        return self._identifier
    }
    
    private var _identifier: String
    
    var heightConstraintOfButton: [UIButton: NSLayoutConstraint] = [:]
    
    public init?(contents: [HtmlTextModel], delegate: HtmlParserViewDelegate?, identifier: String) {
        self._identifier = identifier
        super.init(frame: .zero)
        self.delegate = delegate ?? self
        
        var views = [UIView]()
        var attributedString = NSMutableAttributedString()
        contents.forEach { (htmlModel) in
            switch htmlModel.kind {
            case .text, .paragraph:
                if let text = htmlModel.info[.text] {
                    let newStr = self.delegate.htmlParserView(self, attributedStringWithContent: text, kind: htmlModel.kind)
                    attributedString.append(newStr)
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
                    let newStr = self.delegate.htmlParserView(self, attributedStringWithContent: text, kind: .strong)
                    attributedString.append(newStr)
                }
            case .link:
                if let text = htmlModel.info[.text] {
                    let newStr = self.delegate.htmlParserView(self, attributedStringWithContent: text, kind: .link)
                    attributedString.append(newStr)
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
        let insets = self.delegate.htmlParserView(self, label: label, edgenInsetsToTopView: topView)
        if let topView = topView {
            constraints.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: insets.top))
        } else {
            constraints.append(NSLayoutConstraint(item: label, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
        }
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[label]-\(insets.right)-|", options: .init(rawValue: 0), metrics: nil, views: ["label": label]))
        self.addConstraints(constraints)
    }
    
    private func createLabel(for string: NSMutableAttributedString) -> UILabel {
        if let paragraph = self.delegate.htmlParserView(self, paragraphStyleForContent: string) {
            string.addAttributes([NSAttributedStringKey.paragraphStyle: paragraph], range: NSMakeRange(0, string.length))
        }
        let label = UILabel()
        label.attributedText = string
        label.numberOfLines = 0
        return label
    }
    
    private func addImageButton(button: ImageButton, topView: UIView?) {
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        let insets = self.delegate.htmlParserView(self, imageButton: button, edgenInsetsToTopView: topView)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[button]-\(insets.right)-|", options: .init(rawValue: 0), metrics: nil, views: ["button": button]))
        if let topView = topView {
            constraints.append(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: insets.top))
        } else {
            constraints.append(NSLayoutConstraint(item: button, toItem: self, attribute: .top, multiplier: 1, constant: insets.top))
        }
        if self.calculateImageSizeWhenDidLoad {
            let cons = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            button.addConstraint(cons)
            self.heightConstraintOfButton[button] = cons
        }
        self.addConstraints(constraints)
    }
}

extension HtmlParserView: ImageButtonDelegate {
    fileprivate func onTapImageButton(_ button: ImageButton) {
        self.delegate.htmlParserView(self, onTapImage: button.url)
    }
    
    fileprivate func didLoadImage(imageButton button: ImageButton) {
        if let cons = self.heightConstraintOfButton[button] {
            DispatchQueue.main.async {
                if let image = button.imageView?.image {
                    if image.size.width > button.frame.width {
                        cons.constant = image.size.height / image.size.width * button.frame.width
                    } else {
                        cons.constant = image.size.height
                    }
                }
                self.delegate.didLoadImages(HtmlParserView: self)
            }
        } else {
            self.delegate.didLoadImages(HtmlParserView: self)
        }
    }
    
    fileprivate func imageButton(_ button: ImageButton, setImageURLString string: String, completion: @escaping (UIImage?, Error?, URL?) -> Void) {
        self.delegate.htmlParserView(self, setButton: button, imageURLString: string, completion: completion)
    }
    
    fileprivate func initializeImageButton(_ button: ImageButton) {
        self.delegate.htmlParserView(self, initializeImageButton: button)
    }
}

extension HtmlParserView: HtmlParserViewDelegate {
    public func didLoadImages(HtmlParserView view: HtmlParserView) {}
    
    public func htmlParserView(_ view: HtmlParserView, onTapImage imageURL: URL?) {}
    
    public func htmlParserView(_ view: HtmlParserView, setButton button: UIButton, imageURLString: String, completion: @escaping (UIImage?, Error?, URL?) -> Void) {}
    
    public func htmlParserView(_ view: HtmlParserView, imageButton: UIButton, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    public func htmlParserView(_ view: HtmlParserView, initializeImageButton button: UIButton) {}
    
    public func htmlParserView(_ view: HtmlParserView, label: UILabel, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    public func htmlParserView(_ view: HtmlParserView, attributedStringWithContent content: String, kind: HtmlTextModel.Kind) -> NSAttributedString {
        return NSMutableAttributedString(string: content, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)])
    }
    
    public func htmlParserView(_ view: HtmlParserView, paragraphStyleForContent content: NSAttributedString) -> NSParagraphStyle? {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        return style
    }
}

// MARK: - HtmlParserViewDelegate

public protocol HtmlParserViewDelegate: class {
    func didLoadImages(HtmlParserView view: HtmlParserView)
    
    func htmlParserView(_ view: HtmlParserView, onTapImage imageURL: URL?)
    
    func htmlParserView(_ view: HtmlParserView, setButton button: UIButton, imageURLString: String, completion: @escaping (UIImage?, Error?, URL?) -> Void)
    
    func htmlParserView(_ view: HtmlParserView, imageButton: UIButton, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets
    
    func htmlParserView(_ view: HtmlParserView, initializeImageButton button: UIButton)
    
    func htmlParserView(_ view: HtmlParserView, label: UILabel, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets
    
    func htmlParserView(_ view: HtmlParserView, attributedStringWithContent content: String, kind: HtmlTextModel.Kind) -> NSAttributedString
    
    
    func htmlParserView(_ view: HtmlParserView, paragraphStyleForContent content: NSAttributedString) -> NSParagraphStyle?
}

extension HtmlParserViewDelegate {
    func htmlParserView(_ view: HtmlParserView, imageButton: UIButton, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    func htmlParserView(_ view: HtmlParserView, label: UILabel, edgenInsetsToTopView topView: UIView?) -> UIEdgeInsets {
        return topView == nil ? UIEdgeInsets.zero : UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    func htmlParserView(_ view: HtmlParserView, attributedStringWithContent content: String, kind: HtmlTextModel.Kind) -> NSAttributedString {
        return NSMutableAttributedString(string: content, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)])
    }
    
    func htmlParserView(_ view: HtmlParserView, paragraphStyleForContent content: NSAttributedString) -> NSParagraphStyle? {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        return style
    }
}

/// 图片元素
fileprivate class ImageButton: UIButton {
    weak var delegate: ImageButtonDelegate? {
        didSet {
            self.delegate?.initializeImageButton(self)
        }
    }
    
    var url: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func initializeImageButton(_ button: ImageButton)
}

extension Selector {
    fileprivate static let imageButtonDidTapAction = #selector(ImageButton.didOnTapSelf(button:))
}

extension NSLayoutConstraint {
    convenience init(item: Any, toItem: Any, attribute: NSLayoutAttribute, multiplier: CGFloat = 0, constant: CGFloat = 0) {
        self.init(item: item, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: attribute, multiplier: multiplier, constant: constant)
    }
}
