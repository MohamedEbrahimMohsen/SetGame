//
//  SetGameViewController.swift
//  SetCardGame
//
//  Created by Mohamed Mohsen on 4/13/18.
//  Copyright © 2018 Mohamed Mohsen. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {

    private var game = SetGame()
    
    @IBOutlet weak var boardView: BoardView!{
        didSet{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(deal3Cards))
            swipe.direction = [.up]
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    @IBOutlet weak var deckCardsLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var stateMessegeDescription: UILabel!
    
    @IBOutlet weak var findASetBtnLabel: BorderButton!
    @IBOutlet weak var newGameBtnLabel: BorderButton!
    @IBOutlet weak var deal3CardsBtnLabel: BorderButton!
    
    @objc private func deal3Cards(_ sender: UITapGestureRecognizer){
        switch sender.state{
        case .ended:
            game.deal3Cards()
            updateViewFromModel()
        default: break
        }
    }

    @objc private func reshuffle(_ sender: UITapGestureRecognizer){
        switch sender.state{
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default: break
        }
    }
    
    private func updateViewFromModel(){
        updateCardViewsFromModel()
        deckCardsLabel.text = "Deck: \(game.deckCount)"
        scoreLabel.text = "Score: \(game.score)"
        stateMessegeDescription.text = game.stateDescriptionMessege
        findASetBtnLabel.disable = game.hints.count == 0
        deal3CardsBtnLabel.isHidden = game.deckCount == 0
    }
    
    private func updateCardViewsFromModel(){
        if boardView.cardViews.count - game.cardsOnTable.count > 0 {
            let cardViews = boardView.cardViews [..<game.cardsOnTable.count ]
            boardView.cardViews = Array(cardViews)
        }
        let numberCardViews =  boardView.cardViews.count
        
        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if  index > (numberCardViews - 1) { // new cards
                
                let cardView = SetCardView()
                updateCardView(cardView,for: card)
                addTapGestureRecognizer(for: cardView) // gesture tap
                boardView.cardViews.append(cardView)
                

                let originalCardPosition = cardView.center
                cardView.center = CGPoint(x: boardView.frame.width/2, y: boardView.frame.height+20)
               UIView.transition(with: cardView, duration: 2, options: [.transitionFlipFromLeft],
                                 animations: {
                                    cardView.center = originalCardPosition
               }
//                , completion: {finished in originalCardPosition = cardView.center}
                )
                
//                UIView.animateKeyframes(withDuration: 6, delay: 0, options: [], animations: {
//                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2) {
//                        cardView.center = originalCardPosition
//                    }
//
//
//                })
                
            } else {                                // old cards
                let cardView = boardView.cardViews [index]
                updateCardView(cardView,for: card)
            }
        }
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard){
        cardView.symbolInt =  card.shape.rawValue
        cardView.fillInt = card.fill.rawValue
        cardView.colorInt = card.color.rawValue
        cardView.count =  card.number.rawValue
        cardView.isSelected =  game.cardsOnSelected.contains(card)
    }
    
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: )))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if  let cardView = recognizer.view! as? SetCardView {
//                cardView.isSelected = !cardView.isSelected
                game.chosenCard(at: boardView.cardViews.index(of: cardView)!)
            }
        default:
            break
        }
        updateViewFromModel()
    }
    
    private weak var timer: Timer?
    private var _lastHint = 0
    private let flashTime = 1.5
    
    @IBAction func findASetButton(_ sender: BorderButton) {
        if game.availableSets > 0{
            timer?.invalidate()
            if  game.hints.count > 0 {
            if _lastHint >= game.hints.count {_lastHint = 0}
                game.hints[_lastHint].forEach { (idx) in
                    boardView.cardViews[idx].hint()
                }
                //messageLabel.text = "Set \(_lastHint + 1) Wait..."
                timer = Timer.scheduledTimer(withTimeInterval: flashTime,
                                             repeats: false) { [weak self] time in
                                                self?._lastHint =
                                                    (self?._lastHint)!.incrementCicle(in:(self?.game.availableSets)!)
                                                //self?.messageLabel.text = ""
                                                self?.updateCardViewsFromModel()
                }
            }
        }
    }
    @IBAction func newGameButton(_ sender: BorderButton) {
        game = SetGame()
        boardView.cardViews.removeAll()
        updateViewFromModel()
        seconds = 0
        minutes = 0
    }
    @IBAction func deal3CardsButton(_ sender: BorderButton) {
        game.deal3Cards()
        updateViewFromModel()
    }
    
    private var globalGameTimer: Timer!
    private var seconds: Int = 0
    private var minutes: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        globalGameTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(updateGameTimer),
                                               userInfo: nil,
                                               repeats: true)

        // Do any additional setup after loading the view.
    }
    
    @objc private func updateGameTimer(){
        seconds += 1
        if seconds == 60{
            seconds = 0
            minutes += 1
            if minutes == 60{
                minutes = 0
            }
        }
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}







//                UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
//                    cardView.center = originalCardPosition
//                },
//                    //              completion: {finished in }
//                    completion: {finished in CATransaction.commit() }
//                )


