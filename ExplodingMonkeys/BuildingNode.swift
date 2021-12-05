//
//  BuildingNode.swift
//  ExplodingMonkeys
//
//  Created by Nick Sagan on 05.12.2021.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!

    func setup() {
        name = "building"

        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)

        configurePhysics()
    }

    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    
}
