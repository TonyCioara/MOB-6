//
//  Character.swift
//  SushiNeko
//
//  Created by Tony Cioara on 2/25/18.
//  Copyright © 2018 Tony Cioara. All rights reserved.
//

import SpriteKit

class Character: SKSpriteNode {
    
    var side: Side = .left {
        didSet {
            if side == .left {
                xScale = 1
                position.x = 70
            } else {
                xScale = -1
                position.x = 252
            }
            
//            Character animation
            let punch = SKAction(named: "Punch")!
            run(punch)
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
