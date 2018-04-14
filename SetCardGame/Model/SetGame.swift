//
//  SetGame.swift
//  SetCardGame
//
//  Created by Mohamed Mohsen on 4/12/18.
//  Copyright © 2018 Mohamed Mohsen. All rights reserved.
//

import Foundation

struct SetGame{
    private(set) var flipCount: Int = 0
    private(set) var score: Int = 0
    private(set) var numberOfSet: Int = 0
    
    private(set) var cardsOnTable = [SetCard]()
    private(set) var cardsOnSelected = [SetCard](){
        didSet{
            cardsTryMatched = cardsOnSelected
        }
    }
    private(set) var cardsTryMatched = [SetCard]()
    private(set) var cardsRemoved = [SetCard]()
    
    var availableSets: Int {
        let _hints = hints
        return _hints.count
    }
    private var defaultStateDescriptionMessege: String{
        return "Try to find a SET! \(availableSets) left."
    }
    private var missPenaltyStateDescriptionMessege:String{
        return "-\(Points.missMatchPenalty) for miss penalty."
    }
    private var matchStateDescriptionMessege:String{
        return "+\(Points.matchBonus) for a new matched SET."
    }
    private(set) lazy var stateDescriptionMessege: String = ""
    private(set) var isNeedToUpdated: Bool = false{
        didSet{
            
        }
    }
    private(set) var modificatedSet: SetModification{
        mutating get{
            isNeedToUpdated = false
            return modificatedSet
        }
        set{
            isNeedToUpdated = true
        }
    }
    
    struct SetModification{
        var action: SetModificationAction
        var workedSet: [SetCard] //Applay action on this SET
    }
    
    enum SetModificationAction{
        case append3Cards
        case remove3Cards
        case replace3Cards
    }
    
    private var deck = SetCardDeck()
    var deckCount : Int {return deck.cards.count}
    var isSet: Bool{
        get{
            guard cardsTryMatched.count == 3 else {return false}
            return SetCard.isSet(cards: cardsTryMatched)
        }
        set{
            //TODO
        }
    }
    
    mutating func chosenCard(at index: Int){
        assert(cardsOnTable.indices.contains(index) , "SetGame.chosenCard(\(index)): chosen index out of range")
        let chosenCard = cardsOnTable[index]
        if !cardsRemoved.contains(chosenCard){
            if !cardsOnSelected.contains(chosenCard), cardsOnSelected.count == 2 {
                cardsOnSelected.append(chosenCard)
                //cardsTryMatched = cardsOnSelected assign automaticlly
                if SetCard.isSet(cards: cardsTryMatched) == true{
                    score += Points.matchBonus
                    stateDescriptionMessege = matchStateDescriptionMessege
                    removeOrReplace3CardsFromDeck()
                    cardsOnSelected.removeAll()
                    //cardsTryMatched.removeAll() removed automaticlly
                }else{
                    score -= Points.missMatchPenalty
                    stateDescriptionMessege = missPenaltyStateDescriptionMessege
                }
            }else {
                if !cardsOnSelected.contains(chosenCard), cardsOnSelected.count == 3{cardsOnSelected.removeAll()} // Player want to select new set from beginning
                cardsOnSelected.inOut(element: chosenCard)
                stateDescriptionMessege = defaultStateDescriptionMessege
            }
            flipCount += 1
        }
        
    }
    
    mutating func removeOrReplace3CardsFromDeck(){
        assert(cardsTryMatched.count == 3, "SetGame.removeOrReplace3CardsFromDeck: cardsTryMatched.count = \(cardsTryMatched.count)")
        /*if cardsOnTable.count == Constants.startNumberCards, let new3Cards = take3CardsFromDeck() {
            //replace
            cardsOnTable.replace(elementsOf: cardsTryMatched, with: new3Cards)
            modificatedSet = SetModification(action: SetModificationAction.replace3Cards, workedSet: cardsTryMatched)
        }else{
            //remove from deckCards
            cardsOnTable.remove(elementsOf: cardsTryMatched)
            modificatedSet = SetModification(action: SetModificationAction.remove3Cards, workedSet: cardsTryMatched)
        }*/
        //remove from deckCards
        cardsOnTable.remove(elementsOf: cardsTryMatched)
        modificatedSet = SetModification(action: SetModificationAction.remove3Cards, workedSet: cardsTryMatched)

        cardsRemoved += cardsTryMatched
    }
    
    private mutating func take3CardsFromDeck() -> [SetCard]?{
        //assert(deck.cards.count >= 3 , "SetGame.take3CardsFromDeck: deck.cards.count = \(deck.cards.count) is less than 3")
        guard deck.cards.count >= 3 else {return nil}
        return [deck.draw()!, deck.draw()!, deck.draw()!]
    }
    
    mutating func deal3Cards(){
        if let threeCards = take3CardsFromDeck(){
            cardsOnTable += threeCards
            stateDescriptionMessege = defaultStateDescriptionMessege
        }
    }
    
    var hints: [[Int]]{
        var hints = [[Int]]()
        if cardsOnTable.count > 2{
            for firstCardIndex in cardsOnTable.indices{
                for secondCardIndex in (firstCardIndex+1)..<cardsOnTable.count{
                    for thirdCardIndex in (secondCardIndex+1)..<cardsOnTable.count{
                        if SetCard.isSet(cards: [cardsOnTable[firstCardIndex], cardsOnTable[secondCardIndex], cardsOnTable[thirdCardIndex]]) == true{
                            hints.append([firstCardIndex, secondCardIndex, thirdCardIndex])
                        }
                    }
                }
            }
        }
//        if let itIsSet = isSet,itIsSet {
//            let matchIndices = cardsOnTable.indices(of: cardsTryMatched)
//            return hints.map{ Set($0)}
//                .filter{$0.intersection(Set(matchIndices)).isEmpty}
//                .map{Array($0)}
//        }
        return hints
    }
    
    mutating func shuffle(){
        cardsOnTable.shuffle()
    }
    
    init() {
        for _ in 0..<Constants.startNumberCards{
            if let card = deck.draw(){
                cardsOnTable.append(card)
            }
        }
    }
    
    
    //------------------ Constants -------------
    private struct Points {
        static let matchBonus = 20
        static let missMatchPenalty = 10
        static var maxTimePenalty = 10
        static var flipOverPenalty = 1
    }
    
    private struct Constants {
        static let startNumberCards = 12 //defualt 12
    }
    
}

















