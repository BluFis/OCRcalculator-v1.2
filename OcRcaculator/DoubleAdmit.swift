//
//  DoubleAdmit.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

import Foundation


class DoubleAdmit {
    
    
    func recongonize(str:String)->String?{
        var Str = NSString(string: str)
        let replaceChar = ["o","O","Q","a","I","i","j","T","f","g","z","Z",".","。","-","_"]
        for char in replaceChar{
            switch char {
            case "o","O","Q","a":
                
                Str = Str.replacingOccurrences(of: char, with: "0") as NSString
            case "I","i","j","T":
                
                Str = Str.replacingOccurrences(of: char, with: "1") as NSString
                
            case "f","g":
                
                Str = Str.replacingOccurrences(of: char, with: "9") as NSString
                
            case "Z","z":
                
                Str = Str.replacingOccurrences(of: char, with: "2") as NSString
            case ".","。":
                Str = Str.replacingOccurrences(of: char, with: ".") as NSString
            case "-","_":
                Str = Str.replacingOccurrences(of: char, with: "-") as NSString
                
            default:
                print("error:\(str)")
            }
            
        }
        
     return Str as String
        
        
    }
    
    
 
    
    
    
}
