//
//  CaculatorBrain.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Apple on 2017/8/7.
//  Copyright © 2017年 Ramotion. All rights reserved.
//

import Foundation


struct CaculatorBrain {
    
    private var accumlator:Double?
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double,Double)->Double)
        case equals
    }
    private var operations:[String:Operation] =
        [
         "√":Operation.unaryOperation(sqrt),
         "^2":Operation.unaryOperation({$0 * $0}),
         "±":Operation.unaryOperation({-$0}),
         "x":Operation.binaryOperation({$0 * $1}),
         "÷":Operation.binaryOperation({$0 / $1}),
         "+":Operation.binaryOperation({$0 + $1}),
         "-":Operation.binaryOperation({$0 - $1}),
         "=":Operation.equals
            
    ]
    
    

    
    
    mutating func performOperation(_ symbol:String){
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumlator = value
            case .unaryOperation(let function):
                if accumlator != nil {
                    accumlator = function(accumlator!)
                    
                }
            case .binaryOperation(let function):
                if accumlator != nil{
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumlator!)
                    accumlator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    private mutating func
        performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumlator != nil
        {accumlator =
            pendingBinaryOperation!.perform(with: accumlator!)
            pendingBinaryOperation = nil
            
        }
    }
    
    
    private var  pendingBinaryOperation:PendingBinaryOperation?
    private struct PendingBinaryOperation {
        let function:(Double,Double)->Double
        let firstOperand:Double
        func perform(with secondOperand:Double)->Double{
            return function(firstOperand,secondOperand)
        }
    }
    
    
    
    
    
    mutating func setOperand(_ operand:Double){
        accumlator = operand
        
    }
    var result:Double?{
        return accumlator
        
    }
}
