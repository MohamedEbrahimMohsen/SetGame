//
//  Extensions.swift
//  SetCardGame
//
//  Created by Mohamed Mohsen on 4/12/18.
//  Copyright © 2018 Mohamed Mohsen. All rights reserved.
//

import Foundation

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
    
    func incrementCicle (in number: Int)-> Int {
        return self == (number-1) ? 0: self+1
        //return (number - 1) > self ? self + 1: 0
    }
}

extension Array where Element : Equatable {
    mutating func remove(elementsOf: [Element]){
        self = self.filter{!elementsOf.contains($0)}
    }
    
    mutating func replace(elementsOf oldArray: [Element], with newArray:[Element]){
        guard newArray.count == oldArray.count else {return}
        for idx in newArray.indices{
            if let idxMatched = self.index(of: oldArray[idx]){
                self[idxMatched] = newArray[idx]
            }
        }
    }
    
    mutating func inOut(element: Element){
        if let idx = self.index(of: element){
            self.remove(at: idx)
        }else {
            self.append(element)
        }
    }
    
    mutating func shuffle(){
        if count < 2 {return}
        for _ in indices{
            let randomIndex1 = count.arc4random
            let randomIndex2 = count.arc4random
            swapAt(randomIndex1, randomIndex2)
        }
    }
}

















