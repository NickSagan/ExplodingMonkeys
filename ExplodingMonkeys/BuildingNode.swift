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
    
    func drawBuilding(size: CGSize) -> UIImage {
        // Create a new Core Graphics context the size of our building.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            // Fill it with a rectangle that's one of three colors.
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let color: UIColor

            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }

            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)

            // Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray).
            
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }

                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        // Pull out the result as a UIImage and return it for use elsewhere.
        return img
    }
    
    func hit(at point: CGPoint) {
        // Figure out where the building was hit. SpriteKit's positions things from the center and Core Graphics from the bottom left!
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))

        // Create a new Core Graphics context the size of our current sprite.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            
            //Draw our current building image into the context. This will be the full building to begin with, but it will change when hit.
            currentImage.draw(at: .zero)

            //Create an ellipse at the collision point. The exact co-ordinates will be 32 points up and to the left of the collision, then 64x64 in size - an ellipse centered on the impact point.
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            //Set the blend mode .clear then draw the ellipse, literally cutting an ellipse out of our image.
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }

        //Convert the contents of the Core Graphics context back to a UIImage, which is saved in the currentImage property for next time we’re hit, and used to update our building texture.
        texture = SKTexture(image: img)
        currentImage = img

        // Call configurePhysics() again so that SpriteKit will recalculate the per-pixel physics for our damaged building.
        configurePhysics()
    }
}
