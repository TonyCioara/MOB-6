//
//  SushiPiece.swift
//  SushiNeko
//
//  Created by Tony Cioara on 2/23/18.
//  Copyright © 2018 Tony Cioara. All rights reserved.
//

import SpriteKit

class SushiPiece: SKSpriteNode {
    
//    Pick side for chopstick
    var side: Side = .none {
        didSet {
            switch side {
            case .left:
                leftChopstick.isHidden = false
            case .right:
                rightChopstick.isHidden = false
            case .none:
                rightChopstick.isHidden = true
                leftChopstick.isHidden = true
            }
        }
    }
//    Chopstick objects
    var rightChopstick: SKSpriteNode!
    var leftChopstick: SKSpriteNode!
    
//    init class
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func connectChopsticks() {
//         Connect our child chopstick nodes
        rightChopstick = childNode(withName: "rightChopstick") as! SKSpriteNode
        leftChopstick = childNode(withName: "leftChopstick") as! SKSpriteNode
        side = .none
    }
    
    func flip(_ side: Side) {
//        Flip the sushi out of the screen
        
        var actionName: String = ""
        
//       Choose appropriate action
        if side == .left {
            actionName = "FlipRight"
        } else if side == .right {
            actionName = "FlipLeft"
        }
        
//        Load appropriate action
        let flip = SKAction(named: actionName)!
        
//        Create a node removal action
        let remove = SKAction.removeFromParent()
        
//        Build sequence, flip then remove scene
        let sequence = SKAction.sequence([flip, remove])
        run(sequence)
    }
}
