import SwiftUI
import SpriteKit

struct EvasionGameView: View {
    
    var evasionStagesManager: EvasionStagesManager
    var evasionStage: EvasionStage
    
    @Environment(\.presentationMode) var pmod
    
    @State var evasionScene: GameBattleEnvasionScene?
    
    var center = NotificationCenter.default
    
    
    @State var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    
    @State var gameOver = false
    @State var gameWin = false
    
    var body: some View {
        VStack {
            if evasionScene != nil {
                SpriteView(scene: evasionScene!)
                    .ignoresSafeArea()
                    .onReceive(center.publisher(for: Notification.Name("elapsed_all_time")), perform: { _ in
                        self.evasionScene = nil
                        evasionStagesManager.unlockStage(evasionStage.id + 1)
                        balance += 5
                        withAnimation(.linear(duration: 0.4)) {
                            gameWin = true
                        }
                    })
                    .onReceive(center.publisher(for: Notification.Name("DEFEAT")), perform: { _ in
                        self.evasionScene = nil
                        withAnimation(.linear(duration: 0.4)) {
                            gameOver = true
                        }
                    })
                    .onReceive(center.publisher(for: Notification.Name("home_act")), perform: { _ in
                        pmod.wrappedValue.dismiss()
                    })
            } else {
                EmptyView()
            }
            
            if gameWin {
                WinBattleGameView()
            }
            if gameOver {
                BattleOverGameView()
            }
        }
        .onAppear {
            evasionScene = GameBattleEnvasionScene(evasionStage: evasionStage)
        }
        .onReceive(center.publisher(for: Notification.Name("game_restart")), perform: { _ in
            self.evasionScene = self.evasionScene?.restartGameSceneView()
        })
        .onReceive(center.publisher(for: Notification.Name("new_game")), perform: { _ in
            withAnimation(.linear(duration: 0.4)) {
                self.gameWin = false
                self.gameOver = false
            }
            self.evasionScene = GameBattleEnvasionScene(evasionStage: evasionStage)
        })
    }
}

#Preview {
    EvasionGameView(evasionStagesManager: EvasionStagesManager(), evasionStage: EvasionStage(id: 1, isUnlocked: true))
    
}
