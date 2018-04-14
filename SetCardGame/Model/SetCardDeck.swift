//
//  SetCardDeck.swift
//  Set
//
//  Created by Tatiana Kornilova on 12/31/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
struct SetCardDeck {
    private(set) var cards = [SetCard]()
    
    init() {
        for number in SetCard.Variant.all {
            for color in SetCard.Variant.all {
                for shape in SetCard.Variant.all {
                    for fill in SetCard.Variant.all {
                        cards.append(SetCard(number: number,
                                             color: color,
                                             shape: shape,
                                             fill: fill))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}


