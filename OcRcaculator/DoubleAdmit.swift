//
//  DoubleAdmit.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

import Foundation
import UIKit
class DoubleAdmit {
    func recongonize(str:String)->String?{
        var dot = elementIndex()
        var hipen = elementIndex()
        var Str = NSString(string: str)
        let replaceChar = [".","。","-","_"]
        for char in replaceChar{
            switch char {
            case ".","。":
                Str = Str.replacingOccurrences(of: char, with: ".") as NSString
            case "-","_":
                Str = Str.replacingOccurrences(of: char, with: "-") as NSString
            default:
                print("error:\(str)")
            }
        }
        
        var result = Str as String
        print(result)
        guard result.characters.count > 0 else {
            return "0.0"
        }
        for index in 0...result.characters.count - 1{
            
            if result.charAt(index: index) == "."{
                
                dot.count += 1
                dot.index.
            }
            
            if result.charAt(index: index) == "-"{
                
                hipen.count += 1
                hipen.index.append(result.index(of: "-")!)
            }
            
        }
        print("result:\(result)")
        
        result = result.replacingOccurrences(of: ".", with: "")
        result = result.replacingOccurrences(of: "-", with: "")
        
        if dot.count >= 1{
            result.insert(".", at: (dot.index.last!))
        }
        
        if hipen.count >= 1{
            result.insert("-", at: result.startIndex)
        }
        print("Lastresult:\(result)")
        return result
    }
}

struct elementIndex {
    
    var count:Int = 0
    var index = IndexSet()
}
extension String{
    
    func charAt(index:Int)->Character?{
        
        if index >= self.characters.count || index < 0 {
            
            return nil
            
        }
        
        let NS = NSString(string: self)
        let char = NS.substring(with: NSRange(location: index,length: 1))
        
        
        
        return  char.characters.first  }
}

