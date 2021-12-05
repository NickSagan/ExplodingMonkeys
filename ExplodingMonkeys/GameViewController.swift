//
//  GameViewController.swift
//  ExplodingMonkeys
//
//  Created by Nick Sagan on 04.12.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var playerNumber: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true

        velocitySlider.isHidden = true
        velocityLabel.isHidden = true

        launchButton.isHidden = true

        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))

    }
    
    var currentGame: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                currentGame = scene as? GameScene
                currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }

        angleSlider.isHidden = false
        angleLabel.isHidden = false

        velocitySlider.isHidden = false
        velocityLabel.isHidden = false

        launchButton.isHidden = false
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
