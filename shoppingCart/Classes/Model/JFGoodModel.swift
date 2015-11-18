//
//  JFGoodModel.swift
//  shoppingCart
//
//  Created by jianfeng on 15/11/17.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFGoodModel: NSObject {
    
    // 是否已经加入购物车
    var alreadyAddShoppingCart: Bool = false
    
    // 商品图片名称
    var iconName: String?
    
    // 商品标题
    var title: String?
    
    // 商品描述
    var desc: String?
    
    // 商品购买个数,默认0
    var count: Int = 1
    
    // 新价格
    var newPrice: String?
    
    // 老价格
    var oldPrice: String?
    
    // 是否选中，默认没有选中
    var selected: Bool = true
    
    // 字典转模型
    init(dict: [String : AnyObject]) {
        super.init()
        
        // 使用kvo为当前对象属性设置值
        setValuesForKeysWithDictionary(dict)
    }
    
    // 防止对象属性和kvc时的dict的key不匹配而崩溃
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}
