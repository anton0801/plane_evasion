import SpriteKit
import SwiftUI

class GameBattleEnvasionScene: SKScene, SKPhysicsContactDelegate {
    
    var evasionStage: EvasionStage
    
    init(evasionStage: EvasionStage) {
        self.evasionStage = evasionStage
        super.init(size: CGSize(width: 750, height: 1335))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var aircraft = SKSpriteNode()
    
    var aircraftShieldButton = SKSpriteNode()
    var aircraftSlowButton = SKSpriteNode()
    var aircraftPauseButton = SKSpriteNode()
    
    var pauseNode: PauseNode!
    
    var isSlowedDown = false
    var isShieldUsed = false {
        didSet {
            if isShieldUsed {
                shield = .init(imageNamed: "shield")
                shield.size = CGSize(width: 250, height: 270)
                shield.position = aircraft.position
                shield.zPosition = 5
                shield.name = "shield"
                shield.physicsBody = SKPhysicsBody(circleOfRadius: shield.size.width / 2)
                shield.physicsBody!.isDynamic = false
                shield.physicsBody!.affectedByGravity = false
                shield.physicsBody!.categoryBitMask = .shield
                shield.physicsBody!.collisionBitMask = .enemy | .bossBullet
                shield.physicsBody!.contactTestBitMask = .enemy | .bossBullet
                addChild(shield)
                
                let actionFadeId = SKAction.fadeIn(withDuration: 0.3)
                shield.run(actionFadeId)
            } else {
                let actionFadeId = SKAction.fadeOut(withDuration: 0.3)
                shield.run(actionFadeId) {
                    self.shield.removeFromParent()
                }
            }
        }
    }
    var shield = SKSpriteNode()
    
    var timeFill = SKSpriteNode()
    
    var attackLevel = UserDefaults.standard.integer(forKey: "attack_level")
    
    var balanceLabel = SKLabelNode(text: "")
    private var balance: Int = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
            balanceLabel.text = "\(balance)"
        }
    }
    
    private var aircraftBulletFire = Timer()
    private var aircraftEnemies = Timer()
    
    private var timer = Timer()
    
    var totalTime: CGFloat = 10.0
    var elapsedTime: CGFloat = 0.0 {
        didSet {
            if elapsedTime == totalTime {
                NotificationCenter.default.post(name: Notification.Name("elapsed_all_time"), object: nil)
            }
        }
    }
    
    private var currentAircraft: String {
        get {
            return UserDefaults.standard.string(forKey: "aircraft") ?? "shooter_aircraft"
        }
    }
    
    var isSoundsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "is_sounds_app_on")
        }
    }
    
    var isMusicOn: Bool = UserDefaults.standard.bool(forKey: "is_music_on") {
        didSet {
            if isMusicOn {
                let audioNode = SKAudioNode(fileNamed: "back_m.wav")
                addChild(audioNode)
            } else {
                for child in children {
                    if child is SKAudioNode {
                        child.removeFromParent()
                    }
                }
            }
            UserDefaults.standard.set(isMusicOn, forKey: "is_music_on")
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = CGSize(width: 750, height: 1335)
        
        isMusicOn = UserDefaults.standard.bool(forKey: "is_music_on")
        
        totalTime = CGFloat(20 + (5 * evasionStage.id))
        
        battleField()
        aircraftPlane()
        aircraftActionButtons()
        createTimeView()
        balanceView()
        
        startGame()
    }
    
    private func balanceView() {
        balanceLabel.text = "\(balance)"
        balanceLabel.fontName = "IrishGrover-Regular"
        balanceLabel.fontSize = 72
        balanceLabel.fontColor = .white
        balanceLabel.zPosition = 5
        balanceLabel.position = CGPoint(x: size.width / 2 - 20, y: size.height - 130)
        addChild(balanceLabel)
        
        let c = SKSpriteNode(imageNamed: "coin_button")
        c.position = CGPoint(x: size.width / 2 + 60, y: size.height - 100)
        c.zPosition = 5
        addChild(c)
    }
    
    private func createTimeView() {
        let fillTexture = SKTexture.roundedRect(size: CGSize(width: 650, height: 30), radius: 24, color: UIColor.init(red: 250/255, green: 94/255, blue: 94/255, alpha: 1))
        let strokeTexture = SKTexture.roundedStrokeRect(size: CGSize(width: 650, height: 40), radius: 120, strokeColor: UIColor.init(red: 242/255, green: 195/255, blue: 84/255, alpha: 1), lineWidth: 5)
        let timeBorder = SKSpriteNode(texture: strokeTexture)
        timeBorder.position = CGPoint(x: size.width / 2, y: size.height - 100)
        timeBorder.zPosition = 2
        addChild(timeBorder)
        
        timeFill = SKSpriteNode(texture: fillTexture)
        timeFill.zPosition = 1
        timeFill.anchorPoint = CGPoint(x: -0.08, y: 0.5)
        timeFill.position = CGPoint(x: frame.midX - size.width / 2, y: size.height - 100)
        addChild(timeFill)
    }
    
    private func startGame() {
        spawnEnemies()
        
        var aircraftBulletsTime = 0.5
        if attackLevel == 2 {
            aircraftBulletsTime = 0.45
        } else if attackLevel == 3 {
            aircraftBulletsTime = 0.4
        } else if attackLevel == 4 {
            aircraftBulletsTime = 0.3
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateFillNode), userInfo: nil, repeats: true)
        aircraftBulletFire = .scheduledTimer(timeInterval: aircraftBulletsTime, target: self, selector: #selector(aircraftFire), userInfo: nil, repeats: true)
        aircraftEnemies = .scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(spawnEnemies), userInfo: nil, repeats: true)
    }
    
    @objc func updateFillNode() {
        elapsedTime += 1
        let remainingTime = max(totalTime - elapsedTime, 0)
        let percentage = remainingTime / totalTime
        
        // Adjust the width of the fillNode based on the percentage
        timeFill.size.width = timeFill.texture!.size().width * percentage
        timeFill.anchorPoint.x -= 0.01
        
        if remainingTime == 0 {
            timer.invalidate()
        }
    }
    
    private func battleField() {
        let back = SKSpriteNode(imageNamed: "battle_field")
        back.position = CGPoint(x: size.width / 2, y: size.height / 2)
        back.size = size
        addChild(back)
    }
    
    private func aircraftPlane() {
        aircraft = .init(imageNamed: currentAircraft)
        aircraft.position = CGPoint(x: size.width / 2, y: 250)
        aircraft.size = CGSize(width: 200, height: 140)
        aircraft.name = "aircraft"
        aircraft.zPosition = 2
        aircraft.physicsBody = SKPhysicsBody(rectangleOf: aircraft.size)
        aircraft.physicsBody!.isDynamic = false
        aircraft.physicsBody!.affectedByGravity = false
        aircraft.physicsBody!.categoryBitMask = .plane
        aircraft.physicsBody!.collisionBitMask = .enemy | .bossBullet // 4 is enemy boss bullets
        aircraft.physicsBody!.contactTestBitMask = .enemy | .bossBullet
        addChild(aircraft)
    }
    
    private func aircraftActionButtons() {
        aircraftShieldButton = .init(imageNamed: "aircraft_shield")
        aircraftShieldButton.position = CGPoint(x: size.width / 2 - 120, y: 100)
        aircraftShieldButton.size = CGSize(width: 100, height: 90)
        aircraftShieldButton.name = "shield_button"
        addChild(aircraftShieldButton)
        
        aircraftPauseButton = .init(imageNamed: "pause_game_field")
        aircraftPauseButton.position = CGPoint(x: size.width / 2, y: 100)
        aircraftPauseButton.size = CGSize(width: 100, height: 90)
        aircraftPauseButton.name = "pause_game_field"
        addChild(aircraftPauseButton)
        
        aircraftSlowButton = .init(imageNamed: "aircrafts_slow")
        aircraftSlowButton.position = CGPoint(x: size.width / 2 + 120, y: 100)
        aircraftSlowButton.size = CGSize(width: 100, height: 90)
        aircraftSlowButton.name = "slow_aircrafts"
        addChild(aircraftSlowButton)
        
        let boostPrice1 = SKSpriteNode(imageNamed: "boost_price")
        boostPrice1.position.x = aircraftShieldButton.position.x
        boostPrice1.position.y = aircraftShieldButton.position.y - 65
        addChild(boostPrice1)
        
        let boostPrice2 = SKSpriteNode(imageNamed: "boost_price")
        boostPrice2.position.x = aircraftSlowButton.position.x
        boostPrice2.position.y = aircraftSlowButton.position.y - 65
        addChild(boostPrice2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let pointObject = atPoint(location)
        
        guard pointObject.name != "shield_button" else {
            if balance >= 15 {
                if !isShieldUsed {
                    isShieldUsed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                        self.isShieldUsed = false
                    }
                }
                balance -= 15
            }
            return
        }
        guard pointObject.name != "pause_game_field" else {
            showPauseNode()
            return
        }
        guard pointObject.name != "slow_aircrafts" else {
            if balance >= 15 {
                if !isSlowedDown {
                    isSlowedDown = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                        self.isSlowedDown = false
                    }
                }
                balance -= 15
            }
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let pointObject = atPoint(location)
        
        guard pointObject.name != "aircraft" else {
            if location.x > 50 && location.x < size.width - 50 {
                aircraft.position.x = location.x
            }
            return
        }
        
        guard pointObject.name != "shield" else {
            if location.x > 50 && location.x < size.width - 50 {
                aircraft.position.x = location.x
                shield.position.x = location.x
            }
            return
        }
    }
    
    private func showPauseNode() {
        isPaused = true
        if pauseNode == nil {
            pauseNode = PauseNode(size: size)
            pauseNode.zPosition = 12
            pauseNode.position = CGPoint(x: 0, y: 0)
        }
        addChild(pauseNode)
        let actionAppear = SKAction.fadeIn(withDuration: 0.5)
        pauseNode.run(actionAppear)
    }
    
    func hidePauseNode() {
        self.pauseNode.removeFromParent()
        self.isPaused = false
    }
    
    @objc private func aircraftFire() {
        if !isPaused {
            let bulletNode = SKSpriteNode(imageNamed: "bullet")
            bulletNode.position.x = aircraft.position.x
            bulletNode.position.y = aircraft.position.y + 120
            bulletNode.name = "bullet"
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
            bulletNode.physicsBody!.isDynamic = true
            bulletNode.physicsBody!.affectedByGravity = false
            bulletNode.physicsBody!.categoryBitMask = .bullet
            bulletNode.physicsBody!.collisionBitMask = .enemy
            bulletNode.physicsBody!.contactTestBitMask = .enemy
            bulletNode.zPosition = 1
            addChild(bulletNode)
            
            if isSoundsEnabled {
                let actionMoveBullet = SKAction.move(to: CGPoint(x: bulletNode.position.x, y: size.height), duration: 2)
                let soundAction = SKAction.playSoundFileNamed("fire_audio.wav", waitForCompletion: false)
                let seq = SKAction.sequence([soundAction, actionMoveBullet])
                bulletNode.run(seq) { bulletNode.removeFromParent() }
            } else {
                let actionMoveBullet = SKAction.move(to: CGPoint(x: bulletNode.position.x, y: size.height), duration: 2)
                bulletNode.run(actionMoveBullet) { bulletNode.removeFromParent() }
            }
        }
    }
    
    @objc private func spawnEnemies() {
        let enemyWidth = (size.width / 3) + CGFloat.random(in: 30...60)
        for i in 0..<3 {
            spawnEnemy(x: (CGFloat(i) * (enemyWidth)) + 50)
        }
    }
    
    private func spawnEnemy(x: CGFloat) {
        if !isPaused {
            let enemyNode = SKSpriteNode(imageNamed: "enemy_aircraft")
            enemyNode.position = CGPoint(x: x, y: size.height)
            enemyNode.name = "enemy_aircraft"
            enemyNode.size =  CGSize(width: 200, height: 140)
            enemyNode.physicsBody = SKPhysicsBody(rectangleOf: enemyNode.size)
            enemyNode.physicsBody!.isDynamic = true
            enemyNode.physicsBody!.affectedByGravity = false
            enemyNode.physicsBody!.categoryBitMask = .enemy
            enemyNode.physicsBody!.collisionBitMask = .bullet | .plane
            enemyNode.physicsBody!.contactTestBitMask = .bullet | .plane
            addChild(enemyNode)
            
            if isSlowedDown {
                let enemyGoAction = SKAction.move(to: CGPoint(x: enemyNode.position.x, y: -100), duration: 7)
                enemyNode.run(enemyGoAction) { enemyNode.removeFromParent() }
            } else {
                let enemyGoAction = SKAction.move(to: CGPoint(x: enemyNode.position.x, y: -100), duration: 4)
                enemyNode.run(enemyGoAction) { enemyNode.removeFromParent() }
            }
        }
    }
    
    private func spawnBossOne() {
        
    }
    
    private func spawnBossTwo() {
        
    }
    
    private func spawnBossTree() {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB
        
        if a.categoryBitMask == .shield && b.categoryBitMask == .enemy ||
            a.categoryBitMask == .enemy && b.categoryBitMask == .shield {
            // enemy with bullet
            
            let shieldBody: SKPhysicsBody
            let enemyBody: SKPhysicsBody
            
            if a.categoryBitMask == .shield {
                shieldBody = a
                enemyBody = b
            } else {
                shieldBody = b
                enemyBody = a
            }
            
            if let node = enemyBody.node {
                let expNode = SKSpriteNode(imageNamed: "explosion")
                expNode.position = node.position
                addChild(expNode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    expNode.removeFromParent()
                }
            }
            enemyBody.node?.removeFromParent()
        }
        
        if a.categoryBitMask == .bullet && b.categoryBitMask == .enemy ||
            a.categoryBitMask == .enemy && b.categoryBitMask == .bullet {
            // enemy with bullet
            
            let bulletBody: SKPhysicsBody
            let enemyBody: SKPhysicsBody
            
            if a.categoryBitMask == .bullet {
                bulletBody = a
                enemyBody = b
            } else {
                bulletBody = b
                enemyBody = a
            }
            
            if let node = enemyBody.node {
                let expNode = SKSpriteNode(imageNamed: "explosion")
                expNode.position = node.position
                addChild(expNode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    expNode.removeFromParent()
                }
            }
            enemyBody.node?.removeFromParent()
            bulletBody.node?.removeFromParent()
        }
        
        if a.categoryBitMask == .enemy && b.categoryBitMask == .plane ||
            a.categoryBitMask == .plane && b.categoryBitMask == .enemy {
            let enemyBody: SKPhysicsBody
            let aircraftBody: SKPhysicsBody
            
            if a.categoryBitMask == .enemy {
                enemyBody = a
                aircraftBody = b
            } else {
                aircraftBody = b
                enemyBody = a
            }
            
            enemyBody.node?.removeFromParent()
            aircraftBody.node?.removeFromParent()
            
            if let node = enemyBody.node {
                let expNode = SKSpriteNode(imageNamed: "explosion")
                expNode.position = node.position
                addChild(expNode)
            }
            
            if isSoundsEnabled {
                let actionDefeateSound = SKAction.playSoundFileNamed("DEFEAT.WAV", waitForCompletion: false)
                run(actionDefeateSound)
            }
            
            aircraftBulletFire.invalidate()
            aircraftEnemies.invalidate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: Notification.Name("DEFEAT"), object: nil)
            }
        }
    }
    
    func restartGameSceneView() -> GameBattleEnvasionScene {
        var gameBattle = GameBattleEnvasionScene(evasionStage: evasionStage)
        view?.presentScene(gameBattle)
        return gameBattle
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: GameBattleEnvasionScene(evasionStage: EvasionStage(id: 1, isUnlocked: true)))
            .ignoresSafeArea()
    }
}

extension UInt32 {
    static let bullet: UInt32 = 1
    static let plane: UInt32 = 2
    static let enemy: UInt32 = 3
    static let bossBullet: UInt32 = 4
    static let shield: UInt32 = 5
}
