import Foundation
import SpriteKit

class PauseNode: SKSpriteNode {
    
    private var appMusic: SKSpriteNode
    private var appSounds: SKSpriteNode
    
    init(size: CGSize) {
        let back = SKSpriteNode(imageNamed: "battle_field")
         back.position = CGPoint(x: size.width / 2, y: size.height / 2)
         back.size = size
        
        let pauseTitle = SKLabelNode(text: "PAUSE")
        pauseTitle.fontName = "IrishGrover-Regular"
        pauseTitle.fontSize = 62
        pauseTitle.fontColor = .white
        pauseTitle.position = CGPoint(x: size.width / 2, y: size.height - 300)
        
        let gamePausedTitle = SKLabelNode(text: "GAME PAUSED!")
        gamePausedTitle.fontName = "IrishGrover-Regular"
        gamePausedTitle.fontSize = 42
        gamePausedTitle.fontColor = .white
        gamePausedTitle.position = CGPoint(x: size.width / 2, y: size.height - 450)
        
        let gameResumeButton = SKSpriteNode(imageNamed: "game_resume")
        gameResumeButton.size = CGSize(width: 160, height: 150)
        gameResumeButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameResumeButton.name = "resume_game"
        
        let home = SKSpriteNode(imageNamed: "home_button")
        home.size = CGSize(width: 160, height: 150)
        home.position = CGPoint(x: size.width / 2 - 190, y: size.height / 2)
        home.name = "home_button"
        
        let restart = SKSpriteNode(imageNamed: "game_restart")
        restart.size = CGSize(width: 160, height: 150)
        restart.position = CGPoint(x: size.width / 2 + 190, y: size.height / 2)
        restart.name = "game_restart"
        
        var apM = "button_app_music"
        if !UserDefaults.standard.bool(forKey: "is_music_on") {
            apM += "_off"
        }
        appMusic = SKSpriteNode(imageNamed: apM)
        appMusic.size = CGSize(width: 100, height: 90)
        appMusic.position = CGPoint(x: size.width / 2 + 75, y: size.height / 2 - 160)
        appMusic.name = "button_app_music"
        
        var apS = "button_sounds"
        if !UserDefaults.standard.bool(forKey: "is_sounds_app_on") {
            apS += "_off"
        }
        appSounds = SKSpriteNode(imageNamed: apS)
        appSounds.size = CGSize(width: 100, height: 90)
        appSounds.position = CGPoint(x: size.width / 2 - 75, y: size.height / 2 - 160)
        appSounds.name = "button_sounds"
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(back)
        addChild(pauseTitle)
        addChild(gamePausedTitle)
        addChild(gameResumeButton)
        addChild(home)
        addChild(restart)
        addChild(appMusic)
        addChild(appSounds)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let pointObject = atPoint(location)
        
        if pointObject.name == "resume_game" {
            (self.parent as? GameBattleEnvasionScene)?.hidePauseNode()
            return
        }
        
        if pointObject.name == "button_app_music" {
            if let par = self.parent as? GameBattleEnvasionScene {
                par.isMusicOn = !par.isMusicOn
                if par.isMusicOn {
                    let texture = SKTexture(imageNamed: "button_app_music")
                    appMusic.texture = texture
                } else {
                    let texture = SKTexture(imageNamed: "button_app_music_off")
                    appMusic.texture = texture
                }
            }
            return
        }
        
        if pointObject.name == "button_sounds" {
            let isSoundsOn = UserDefaults.standard.bool(forKey: "is_sounds_app_on")
            UserDefaults.standard.set(!isSoundsOn, forKey: "is_sounds_app_on")
            if UserDefaults.standard.bool(forKey: "is_sounds_app_on") {
                let texture = SKTexture(imageNamed: "button_sounds")
                appSounds.texture = texture
            } else {
                let texture = SKTexture(imageNamed: "button_sounds_off")
                appSounds.texture = texture
            }
            return
        }
        
        if pointObject.name == "home_button" {
            NotificationCenter.default.post(name: Notification.Name("home_act"), object: nil)
            return
        }
        
        if pointObject.name == "game_restart" {
            NotificationCenter.default.post(name: Notification.Name("game_restart"), object: nil)
            return
        }
        
        
    }
    
}
