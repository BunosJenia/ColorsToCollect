//
//  GameScene.swift
//  ColorsToCollect
//
//  Created by Yauheni Bunas on 7/4/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SpriteKit
import GameplayKit

var touchLocation = CGPoint()
var offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
var offWhiteColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
var orangeColor = UIColor.orange
var blueColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)

var colorSelection = 0

var player = SKSpriteNode()
var fallingBlock = SKSpriteNode()

var labelMain = SKLabelNode()
var labelScore = SKLabelNode()

var playerSize = CGSize(width: 60, height: 60)
var fallingBlockSize = CGSize(width: 40, height: 40)

var fallingBlockSpeed = 3.0
var fallingBlockRotationSpeed = 0.1
var spawnTimeFallingBlock = 2.0

var score = 0

var isAlive = true

struct physicsCategory {
    static let player: UInt32 = 1
    static let fallingBlock: UInt32 = 2
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        
        resetGameVariablesOnStart()
        
        spawnLabelMain()
        spawnLabelScore()
        spawnPlayer()
        
        timerFallingBlock()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)

            if isAlive == true {
               player.position.x = touchLocation.x
            }
           
            movePlayerOffScreen()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            
            colorChangingLogic()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayerOffScreen()
        keepPlayerInPosition()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.fallingBlock) || (firstBody.categoryBitMask == physicsCategory.fallingBlock) && (secondBody.categoryBitMask == physicsCategory.player) {
            playerFallingBlockCollision(contactA: firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
        }
    }
    
    func playerFallingBlockCollision(contactA: SKSpriteNode, contactB: SKSpriteNode) {
        if contactA.name == "playerName" {
            if colorSelection == 0 && contactB.name == "fallingBlock0" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 1 || colorSelection == 2) && contactB.name == "fallingBlock0" {
                gameOverLogic()
            }
            
            if colorSelection == 1 && contactB.name == "fallingBlock1" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 0 || colorSelection == 2) && contactB.name == "fallingBlock1" {
                gameOverLogic()
            }
            
            if colorSelection == 2 && contactB.name == "fallingBlock2" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 1 || colorSelection == 0) && contactB.name == "fallingBlock2" {
                gameOverLogic()
            }
        }
        
        if contactB.name == "playerName" {
            if colorSelection == 0 && contactA.name == "fallingBlock0" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 1 || colorSelection == 2) && contactA.name == "fallingBlock0" {
                gameOverLogic()
            }
            
            if colorSelection == 1 && contactA.name == "fallingBlock1" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 0 || colorSelection == 2) && contactA.name == "fallingBlock1" {
                gameOverLogic()
            }
            
            if colorSelection == 2 && contactA.name == "fallingBlock2" {
                contactB.removeFromParent()
                score += 1
                updateScore()
            } else if (colorSelection == 1 || colorSelection == 0) && contactA.name == "fallingBlock2" {
                gameOverLogic()
            }
        }
    }
    
    func spawnLabelMain() {
        labelMain = SKLabelNode(fontNamed: "Futura")
        labelMain.fontSize = 100
        labelMain.fontColor = offWhiteColor
        labelMain.position = CGPoint(x: 0, y: self.frame.size.height/2 - 200)
        labelMain.text = "Start"
        
        self.addChild(labelMain)
    }
    
    func spawnLabelScore() {
        labelScore = SKLabelNode(fontNamed: "Futura")
        labelScore.fontSize = 50
        labelScore.fontColor = offWhiteColor
        labelScore.position = CGPoint(x: 0, y: -self.frame.size.height/2 + 100)
        labelScore.text = "Score: \(score)"
        
        self.addChild(labelScore)
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(color: offWhiteColor, size: playerSize)
        player.size = playerSize
        
        player.position = CGPoint(x: 0, y: -self.frame.size.height/2 + 180)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.fallingBlock
        player.physicsBody?.isDynamic = true
        
        player.name = "playerName"
        
        self.addChild(player)
    }
    
    func spawnFallingBlock() {
        let maxPossibleX = Int(self.frame.size.width/2) - 50
        let randomX = Int.random(in: -maxPossibleX ..< maxPossibleX)
        let colorOfBlock = Int.random(in: 0..<3)
        
        fallingBlock = SKSpriteNode(color: offWhiteColor, size: fallingBlockSize)
        fallingBlock.position = CGPoint(x: randomX, y: 600)
        
        fallingBlock.physicsBody = SKPhysicsBody(rectangleOf: fallingBlock.size)
        fallingBlock.physicsBody?.affectedByGravity = false
        fallingBlock.physicsBody?.allowsRotation = false
        fallingBlock.physicsBody?.categoryBitMask = physicsCategory.fallingBlock
        fallingBlock.physicsBody?.contactTestBitMask = physicsCategory.player
        fallingBlock.physicsBody?.isDynamic = true
        
        if colorOfBlock == 0 {
            fallingBlock.color = offWhiteColor
            fallingBlock.name = "fallingBlock0"
        }
        
        if colorOfBlock == 1 {
            fallingBlock.color = orangeColor
            fallingBlock.name = "fallingBlock1"
        }
        
        if colorOfBlock == 2 {
            fallingBlock.color = blueColor
            fallingBlock.name = "fallingBlock2"
        }
        
        moveFallingBlockToBottom()
        
        self.addChild(fallingBlock)
    }
    
    func moveFallingBlockToBottom() {
        let moveFoward = SKAction.moveTo(y: -1500, duration: fallingBlockSpeed)
        let rotateAnimate = SKAction.rotate(byAngle: 0.1, duration: fallingBlockRotationSpeed)
        let destroy = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([moveFoward, destroy])
        
        fallingBlock.run(SKAction.repeatForever(sequence))
        fallingBlock.run(SKAction.repeatForever(rotateAnimate))
    }
    
    func timerFallingBlock() {
        let wait = SKAction.wait(forDuration: spawnTimeFallingBlock)
    
        let spawn = SKAction.run {
            if isAlive {
                self.spawnFallingBlock()
            }
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func movePlayerOffScreen() {
        if isAlive == false {
            player.position.x = -5000
        }
    }
    
    func keepPlayerInPosition() {
        player.position.y = -self.frame.size.height/2 + 180
    }
    
    func colorChangingLogic() {
        colorSelection = colorSelection + 1
        
        if colorSelection == 3 {
            colorSelection = 0
        }
        
        if colorSelection == 0 {
            player.color = offWhiteColor
        }
        
        if colorSelection == 1 {
            player.color = orangeColor
        }
        
        if colorSelection == 2 {
            player.color = blueColor
        }
    }
    
    func updateScore() {
        labelScore.text = "Score: \(score)"
    }
    
    func gameOverLogic() {
        isAlive = false
        labelMain.text = "Game Over"
        
        waitThenRestartTheGame()
    }
    
    func waitThenRestartTheGame() {
        let wait = SKAction.wait(forDuration: 3)
        let theGameScene = GameScene(fileNamed: "GameScene")
        let theTransition = SKTransition.crossFade(withDuration: 1.0)
        
        theGameScene?.scaleMode = SKSceneScaleMode.aspectFill
        
        let changeScene = SKAction.run {
            self.view?.presentScene(theGameScene!, transition: theTransition)
        }
        
        let sequence = SKAction.sequence([wait, changeScene])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func resetGameVariablesOnStart() {
        score = 0
        isAlive = true
    }
}
