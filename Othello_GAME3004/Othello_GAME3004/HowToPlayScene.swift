//
//  HowToPlayScene.swift
//  Othello_GAME3004
//
//  Created by Darren Yam on 2019-03-12.
//  Copyright © 2019 Codex. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class HowToPlayScene: SKScene {
    var background: SKSpriteNode!
    var clickParticle: SKEmitterNode!
    var touchStartLoc: CGRect!
    
    var titleLabel: SKLabelNode!
    var instructionsLabel: SKLabelNode!
    
    var backButton: SKSpriteNode!
    
    var soundOn: Bool = UserDefaults.standard.bool(forKey: "sound")
    var audioPlayer = AVAudioPlayer()
    let sfxClickDown: URL! = Bundle.main.url(forResource: "button-click-down", withExtension: "mp3", subdirectory: "Sounds")
    let sfxClickUp: URL! = Bundle.main.url(forResource: "button-click-up", withExtension: "mp3", subdirectory: "Sounds")
    
    override init(size: CGSize) {
        super.init(size: size)
        touchStartLoc = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        background = SKSpriteNode(imageNamed: "menu-BG")
        background?.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        background?.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        background?.zPosition = -1;
        addChild(background)
        
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "back"))
        addChild(backButton)
        backButton.anchorPoint = CGPoint(x: 0, y: 0)
        //backButton.setScale(UIScreen.main.bounds.width / (UIScreen.main.bounds.width * 3))
        
        backButton.position = CGPoint(x: UIScreen.main.bounds.width * 0.05, y: UIScreen.main.bounds.width * 0.05)
        backButton.setScale((UIScreen.main.bounds.width / backButton.frame.width) * 0.18)
        
        //label = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel = SKLabelNode(text: "How To Play")
        titleLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 8.5/10)
        titleLabel.fontSize = UIScreen.main.bounds.width/8
        addChild(titleLabel)
        
        instructionsLabel = SKLabelNode(text: "How to Play: \n\nEach turn, the player places one disc \non the board. Each disc played must \nbe laid adjacent to an opponent's disc \nso that the opponent's disc or a row of \nopponent's discs is flanked by the new \ndisc and another disc of the player's \ncolour. All of the opponent's discs \nbetween these two discs are 'captured' \nand turned over to match the player's \ncolour. \n\n\nObjective of the Game: \n\nTo have the most discs on the board\nwhen the game ends. \n\n" )
        instructionsLabel.numberOfLines = 0
        instructionsLabel.horizontalAlignmentMode = .center
        instructionsLabel.verticalAlignmentMode = .top
        instructionsLabel.preferredMaxLayoutWidth = 500
        instructionsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        instructionsLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height  * 0.8)
        instructionsLabel.fontSize = UIScreen.main.bounds.width/18
        addChild(instructionsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder: ) has not been implemented")
    }
    
    func PlaySound(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if soundOn { audioPlayer.play() }
        } catch {
            print("Couldn't play file!")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if (backButton.frame.contains(t.location(in: self))) {
                backButton.texture = SKTexture(imageNamed: "back-pressed")
                PlaySound(url: sfxClickDown)
                touchStartLoc = backButton.frame
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            clickParticle = SKEmitterNode(fileNamed: "ClickParticle.sks")
            clickParticle.position = t.location(in: self)
            scene?.addChild(clickParticle)
            
            if (backButton.frame.contains(t.location(in: self)) && touchStartLoc!.equalTo(backButton.frame)) {
                backButton.texture = SKTexture(imageNamed: "back")
                PlaySound(url: sfxClickUp)
                let scene = MainMenuScene(size: self.size)
                let transition = SKTransition.moveIn(with: .down, duration: 0.5)
                self.view?.presentScene(scene, transition:transition)
            }
            
            if (!backButton.frame.contains(t.location(in: self))) {
                backButton.texture = SKTexture(imageNamed: "back")
                touchStartLoc = CGRect(x: 0, y: 0, width: 0, height: 0)
                return;
            }
        }
    }
}
