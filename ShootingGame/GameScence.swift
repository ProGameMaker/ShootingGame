//
//  GameScence.swift
//  ShootingGame
//
//  Created by Nguyễn Trí on 8/28/18.
//  Copyright © 2018 Nguyễn Trí. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let monster   : UInt32 = 0b1       // 1
        static let projectile: UInt32 = 0b10      // 2
    }
    
    var score = 0
    let Score = SKLabelNode()
    
    var NewShip = mySpriteNode()
    var background = SKSpriteNode()
    
    var bullet = mySpriteNode()
    var ostacle = mySpriteNode()
    
    //private var bear = SKSpriteNode()
    var bearWalkingFrames: [SKTexture] = []
    var beamWalkingFrames: [SKTexture] = []
    var ostacleWalkingFrames: [SKTexture] = []
    
    class mySpriteNode: SKSpriteNode {
        
        var health : Int32 = 0
    }
    
    func interval(location: CGPoint, present: CGPoint) -> Double {
        
        return Double(sqrt((location.x - present.x)*(location.x - present.x) + (location.y - present.y)*(location.y - present.y))/500)
    }
    
    func buildShipAnimation() {
        
        let bearAnimatedAtlas = SKTextureAtlas(named: "Ship")
        var walkFrames: [SKTexture] = []
        
        let numImages = bearAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let bearTextureName = "\(i)"
            walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
        }
        bearWalkingFrames = walkFrames
        
        let firstFrameTexture = bearWalkingFrames[0]
        NewShip = mySpriteNode(texture: firstFrameTexture)
        //bear.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(NewShip)
    }
    
    func runShipAnimation() {
        NewShip.run(SKAction.repeatForever(
            SKAction.animate(with: bearWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)))
    }
    
    func buildBeamAnimation() {
        
        let bearAnimatedAtlas = SKTextureAtlas(named: "Beam")
        var walkFrames: [SKTexture] = []
        
        let numImages = bearAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let bearTextureName = "\(i)"
            walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
        }
        beamWalkingFrames = walkFrames
        
        let firstFrameTexture = beamWalkingFrames[0]
        bullet = mySpriteNode(texture: firstFrameTexture)
        //bear.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func runBeamAnimation(Interval: Double) {
        bullet.run(SKAction.repeatForever(
            SKAction.animate(with: beamWalkingFrames,
                             timePerFrame: Interval/2.2,
                             resize: true,
                             restore: true)))
    }
    
    func buildOstacleAnimation() {
        
        let bearAnimatedAtlas = SKTextureAtlas(named: "glitch_meteor")
        var walkFrames: [SKTexture] = []
        
        let numImages = bearAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let bearTextureName = "\(i)"
            walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
        }
        ostacleWalkingFrames = walkFrames
        
        let firstFrameTexture = ostacleWalkingFrames[0]
        ostacle = mySpriteNode(texture: firstFrameTexture)
        //bear.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func runOstacleAnimation() {
        ostacle.run(SKAction.repeatForever(
            SKAction.animate(with: ostacleWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)))
    }
    
    func AddObstacle() {
        
        buildOstacleAnimation()
        
       // let ostacleTexture = SKTexture(imageNamed: "comet")
       // let ostacle = mySpriteNode(texture: ostacleTexture)
        let random = (view?.frame.size.width)!/10 +  CGFloat(Int(arc4random_uniform(UInt32((view?.frame.size.width)!*6/10))))
        
        ostacle.position = CGPoint(x: random, y: 1000);
        ostacle.health = 2
        
        addChild(ostacle)
        
        ostacle.physicsBody = SKPhysicsBody(texture: ostacle.texture!, size: CGSize(width: ostacle.size.width, height: ostacle.size.height))
        ostacle.physicsBody?.isDynamic = true // 2
        ostacle.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        ostacle.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        ostacle.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        let actionMove = SKAction.move(to: CGPoint(x: random, y: 0),duration: 1.8)
        
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() { [weak self] in
            guard let `self` = self else { return }
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        let ostacleAnimation = SKAction.run {
            self.runOstacleAnimation()
        }
        
        let group = SKAction.group([SKAction.sequence([actionMove,loseAction,actionMoveDone]),ostacleAnimation])
        
        ostacle.run(group)
    }
    
    func AddBullet() {
        
        buildBeamAnimation()
        
        //let bulletTexture = SKTexture(imageNamed: "images")
        //bullet = mySpriteNode(texture: bulletTexture)
        
        bullet.position = CGPoint(x: NewShip.frame.origin.x + NewShip.frame.width/2, y: NewShip.frame.origin.y + 3/2 * NewShip.frame.height)
        bullet.health = 1
        
        addChild(bullet)
        
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: CGSize(width: bullet.size.width, height: bullet.size.height))
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        let Interval: Double = interval(location: CGPoint(x: bullet.frame.origin.x,y: (view?.frame.height)!), present: bullet.position)
        
        let actionMove = SKAction.move(to: CGPoint(x: NewShip.frame.origin.x + NewShip.frame.width/2, y: ((view?.frame.height)!)/1.5),duration: Interval)
        
        let bulletAnimation = SKAction.run {self.runBeamAnimation(Interval: Interval)}
        
        //run(loseAction)
        let actionMoveDone = SKAction.removeFromParent()
        let group = SKAction.group([SKAction.sequence([actionMove,actionMoveDone]),bulletAnimation])
        
        bullet.run(group)
        
    }
    
    /*override func sceneDidLoad() {
        
        background = SKSpriteNode(imageNamed: "full-resolution-1280")
        background.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        addChild(background)
    }*/
    
    func createGround() {
        
        for i in 0...3 {
            
            let ground = SKSpriteNode(imageNamed: "full-resolution-1280")
            ground.name = "Ground"
            ground.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
            ground.anchorPoint = CGPoint(x: 0, y: 0)
            ground.position = CGPoint(x: 0, y: CGFloat(i)*ground.size.height)
            
            ground.zPosition = -2
            self.addChild(ground)
        }
    }
    
    func moveGround() {
        
        self.enumerateChildNodes(withName: "Ground", using: ({
            
            (node,error) in
            node.position.y -= 2
            
            if (node.position.y < -(self.scene?.size.height)!) {
                
                node.position.y += (self.scene?.size.height)!*3
                
            }
            
        }))
    }
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        createGround()
        
        buildShipAnimation()
        // To get the saved score
        //background.removeFromParent()
        //background = SKSpriteNode(imageNamed: "Galaxy_Background")
        //background.zPosition = -1
        //background.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        //background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        //addChild(background)
        
        Score.fontName = "YourFontName-Bold"
        Score.fontColor = SKColor.white
        Score.text = String(score)
        Score.position = CGPoint(x: view.frame.width/2, y: view.frame.height - view.frame.height/10)
        
        backgroundColor = SKColor.white
        
        NewShip.position = CGPoint(x: view.frame.width/2, y: 100)
        NewShip.isUserInteractionEnabled = true
        
        addChild(Score)
        //addChild(NewShip)
    
        NewShip.physicsBody = SKPhysicsBody(circleOfRadius: NewShip.size.width/100)
        NewShip.physicsBody?.isDynamic = true
        NewShip.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        NewShip.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        NewShip.physicsBody?.collisionBitMask = PhysicsCategory.none
        NewShip.physicsBody?.usesPreciseCollisionDetection = true
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        let ostacle = SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run(AddObstacle)]))
        
        let bullet = SKAction.repeatForever(SKAction.sequence([SKAction.run(AddBullet),SKAction.wait(forDuration: 0.3)]))
        
        let animation = SKAction.run {
            self.runShipAnimation()
        }
        
        let group = SKAction.group([ostacle,bullet,animation])
        
        let backgroundMusic = SKAudioNode(fileNamed: "Space_Idea")
        backgroundMusic.autoplayLooped = true
        //backgroundMusic.run(SKAction.changeVolume(by: Float(0.1), duration: 0))
        addChild(backgroundMusic)
        
        //sleep(2)
        run(group)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //var pre = CGPoint(x :0, y: 0)
        for touch in touches {
            
            let location = touch.location(in: self)
            /*if (pre == location) {
             NewShip.run(SKAction.move(to: location, duration: 0))
             }
             else*/
            
            NewShip.run(SKAction.move(to: location, duration: interval(location: location,present: NewShip.position)))
            // pre = location
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            // if (NewShip.contains(location)) {
            NewShip.run(SKAction.move(to: location, duration: interval(location: location,present: NewShip.position)))
            //}
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        moveGround()
    }
    
    func projectileDidCollideWithMonster(projectile: mySpriteNode, monster: mySpriteNode) {
        print("Hit")
        
        if (projectile == NewShip) {
            
            let loseAction = SKAction.run() { //[weak self] in
                //guard let `self` = self else { return }
                self.Score.removeFromParent()
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, score: self.score)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            
            run(loseAction)
            
            //exit(0)
        }
        
        //let backgroundMusic = SKAudioNode(fileNamed: "boulder_impact_from_catapult_or_trebuchet.mp3")
        run(SKAction.playSoundFileNamed("boulder_impact_from_catapult_or_trebuchet.mp3", waitForCompletion: false))
        //backgroundMusic.run(SKAction.changeVolume(by: Float(0), duration: -100))
        //addChild(backgroundMusic)
        
        projectile.health = projectile.health - 1
        monster.health = monster.health - 1
        
        if (projectile.health == 0) {
            projectile.texture = SKTexture(imageNamed: "3") //IsNessesary ??
            projectile.removeFromParent()
        }
        if (monster.health == 0) {
            
            monster.removeFromParent(); score = score + 1 }
    }
}

extension GameScene: SKPhysicsContactDelegate {
 
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? mySpriteNode,
                let projectile = secondBody.node as? mySpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    
        Score.text = String(score);
        
    }
}




