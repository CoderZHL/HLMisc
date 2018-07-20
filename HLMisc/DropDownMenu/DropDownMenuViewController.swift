//
//  DropDownMenuViewController.swift
//  Popover
//
//  Created by 钟浩良 on 2017/11/20.
//  Copyright © 2017年 钟浩良. All rights reserved.
//

import UIKit

@objc public class DropDownItem: NSObject {
    @objc public var title: String?
    @objc public var info: Any?
    @objc public var isRedPoint: Bool
    @objc public var selectedColor: UIColor?
    @objc public var isSelected: Bool

    
    @objc public init(title: String? = nil, isSelected: Bool = false, info: Any? = nil, isRedPoint: Bool = false, selectedColor: UIColor? = nil) {
        self.title = title
        self.info = info
        self.isRedPoint = isRedPoint
        self.selectedColor = selectedColor
        self.isSelected = isSelected
    }
}

@objc
public protocol DropDownMenuViewControllerDelegate: class {
    func dropDownMenu(_ viewController: DropDownMenuViewController, didSelect item: DropDownItem)
}

public class DropDownMenuViewController: UIViewController {
    
    /// 菜单项目
    @objc public var items: [DropDownItem] = []
    /// 项目高度
    @objc public var cellHeight: CGFloat = 50.0
    /// 菜单宽度
    @objc public var menuWidth: CGFloat = 150.0
    /// 字体
    @objc public var textFont: UIFont?
    /// 字体颜色
    @objc public var textColor: UIColor?
    /// 分割线颜色
    @objc public var itemSeparatorColor: UIColor?
    /// 菜单颜色
    @objc public var menuColor: UIColor = UIColor.white
    /// 菜单被选定的颜色
    @objc public var menuSelectedColor: UIColor?
    /// 菜单显示动画时长
    @objc public var presentingDuratioin: TimeInterval = 0.25
    /// 菜单消失动画时长
    @objc public var dismissingDuration: TimeInterval = 0.25
    /// 背景颜色
    @objc public var backgroundColor: UIColor?
    /// 箭头附加偏移
    @objc public var arrowXoffset: CGFloat = 0
    /// 表单内边距
    @objc public var padding: UIEdgeInsets = .zero
    /// 内边框颜色
    @objc public var paddingColor: UIColor = UIColor.white
    /// 边框宽度
    @objc public var borderWidth: CGFloat = 0
    /// 边框颜色
    @objc public var borderColor: UIColor = UIColor.white
    /// 箭头尺寸
    @objc public var arrowSize: CGSize = CGSize(width: 14, height: 7)

    /// 下拉菜单代理
    @objc public weak var delegate: DropDownMenuViewControllerDelegate?
    
    private var _arrowOffsetX: CGFloat = 0
    
    private var tableView: UITableView!
    
    private var arrowImageView: UIImageView?
    
    private var totalWidth: CGFloat {
        return self.menuWidth + self.padding.left + self.padding.right
    }
    
    private var totoalHeight: CGFloat {
        return (CGFloat(self.items.count) * self.cellHeight) + self.arrowSize.height + self.padding.bottom + self.padding.top
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupUI() {
        self.view.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        //  列表夫视图
        let contentView = UIView()
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = self.borderWidth
        contentView.layer.borderColor = self.borderColor.cgColor
        self.view.addSubview(contentView)
        // 列表
        self.tableView = UITableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = menuColor
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        contentView.addSubview(tableView!)
        contentView.backgroundColor = self.paddingColor
        // 箭头
        let arrowImage = drawArrowImage(with: self.arrowSize)
        let imageView = UIImageView(image: arrowImage)
        self.view.addSubview(imageView)
        self.arrowImageView = imageView
        // 布局
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView!.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["arrow":imageView, "content": contentView]
        var xOfArrow = (menuWidth - self.arrowSize.width) / 2
        if #available(iOS 11.0, *) { // arrowOffset 在iOS 11以下计算错误，原因未知
            xOfArrow += _arrowOffsetX
        }
        xOfArrow += arrowXoffset
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(xOfArrow)-[arrow(\(imageView.bounds.size.width))]",
            options: .init(rawValue: 0),
            metrics: nil,
            views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[content]-0-|",
                                                                options: .init(rawValue: 0),
                                                                metrics: nil,
                                                                views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[arrow]",
            options: .init(rawValue: 0),
            metrics: nil,
            views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(self.arrowSize.height)-[content]-0-|",
            options: .init(rawValue: 0),
            metrics: nil,
            views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(self.padding.left)-[table]-\(self.padding.right)-|",
            options: .init(rawValue: 0),
            metrics: nil,
            views: ["table": self.tableView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(self.padding.top)-[table]-\(self.padding.bottom)-|",
            options: .init(rawValue: 0),
            metrics: nil,
            views: ["table": self.tableView]))
        
        // 设置图层铆点
        self.view.layer.anchorPoint = CGPoint(x: xOfArrow / self.totalWidth, y: 0)
    }
    
    lazy var popoverAnimator: PopoverAnimator = {
        let animator = PopoverAnimator()
        animator.delegate = self
        return animator
    }()
}

// MARK: - PopoverAnimatorDelegate

extension DropDownMenuViewController: PopoverAnimatorDelegate {
    func transitionDuration(for popoverAnimator: PopoverAnimator, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresent ? presentingDuratioin : dismissingDuration
    }
    
    func popoverAnimator(_ popoverAnimator: PopoverAnimator, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            guard let toView = transitionContext.view(forKey: .to) else { return }
            toView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            transitionContext.containerView.addSubview(toView)
            let alphaOfCoverView = popoverAnimator.presentationController?.coverView.alpha ?? 1
            popoverAnimator.presentationController?.coverView.alpha = 0
            if let color = self.backgroundColor {
                popoverAnimator.presentationController?.coverView.backgroundColor = color
            }
            UIView.animate(withDuration: popoverAnimator.transitionDuration(using: transitionContext), animations: {
                toView.transform = CGAffineTransform.identity
                popoverAnimator.presentationController?.coverView.alpha = alphaOfCoverView
            }, completion: { (_) in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromView = transitionContext.view(forKey: .from)
            UIView.animate(withDuration: popoverAnimator.transitionDuration(using: transitionContext), animations: {
                fromView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                fromView?.alpha = 0.01
                transitionContext.containerView.subviews.filter({ $0 !== fromView }).forEach({ (view) in
                    view.alpha = 0
                })
            }, completion: { (_) in
                fromView?.alpha = 1
                transitionContext.completeTransition(true)
            })
        }
    }
}

// MARK: - UITableViewDataSource

extension DropDownMenuViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as? DropDownCell
        if cell == nil {
            cell = DropDownCell(style: .default, reuseIdentifier: "DropDownCell")
            cell?.titleFont = textFont
            cell?.titleColor = textColor
            cell?.separatorColor = itemSeparatorColor
            cell?.selectedColor = self.menuSelectedColor
        }
        
        let model = items[indexPath.row]
        cell!.config(with: model)
        cell?.isShowSeparator = items.count != indexPath.row + 1
        return cell!
    }
}

// MARK: - UITableViewDelegate

extension DropDownMenuViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.dropDownMenu(self, didSelect: items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
        dismiss(animated: false, completion: nil)
    }
}

// MARK: - Instantiation

extension DropDownMenuViewController {
    @objc public static func instance(with items: [DropDownItem]) -> DropDownMenuViewController {
        let vc = DropDownMenuViewController()
        vc.items = items
        return vc
    }
}

// MARK: - show

extension DropDownMenuViewController {
    @objc public func show(in viewController: UIViewController, anchorView: UIView) {
        guard let window = UIApplication.shared.keyWindow else { return }
        let rect = anchorView.convert(anchorView.bounds, to: window)

        popoverAnimator.presentFrame = calculatPreferredFrame(with: rect)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = popoverAnimator
        
        setupUI()
        viewController.present(self, animated: true, completion: nil)
    }
    
    @objc public func show(in viewController: UIViewController, touchEvent: UIEvent) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let view = touchEvent.allTouches?.first?.view else { return }
        let rect = view.convert(view.frame, to: window)

        popoverAnimator.presentFrame = calculatPreferredFrame(with: rect)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = popoverAnimator

        setupUI()
        viewController.present(self, animated: true, completion: nil)
    }
    
    /// 计算位置和尺寸
    private func calculatPreferredFrame(with anchorRect: CGRect) -> CGRect {
        func preferredFrame(for point: CGPoint) -> CGRect {
            return CGRect(origin: point, size: CGSize(width: self.totalWidth,
                                                      height: self.totoalHeight))
        }
        
        guard let window = UIApplication.shared.keyWindow else { return .zero }
        let x = anchorRect.origin.x + anchorRect.size.width / 2 - self.totalWidth / 2
        let y = anchorRect.maxY
        var presentFrame = preferredFrame(for: CGPoint(x: x, y: y))
        
        // 计算菜单的frame，限制菜单与显示范围的边缘保持最小10pt间距，箭头指向始终保持在anchorView底部中间
        _arrowOffsetX = 0
        let margin: CGFloat = 10
        let d = presentFrame.maxX - window.bounds.size.width + margin
        if d > 0 {
            presentFrame = preferredFrame(for: CGPoint(x: x - d, y: y))
            _arrowOffsetX = d
        }
        
        let d2 = presentFrame.minX - margin
        if d2 < 0 {
            presentFrame = preferredFrame(for: CGPoint(x: presentFrame.origin.x - d2, y: y))
            _arrowOffsetX = _arrowOffsetX + d2
        }
        return presentFrame
    }
}

extension DropDownMenuViewController {
    /// 生成箭头图片
    private func drawArrowImage(with size: CGSize) -> UIImage {
        // 根据边框宽度，计算里面的箭头向下偏移的距离，从而形成边框效果
        func contentArrowOffsetY(by arrowSize: CGSize) -> CGFloat {
            var t = 2 * arrowSize.height / arrowSize.width
            t = sqrt(1 + t * t)
            return t * self.borderWidth
        }
        let offsetY = contentArrowOffsetY(by: size)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height + offsetY), false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let ctx = UIGraphicsGetCurrentContext()!
        UIColor.clear.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height + offsetY))
        // 外箭头
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: size.width / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: size.width, y: size.height))
        arrowPath.addLine(to: CGPoint(x: 0, y: size.height))
        arrowPath.closeSubpath()
        ctx.addPath(arrowPath)
        ctx.setFillColor(self.borderColor.cgColor)
        ctx.drawPath(using: .fill)
        // 内箭头
        let contentArrowPath = CGMutablePath()
        contentArrowPath.move(to: CGPoint(x: size.width / 2, y: offsetY))
        contentArrowPath.addLine(to: CGPoint(x: size.width, y: size.height + offsetY))
        contentArrowPath.addLine(to: CGPoint(x: 0, y: size.height + offsetY))
        contentArrowPath.closeSubpath()
        ctx.addPath(contentArrowPath)
        let color = (self.padding.top - self.borderWidth) <= 0 ? self.menuColor.cgColor : self.paddingColor.cgColor
        ctx.setFillColor(color)
        ctx.drawPath(using: .fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image!
    }
}

// MARK: - DropDownCell

class DropDownCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    
    private var redPoint: UIView!
    
    private var separatorView: UIView!
    
    /// 字体
    var titleFont: UIFont? = UIFont.systemFont(ofSize: 15) {
        didSet {
            if let font = titleFont {
                titleLabel.font = font
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 15)
            }
        }
    }
    /// 字体颜色
    var titleColor: UIColor? = UIColor.darkText {
        didSet {
            if let color = titleColor {
                titleLabel.textColor = color
            } else {
                titleLabel.textColor = UIColor.darkText
            }
        }
    }
    /// 分割线颜色
    var separatorColor: UIColor? = UIColor.darkGray {
        didSet {
            if let color = separatorColor {
                separatorView.backgroundColor = color
            } else {
                separatorView.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    var selectedColor: UIColor?
    
    var isShowSeparator: Bool = false {
        didSet {
            separatorView.isHidden = !isShowSeparator
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 标题Label
        titleLabel = UILabel()
        titleColor = nil // 初始化字体大小
        titleFont = nil // 初始化字体颜色
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        // 分割线
        let separator = UIView()
        separator.backgroundColor = separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separator(0.5)]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["separator": separator]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[separator]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["separator": separator]))
        separatorView = separator
        
        // 红点
        redPoint = UIView()
        redPoint.backgroundColor = UIColor(red: 0xff/0xff, green: 0x33/0xff, blue: 0x00/0xff, alpha: 1)
        addSubview(redPoint)
        
        let size_redPoint: CGFloat = 6
        redPoint.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[title]-2-[redPoint(\(size_redPoint))]", options: .init(rawValue: 0), metrics: nil, views: ["title": titleLabel, "redPoint": redPoint]))
        addConstraint(NSLayoutConstraint(item: redPoint, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1, constant: size_redPoint / 2))
        addConstraint(NSLayoutConstraint(item: redPoint, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size_redPoint))
        redPoint.layer.cornerRadius = size_redPoint / 2
    }
    
    func config(with model: DropDownItem) {
        titleLabel.text = model.title
        redPoint.isHidden = !model.isRedPoint
        self.contentView.backgroundColor = model.isSelected ? (model.selectedColor ?? self.selectedColor) : nil
    }
}


