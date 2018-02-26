//
//  GameScene.swift
//  SushiNeko
//
//  Created by Tony Cioara on 2/23/18.
//  Copyright © 2018 Tony Cioara. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Side {
    case left, right, none
}

enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
   
//    Sushi piece and character
    var sushiBasePiece: SushiPiece!
    var character: Character!
//    Sushi tower
    var sushiTower: [SushiPiece] = []
//    Game management
    var state: GameState = .title {
        didSet {
            if state == .playing || state == .ready {
                playButton.isHidden = true
            } else {
                playButton.isHidden = false
            }
        }
    }
//    Game buttons
    var playButton: MSButtonNode!
//    Health bar and health
    var healthBar: SKSpriteNode!
    var health: CGFloat = 1.0 {
        didSet {
//            Scale varries between 0.0 and 1.0
            healthBar.xScale = health
            if health > 1.0 {
                health = 1.0
            }
        }
    }
//    Score label and score
    var scoreLabel: SKLabelNode!
    var score: Int = 1 {
        didSet {
//            Update label with score
            scoreLabel.text = String(describing: score)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
//        Connect game objects
        sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        character = childNode(withName: "character") as! Character
//        UI game objects
        playButton = childNode(withName: "playButton") as! MSButtonNode
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
//        Setup play button selection handler
        playButton.selectedHandler = {
//            Start game
            self.state = .ready
        }
        
//        Setup chopstick connection
        sushiBasePiece.connectChopsticks()
        
//        Add starting tower pieces
        addRandomSushiPiece(total: 10)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        moveTowerDown()
        
//        Return unless gamestate is playing
        if state != .playing {
            return
        }
//        Decrease health
        health -= 0.01
//        Has player run out of health
        if health < 0 {
            gameOver()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Called when touch begins
        
//        Game not ready to play
        if state == .gameOver || state == .title {return}
//        Game begins after first touch
        if state == .ready {
            state = .playing
        }
        
//        Increase health
        health += 0.1
        score += 1
        
//        We only need a single touch
        let touch = touches.first!
        
//        Get touch position in scene
        let location = touch.location(in: self)
        
//        Was touch on the left or right side of the screen?
        if location.x > size.width / 2 {
            character.side = .right
        } else {
            character.side = .left
        }
        
//        Grab sushi piece on top of the sushiBasePiece. It will always be first
        if let firstPiece = sushiTower.first {
            
//            Remove from sushi array
            sushiTower.removeFirst()
            
//            Animate the punched sushi piece
            firstPiece.flip(character.side)
            
//            Check if character is on the same side as first chopstick
            if character.side == firstPiece.side {
                gameOver()
                
//                No need to continue as player is dead
                return
            }
        }
        
        
//        Add a new sushi piece to the topof the sushi tower
        addRandomSushiPiece(total: 1)
    }
    
    func addTowerPiece(side: Side) {
//        Add a new sushi piece to the sushi tower
        
//        Copy original sushi piece
        let newPiece = sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
//        Access last piece properties
        let lastPiece = sushiTower.last
        
//        Add on top of last piece, default on first piece
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
//        Increment z to ensure it's on top of previous piece, default on first position
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
//        Set side
        newPiece.side = side
        
//        Add sushi to scene
        addChild(newPiece)
        
//        Add sushi piece to sushi tower
        sushiTower.append(newPiece)
    }
    
    func addRandomSushiPiece(total: Int) {
//        Add random sushi pieces to tower
        
        for _ in 1...total {
//            Need to access last piece properties
            let lastPiece = sushiTower.last ?? sushiBasePiece!
            
//            Need to assure we won't create impossible sushi structures
            if lastPiece.side != .none {
                addTowerPiece(side: .none)
            } else {
//                Random number generator
                let rand = arc4random_uniform(100)
                
                if rand < 45 {
                    addTowerPiece(side: .left)
                } else if rand < 90 {
                    addTowerPiece(side: .right)
                } else {
                    addTowerPiece(side: .none)
                }
            }
            
        }
    }
    
    func moveTowerDown() {
//        Move tower pieces down
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    func gameOver() {
//        Game over :(
        
        state = .gameOver
        
//        Turn all the sushi pieces red
        for sushiPiece in sushiTower {
            sushiPiece.run(SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5))
            sushiPiece.leftChopstick.run(SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5))
            sushiPiece.rightChopstick.run(SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5))
        }
        
//        Make the base turn red
        sushiBasePiece.run(SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5))
        
//        Make the player turn red
        character.run(SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5))
        
//        Change play button selected handler
        playButton.selectedHandler = {
            
//            Grab reference to SpriteKit view
            let skView = self.view as SKView!
            
//            Load game scene
            guard let scene = GameScene(fileNamed: "GameScene") as GameScene! else {
                return
            }
            
//            Ensure correct aspect mode
            scene.scaleMode = .aspectFill
            
//            Restart gamescene
            skView?.presentScene(scene)
        }
    }
}
