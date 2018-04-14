//
//  BoardView.swift
//  SetCardGame
//
//  Created by Mohamed Mohsen on 4/13/18.
//  Copyright © 2018 Mohamed Mohsen. All rights reserved.
//

import UIKit

class BoardView: UIView {

    var cardViews = [SetCardView](){
        willSet{
            removeSubviews()
        }
        didSet{
            addSubviews()
        }
    }
    
    private func removeSubviews(){
        for card in cardViews{
            card.removeFromSuperview()
        }
    }
    
    private func addSubviews(){
        for card in cardViews{
            self.addSubview(card)
        }
    }
    
    override func layoutSubviews() {
        UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
            super.layoutSubviews()
            var grid = Grid(
                layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio),
                frame: self.bounds)
            grid.cellCount = self.cardViews.count
            for row in 0..<grid.dimensions.rowCount {
                for column in 0..<grid.dimensions.columnCount {
                    if self.cardViews.count > (row * grid.dimensions.columnCount + column) {
                        
                        self.cardViews[row * grid.dimensions.columnCount + column].frame = grid[row,column]!.insetBy(
                            dx: Constant.spacingDx, dy: Constant.spacingDy)
                    }
                }
            }
        }
            //, completion:
        )
        
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let spacingDx: CGFloat  = 3.0
        static let spacingDy: CGFloat  = 3.0
    }
}
