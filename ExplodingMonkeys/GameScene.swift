//
//  GameScene.swift
//  ExplodingMonkeys
//
//  Created by Nick Sagan on 04.12.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!

    var currentPlayer = 1
    
    var player1score = 0
    var player2score = 0
    
    weak var viewController: GameViewController!
    var buildings = [BuildingNode]()

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)

        createBuildings()
        createPlayers()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity.dx = Double.random(in: -3.0...3.0)
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15

        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 150...450))
            currentX += size.width + 2

            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)

            buildings.append(building)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func launch(angle: Int, velocity: Int) {
        // Figure out how hard to throw the banana.
        let speed = Double(velocity) / 10.0

        // Convert the input angle to radians.
        let radians = deg2rad(degrees: angle)

        // If somehow there's a banana already, we'll remove it then create a new one
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }

        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)

        if currentPlayer == 1 {
            // If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20

            // Animate player 1 throwing their arm up then putting it down again.
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)

            // Make the banana move in the correct direction.
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            // If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction.
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20

            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)

            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false

        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)

        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false

        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        // assign banana to firstBody, because its bitmask is the lowest
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }

        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }

        if firstNode.name == "banana" && secondNode.name == "player1" {
            player2score += 1
            viewController.playersScore.text = "Player-1 \(player1score):\(player2score) Player-2"
            destroy(player: player1)
        }

        if firstNode.name == "banana" && secondNode.name == "player2" {
            player1score += 1
            viewController.playersScore.text = "Player-1 \(player1score):\(player2score) Player-2"
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }

        player.removeFromParent()
        banana.removeFromParent()
        
        
        if player1score == 3 {
            viewController.playerNumber.text = "Player 1 win!"
            player1score = 0
            player2score = 0
        } else if player2score == 3 {
            viewController.playerNumber.text = "Player 2 win!"
            player1score = 0
            player2score = 0
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame

            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            newGame.player1score = self.player1score
            newGame.player2score = self.player2score
            
            newGame.viewController.playersScore.text = "Player-1 \(self.player1score):\(self.player2score) Player-2"

            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }

        viewController.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building) // asks the game scene to convert the collision contact point into the coordinates relative to the building node. That is, if the building node was at X:200 and the collision was at X:250, this would return X:50, because it was 50 points into the building node.
        building.hit(at: buildingLocation)

        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }

        banana.name = "" // it's to fix a small but annoying bug: if a banana just so happens to hit two buildings at the same time, then it will explode twice and thus call changePlayer() twice. By clearing the banana's name here, the second collision won't happen because our didBegin() method won't see the banana as being a banana any more ??? its name is gone.
        
        banana.removeFromParent()
        banana = nil

        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }

        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}
