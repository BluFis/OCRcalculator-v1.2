//
//  mathButton.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Apple on 2017/8/7.
//  Copyright © 2017年 Ramotion. All rights reserved.
//

import UIKit
@IBDesignable
class mathButton: UIButton {

  
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor.darkGray.cgColor
        
        self.layer.borderWidth = 0.3
    }
  
}
extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: state);
    }
}
