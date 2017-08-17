//
//  Button.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
@IBDesignable
class Button: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            setUpView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = cornerRadius
    }
}
