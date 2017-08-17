//
//  String.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 Apple. All rights reserved.
//
import Foundation
extension String {
    static let DecimalDigits = 6
    
    func beautifyNumbers() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = String.DecimalDigits
        
        var text = self as NSString
        var numbers = [String]()
        let regex = try! NSRegularExpression(pattern: "[.0-9]+", options: .caseInsensitive)
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, text.length))
        numbers = matches.map { text.substring(with: $0.range) }
        
        for number in numbers {
            text = text.replacingOccurrences(
                of: number,
                with: formatter.string(from: NSNumber(value: Double(number)!))!
                ) as NSString
        }
        return text as String;
    }
}
