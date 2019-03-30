//
//  GameScene.swift
//  Othello_GAME3004
//
//  Created by Darren Yam on 2019-03-12.
//  Copyright © 2019 Codex. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: Game logic vars
    //define board size, create game board
    let boardSize = 8;
    var gameBoard: [[Character]]!;
    
    //tokens
    let black: Character = "b";
    let white: Character = "w";
    let empty: Character = "e";
    var currentTurn: Character = " ";
    
    //amount of discs on the board
    var whiteCount = 2;
    var blackCount = 2;
    
    // MARK: Scene display vars
    //game
    var board: SKSpriteNode!
    let greenRatio: CGFloat = 73.0 / 80.0       //the percentage of the board sprite that is green
    var blackDisc: SKSpriteNode!
    var whiteDisc: SKSpriteNode!
    var background: SKSpriteNode!
    var clickParticle: SKEmitterNode!
    var touchStartLoc: CGRect!
    
    //text display
    var blackTitleLabel: SKLabelNode!
    var whiteTitleLabel: SKLabelNode!
    var blackCountLabel: SKLabelNode!
    var whiteCountLabel: SKLabelNode!
    var playerTurnLabel: SKLabelNode!
    
    //animations
    var blackToWhiteAnim: SKAction!
    var whiteToBlackAnim: SKAction!
    let animTimePerFrame: Double = 0.05
    
    //buttons
    var pauseButton: SKSpriteNode!
    var soundButton: SKSpriteNode!
    
    //audio
    var isSoundOn: Bool = true
    var audioPlayer = AVAudioPlayer()
    var sfxClickDown: URL!
    var sfxClickUp: URL!
	
    override init(size: CGSize) {
        super.init(size: size)
        touchStartLoc = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        background = SKSpriteNode(imageNamed: "menu-BG")
        background?.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        background?.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        background?.zPosition = -2;
        addChild(background)
        
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "back"))
        addChild(pauseButton)
        pauseButton.anchorPoint = CGPoint(x: 0, y: 0)
        pauseButton.setScale((UIScreen.main.bounds.width / pauseButton.frame.width) * 0.18)
        pauseButton.position = CGPoint(x: UIScreen.main.bounds.width * 0.05, y: UIScreen.main.bounds.width * 0.05)
        
        soundButton = SKSpriteNode(texture: SKTexture(imageNamed: "soundon"))
        addChild(soundButton)
        soundButton.anchorPoint = CGPoint(x: 1, y: 0)
        soundButton.setScale((UIScreen.main.bounds.width / soundButton.frame.width) * 0.18)
        soundButton.position = CGPoint(x: UIScreen.main.bounds.width * 0.95, y: UIScreen.main.bounds.width * 0.05)
        
        sfxClickDown = Bundle.main.url(forResource: "button-click-down", withExtension: "mp3", subdirectory: "Sounds")
        sfxClickUp = Bundle.main.url(forResource: "button-click-up", withExtension: "mp3", subdirectory: "Sounds")
        
        board = SKSpriteNode(texture: SKTexture(imageNamed: "board"))
        addChild(board)
        board.zPosition = -1
        board.setScale(UIScreen.main.bounds.width / (UIScreen.main.bounds.width * 2))
        board.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        blackTitleLabel = SKLabelNode(text: "Black")
        blackTitleLabel.position = CGPoint(x: UIScreen.main.bounds.width * 3/4, y: (board.frame.maxY + UIScreen.main.bounds.height) / 2 +  blackTitleLabel.frame.height/2)
        blackTitleLabel.fontSize = UIScreen.main.bounds.width/10
        blackTitleLabel.horizontalAlignmentMode = .center
        blackTitleLabel.numberOfLines = 0
        addChild(blackTitleLabel)
        
        blackCountLabel = SKLabelNode(text: "\(blackCount)")
        blackCountLabel.position = CGPoint(x: UIScreen.main.bounds.width * 3/4, y: ((board.frame.maxY + UIScreen.main.bounds.height) / 2) - blackCountLabel.frame.height)
        blackCountLabel.fontSize = UIScreen.main.bounds.width/10
        blackCountLabel.horizontalAlignmentMode = .center
        blackCountLabel.numberOfLines = 0
        addChild(blackCountLabel)
        
        whiteTitleLabel = SKLabelNode(text: "White")
        whiteTitleLabel.position = CGPoint(x: UIScreen.main.bounds.width * 1/4, y: (board.frame.maxY + UIScreen.main.bounds.height) / 2 +  whiteTitleLabel.frame.height/2)
        whiteTitleLabel.fontSize = UIScreen.main.bounds.width/10
        whiteTitleLabel.horizontalAlignmentMode = .center
        whiteTitleLabel.numberOfLines = 0
        addChild(whiteTitleLabel)
        
        whiteCountLabel = SKLabelNode(text: "\(whiteCount)")
        whiteCountLabel.position = CGPoint(x: UIScreen.main.bounds.width * 1/4, y: ((board.frame.maxY + UIScreen.main.bounds.height) / 2) - whiteCountLabel.frame.height)
        whiteCountLabel.fontSize = UIScreen.main.bounds.width/10
        whiteCountLabel.horizontalAlignmentMode = .center
        whiteCountLabel.numberOfLines = 0
        addChild(whiteCountLabel)
        
        playerTurnLabel = SKLabelNode(text: "Black's turn.")
        playerTurnLabel.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: board.frame.minY / 2)
        playerTurnLabel.fontSize = UIScreen.main.bounds.width/10
        playerTurnLabel.horizontalAlignmentMode = .center
        addChild(playerTurnLabel)
        
        blackDisc = SKSpriteNode(texture: SKTexture(imageNamed: "black0"))
        addChild(blackDisc)
        blackDisc.position = CGPoint(x: -100, y: -100)                  //spawn off-screen. only used for cloning during runtime
        
        whiteDisc = SKSpriteNode(texture: SKTexture(imageNamed: "white0"))
        addChild(whiteDisc)
        whiteDisc.position = CGPoint(x: -100, y: -100)                  //same as above
        
        var btwFrames: [SKTexture] = [blackDisc.texture!]
        var wtbFrames: [SKTexture] = [whiteDisc.texture!]
        for i in 1..<12 {
            btwFrames.append(SKTexture(imageNamed: "black\(i)"))
            wtbFrames.append(SKTexture(imageNamed: "white\(i)"))
        }
        btwFrames.append(whiteDisc.texture!)
        wtbFrames.append(blackDisc.texture!)
        blackToWhiteAnim = SKAction.animate(with: btwFrames, timePerFrame: animTimePerFrame)
        whiteToBlackAnim = SKAction.animate(with: wtbFrames, timePerFrame: animTimePerFrame)
        
        InitGameState()
        currentTurn = black;
    }
    
    //sets starting game state
    func InitGameState(){
        gameBoard = [[Character]](repeating: [Character](repeating: " ", count: boardSize), count: boardSize)
                
        for i in 0..<boardSize
        {
            for j in 0..<boardSize
            {
                gameBoard[i][j] = empty;
            }
        }        
        
        gameBoard[3][3] = white;
        gameBoard[3][4] = black;
        gameBoard[4][3] = black;
        gameBoard[4][4] = white;
        
        DrawDisc(colour: white, r: 3, c: 3);
        DrawDisc(colour: black, r: 3, c: 4);
        DrawDisc(colour: black, r: 4, c: 3);
        DrawDisc(colour: white, r: 4, c: 4);
    }
    
    //renders <colour> disc at position [r, c] on the game board
    func DrawDisc(colour: Character, r: Int, c: Int) {

        if colour == black
        {
            let newBlackDisc = blackDisc.copy() as! SKSpriteNode
            newBlackDisc.name = "disc\(r)\(c)"
            newBlackDisc.anchorPoint = CGPoint(x: -greenRatio / 2, y: 1 + greenRatio / 2)
            newBlackDisc.setScale(greenRatio * board.xScale)
            newBlackDisc.position = CGPoint(x: board.frame.width * (CGFloat(c) / 8) * greenRatio, y: board.frame.maxY - board.frame.height * (CGFloat(r) / 8) * greenRatio)
            newBlackDisc.position.x += board.frame.minX + CGFloat(c) * 2
            newBlackDisc.position.y -= CGFloat(r) * 2
            addChild(newBlackDisc)
        }
        
        if colour == white
        {
            let newWhiteDisc = whiteDisc.copy() as! SKSpriteNode
            newWhiteDisc.name = "disc\(r)\(c)"
            newWhiteDisc.anchorPoint = CGPoint(x: -greenRatio / 2, y: 1 + greenRatio / 2)
            newWhiteDisc.setScale(greenRatio * board.xScale)
            newWhiteDisc.position = CGPoint(x: board.frame.width * (CGFloat(c) / 8) * greenRatio, y: board.frame.maxY - board.frame.height * (CGFloat(r) / 8) * greenRatio)
            newWhiteDisc.position.x += board.frame.minX + CGFloat(c) * 2
            newWhiteDisc.position.y -= CGFloat(r) * 2
            addChild(newWhiteDisc)
        }
    }
	
	func IsValidMove(colour: Character, r: Int, c: Int) -> Bool {
		var opponent: Character = empty;
		if colour == black { opponent = white; }
		else if colour == white { opponent = black; }
		
		//checks if there is an adjacent opponent disc one direction at a time
		//returns true if at least one direction returns true
		if gameBoard[r][c] == empty
		{
			var distanceToEdge: Int = 0;
			
			//bottom
			if r + 1 < boardSize, gameBoard[r + 1][c] == opponent
			{
				distanceToEdge = boardSize - 1 - r;
				for x in 1...distanceToEdge
				{
					if gameBoard[r + x][c] == colour
					{
						return true;
					}
				}
			}
			
			//top
			if r - 1 > -1, gameBoard[r - 1][c] == opponent
			{
				distanceToEdge = r;
				for x in 1...distanceToEdge
				{
					if gameBoard[r - x][c] == colour
					{
						return true;
					}
				}
			}
			
			//right
			if c + 1 < boardSize, gameBoard[r][c + 1] == opponent
			{
				distanceToEdge = boardSize - 1 - c;
				for y in 1...distanceToEdge
				{
					if gameBoard[r][c + y] == colour
					{
						return true;
					}
				}
			}
			
			//left
			if c - 1 > -1, gameBoard[r][c - 1] == opponent
			{
				distanceToEdge = c;
				for y in 1...distanceToEdge
				{
					if gameBoard[r][c - y] == colour
					{
						return true;
					}
				}
			}
			
			//bottom right
			if r + 1 < boardSize, c + 1 < boardSize, gameBoard[r + 1][c + 1] == opponent
			{
				distanceToEdge = min(boardSize - 1 - r, boardSize - 1 - c);
				for xy in 1...distanceToEdge
				{
					if gameBoard[r + xy][c + xy] == colour
					{
						return true;
					}
				}
			}
			
			//bottom left
			if r + 1 < boardSize, c - 1 > -1, gameBoard[r + 1][c - 1] == opponent
			{
				distanceToEdge = min(boardSize - 1 - r, c);
				for xy in 1...distanceToEdge
				{
					if gameBoard[r + xy][c - xy] == colour
					{
						return true;
					}
				}
			}
			
			//top left
			if r - 1 > -1, c - 1 > -1, gameBoard[r - 1][c - 1] == opponent
			{
				distanceToEdge = min(r, c);
				for xy in 1...distanceToEdge
				{
					if gameBoard[r - xy][c - xy] == colour
					{
						return true;
					}
				}
			}
			
			//top right
			if r - 1 > -1, c + 1 < boardSize, gameBoard[r - 1][c + 1] == opponent
			{
				distanceToEdge = min(r, boardSize - 1 - c);
				for xy in 1...distanceToEdge
				{
					if gameBoard[r - xy][c + xy] == colour
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}
    
	//places disc on board, immediately calls FlipDiscs()
	func PlaceDisc(colour: Character, r: Int, c: Int) {
		gameBoard[r][c] = colour
		DrawDisc(colour: colour, r: r, c: c)
        
		for i in stride(from: 0, to:Double.pi * 2, by:Double.pi / 4)
		{			
			FlipDiscs(colour: colour, r: r, c: c, yDelta: Int(round(sin(i))), xDelta: Int(round(sin(i + Double.pi / 2))));
		}
	}

	//flips discs according to standard Othello rules
	func FlipDiscs(colour: Character, r: Int, c: Int, yDelta: Int, xDelta: Int) {
		var nextRow: Int = r + yDelta;
		var nextCol: Int = c + xDelta;
		
        //holy motherfu-- what is this abomination
		if nextRow < boardSize, nextRow > -1, nextCol < boardSize, nextCol > -1
		{
			while gameBoard[nextRow][nextCol] != empty
			{
				if gameBoard[nextRow][nextCol] == colour
				{
					while !(r == nextRow && c == nextCol)
					{
                        if gameBoard[nextRow][nextCol] != colour {
                            gameBoard[nextRow][nextCol] = colour;
                            AnimateDisc(colour: colour == black ? black : white, r: nextRow, c: nextCol)
                        }
						nextRow -= yDelta;
						nextCol -= xDelta;
					}
					break;
				}
				else
				{
					nextRow += yDelta;
					nextCol += xDelta;
				}
			}
		}
	}
    
    func AnimateDisc(colour: Character, r: Int, c: Int) {
        childNode(withName: "disc\(r)\(c)")?.removeFromParent()
        DrawDisc(colour: colour, r: r, c: c)
        childNode(withName: "disc\(r)\(c)")?.run(colour == black ? whiteToBlackAnim : blackToWhiteAnim)
    }
	
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder: ) has not been implemented")
    }
    
	func IsGameOver() -> Bool {
		return blackCount + whiteCount >= boardSize * boardSize;
    }
    
    func GetDiscCount(colour: Character) -> Int{
        var discCount: Int = 0
        
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                if gameBoard[i][j] == colour {
                    discCount += 1
                }
            }
        }
        
        return discCount
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        blackCount = GetDiscCount(colour: black)
        whiteCount = GetDiscCount(colour: white)
        blackCountLabel.text = "\(blackCount)"
        whiteCountLabel.text = "\(whiteCount)"
        
        if IsGameOver() {
            playerTurnLabel.text = (blackCount > whiteCount ? "Black wins!" : (blackCount == whiteCount ? "Tie game!" : "White wins!"))
        }
    }
    
    func PlaySound(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if isSoundOn {
                audioPlayer.play()
            }
        } catch {
            print("Couldn't play file!")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if pauseButton.frame.contains(t.location(in: self)) {
                pauseButton.texture = SKTexture(imageNamed: "back-pressed")
                PlaySound(url: sfxClickDown)
                touchStartLoc = pauseButton.frame
            }
            
            if (soundButton.frame.contains(t.location(in: self))) {
                soundButton.texture = SKTexture(imageNamed: isSoundOn ? "soundon-pressed" : "soundoff-pressed")
                PlaySound(url: sfxClickDown)
                touchStartLoc = soundButton.frame
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            clickParticle = SKEmitterNode(fileNamed: "ClickParticle.sks")
            clickParticle.position = t.location(in: self)
            scene?.addChild(clickParticle)
			
            if (!IsGameOver()) {
                if board.frame.contains(t.location(in: self)) {
                    let row: Int = Int(floor((board.frame.maxY - t.location(in: self).y) / (board.frame.height / 8)))
                    let col: Int = Int(floor((t.location(in: self).x - board.frame.minX) / (board.frame.width / 8)))
                    if IsValidMove(colour: currentTurn, r: row, c: col) {
                        PlaceDisc(colour: currentTurn, r: row, c: col)
                        if currentTurn == black {
                            currentTurn = white
                            playerTurnLabel.text = "White's turn."
                        }
                        else if currentTurn == white {
                            currentTurn = black
                            playerTurnLabel.text = "Black's turn."
                        }
                    }
                }
            }
			
            if (pauseButton.frame.contains(t.location(in: self)) && touchStartLoc!.equalTo(pauseButton.frame)) {
                let scene = MainMenuScene(size: self.size)
                let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
                self.view?.presentScene(scene, transition:transition)
                PlaySound(url: sfxClickUp)
            }
            
            if (soundButton.frame.contains(t.location(in: self)) && touchStartLoc!.equalTo(soundButton.frame)) {
                if (isSoundOn) {
                    soundButton.texture = SKTexture(imageNamed: "soundoff")
                    isSoundOn = false;
                    //no need to play sound here
                }
                else
                {
                    soundButton.texture = SKTexture(imageNamed: "soundon")
                    isSoundOn = true
                    PlaySound(url: sfxClickUp)
                }
            }
			
            if (!pauseButton.frame.contains(t.location(in: self)) ||
                !soundButton.frame.contains(t.location(in: self))) {
                pauseButton.texture = SKTexture(imageNamed: "back")
                soundButton.texture = SKTexture(imageNamed: isSoundOn ? "soundon" : "soundoff")
                touchStartLoc = CGRect(x: 0, y: 0, width: 0, height: 0)
                return;
            }
            
            if (!IsGameOver()) {
                if board.frame.contains(t.location(in: self)) {
                    let row: Int = Int(floor((board.frame.maxY - t.location(in: self).y) / (board.frame.height / 8)))
                    let col: Int = Int(floor((t.location(in: self).x - board.frame.minX) / (board.frame.width / 8)))
                    if IsValidMove(colour: currentTurn, r: row, c: col) {
                        PlaceDisc(colour: currentTurn, r: row, c: col)
                    }
                }
            }
        }
    }
}
