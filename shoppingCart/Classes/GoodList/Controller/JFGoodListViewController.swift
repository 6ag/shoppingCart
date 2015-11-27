//
//  JFGoodListViewController.swift
//  shoppingCart
//
//  Created by jianfeng on 15/11/17.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

// 屏幕尺寸
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

class JFGoodListViewController: UIViewController {
    
    // MARK: - 属性
    /// 商品模型数组，初始化
    private var goodArray = [JFGoodModel]()
    
    /// 商品列表cell的重用标识符
    private let goodListCellIdentifier = "goodListCell"
    
    /// 已经添加进购物车的商品模型数组，初始化
    private var addGoodArray = [JFGoodModel]()
    
    /// 贝塞尔曲线
    private var path: UIBezierPath?
    
    /// 自定义图层
    var layer: CALayer?
    
    // MARK: - view生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 提醒：这个方法中一般用于初始化控制器中的一些数据、添加子控件等。但是这个方法获取的frame并不一定准确，所以不建议在这个方法约束子控件
        
        // 初始化模型数组，也就是搞点假数据。这里整10个模型
        for i in 0..<10 {
            var dict = [String : AnyObject]()
            dict["iconName"] = "goodicon_\(i)"
            dict["title"] = "\(i + 1)阿哥"
            dict["desc"] = "这是第\(i + 1)个商品"
            dict["newPrice"] = "1000\(i)"
            dict["oldPrice"] = "2000\(i)"
            
            // 字典转模型并将模型添加到模型数组中
            goodArray.append(JFGoodModel(dict: dict))
        }
        
        // 准备子控件
        prepareUI()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 提示：这个方法是在控制器view已经显示后调用，我们可以在这个方法里面做一些子控件约束操作等
        
        // 约束子控件
        layoutUI()
    }
    
    /**
     准备子控件方法，在这个方法中我们可以创建并添加子控件到view
     */
    private func prepareUI() {
        
        // 标题
        navigationItem.title = "商品列表"
        
        // 添加导航栏上的购物车按钮和已经添加的商品数量label
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartButton)
        
        // 添加购物车按钮上的label
        navigationController?.navigationBar.addSubview(addCountLabel)
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        // 添加tableView到控制器的view上
        view.addSubview(tableView)
        
        // 注册cell
        tableView.registerClass(JFGoodListCell.self, forCellReuseIdentifier: goodListCellIdentifier)
    }
    
    /**
     约束子控件的方法
     */
    private func layoutUI() {
        
        // 约束tableview，让它全屏显示。注意：这里我使用了第三方约束框架（SnapKit）。如果还不会使用，请学习
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view.snp_edges)
        }
        
        addCountLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-12)
            make.top.equalTo(10.5)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
    }

    // MARK: - 懒加载
    /// tableView
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 80
        // 指定数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    /// cartButton顶部购物车按钮
    lazy var cartButton: UIButton = {
        let carButton = UIButton(type: UIButtonType.Custom)
        carButton.setImage(UIImage(named: "button_cart"), forState: UIControlState.Normal)
        carButton.addTarget(self, action: "didTappedCarButton:", forControlEvents: UIControlEvents.TouchUpInside)
        carButton.sizeToFit()
        return carButton
    }()
    
    /// 已经添加进购物车的商品数量
    lazy var addCountLabel: UILabel = {
        let addCountLabel = UILabel()
        addCountLabel.backgroundColor = UIColor.whiteColor()
        addCountLabel.textColor = UIColor.redColor()
        addCountLabel.font = UIFont.boldSystemFontOfSize(11)
        addCountLabel.textAlignment = NSTextAlignment.Center
        addCountLabel.text = "\(self.addGoodArray.count)"
        addCountLabel.layer.cornerRadius = 7.5
        addCountLabel.layer.masksToBounds = true
        addCountLabel.layer.borderWidth = 1
        addCountLabel.layer.borderColor = UIColor.redColor().CGColor
        addCountLabel.hidden = true
        return addCountLabel
    }()

}

// MARK: - UITableViewDataSource, UITableViewDelegate 数据源和代理方法
extension JFGoodListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 第section组有多少个cell,我们这里一共就一组。所以直接返回模型数组的长度
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodArray.count
    }
    
    // 创建每个cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 从缓存池创建cell，如果没有从缓存池创建成功就根据注册的cell重用标识符创建一个新的cell
        let cell = tableView.dequeueReusableCellWithIdentifier(goodListCellIdentifier, forIndexPath: indexPath) as! JFGoodListCell
        
        // 取消选中效果
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // 为cell传递数据
        cell.goodModel = goodArray[indexPath.row]
        
        // 指定代理
        cell.delegate = self
        
        // 返回创建好的cell
        return cell
    }
}

// view上的一些事件处理在这个类扩展里
extension JFGoodListViewController {
    
    /**
     当点击了购物车触发，modal到购物车控制器
     
     - parameter button: 购物车按钮
     */
    @objc private func didTappedCarButton(button: UIButton) {
        
        let shoppingCartVc = JFShoppingCartViewController()
        
        // 传递商品模型数组
        shoppingCartVc.addGoodArray = addGoodArray
        
        // 模态出一个购物车控制器
        presentViewController(UINavigationController(rootViewController: shoppingCartVc), animated: true, completion: nil)
    }
}

// MARK: - JFGoodListCellDelegate代理方法
extension JFGoodListViewController: JFGoodListCellDelegate {
    
    /**
     代理回调方法，当点击了cell上的购买按钮后触发
     
     - parameter cell:     被点击的cell
     - parameter iconView: 被点击的cell上的图标对象
     */
    func goodListCell(cell: JFGoodListCell, iconView: UIImageView) {
        
        guard let indexPath = tableView.indexPathForCell(cell) else {
            return
        }
        
        // 获取当前模型，添加到购物车模型数组
        let model = goodArray[indexPath.row]
        addGoodArray.append(model)
        
        // 重新计算iconView的frame，并开启动画
        var rect = tableView .rectForRowAtIndexPath(indexPath)
        rect.origin.y -= tableView.contentOffset.y
        var headRect = iconView.frame
        headRect.origin.y = rect.origin.y + headRect.origin.y - 64
        startAnimation(headRect, iconView: iconView)
    }
}

// MARK: - 商品图片抛入购物车的动画效果
extension JFGoodListViewController {
    
    /**
     开始动画
     - parameter rect:     商品图标对象的frame
     - parameter iconView: 商品图标对象
     */
    private func startAnimation(rect: CGRect, iconView: UIImageView) {
        if layer == nil {
            layer = CALayer()
            layer?.contents = iconView.layer.contents
            layer?.contentsGravity = kCAGravityResizeAspectFill
            layer?.bounds = rect
            layer?.cornerRadius = CGRectGetHeight(layer!.bounds) * 0.5
            layer?.masksToBounds = true
            layer?.position = CGPoint(x: iconView.center.x, y: CGRectGetMinY(rect) + 96)
            UIApplication.sharedApplication().keyWindow?.layer.addSublayer(layer!)
            
            path = UIBezierPath()
            path!.moveToPoint(layer!.position)
            path!.addQuadCurveToPoint(CGPoint(x: SCREEN_WIDTH - 25, y: 35), controlPoint: CGPoint(x: SCREEN_WIDTH * 0.5, y: rect.origin.y - 80))
        }
        
        // 组动画
        groupAnimation()
    }
    
    /**
     组动画，帧动画抛入购物车，并放大、缩小图层增加点动效。
     */
    private func groupAnimation() {
        
        // 开始动画禁用tableview交互
        tableView.userInteractionEnabled = false
        
        // 帧动画
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path!.CGPath
        animation.rotationMode = kCAAnimationRotateAuto
        
        // 放大动画
        let bigAnimation = CABasicAnimation(keyPath: "transform.scale")
        bigAnimation.duration = 0.5
        bigAnimation.fromValue = 1
        bigAnimation.toValue = 2
        bigAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        // 缩小动画
        let smallAnimation = CABasicAnimation(keyPath: "transform.scale")
        smallAnimation.beginTime = 0.5
        smallAnimation.duration = 1.5
        smallAnimation.fromValue = 2
        smallAnimation.toValue = 0.3
        smallAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // 组动画
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animation, bigAnimation, smallAnimation]
        groupAnimation.duration = 2
        groupAnimation.removedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.delegate = self
        layer?.addAnimation(groupAnimation, forKey: "groupAnimation")
    }
    
    /**
     动画结束后做一些操作
     */
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        // 如果动画是我们的组动画，才开始一些操作
        if anim == layer?.animationForKey("groupAnimation") {
            
            // 开启交互
            tableView.userInteractionEnabled = true
            
            // 隐藏图层
            layer?.removeAllAnimations()
            layer?.removeFromSuperlayer()
            layer = nil
            
            // 如果商品数大于0，显示购物车里的商品数量
            if self.addGoodArray.count > 0 {
                addCountLabel.hidden = false
            }
            
            // 商品数量渐出
            let goodCountAnimation = CATransition()
            goodCountAnimation.duration = 0.25
            addCountLabel.text = "\(self.addGoodArray.count)"
            addCountLabel.layer.addAnimation(goodCountAnimation, forKey: nil)
            
            // 购物车抖动
            let cartAnimation = CABasicAnimation(keyPath: "transform.translation.y")
            cartAnimation.duration = 0.25
            cartAnimation.fromValue = -5
            cartAnimation.toValue = 5
            cartAnimation.autoreverses = true
            cartButton.layer.addAnimation(cartAnimation, forKey: nil)
        }
    }
}
