import SwiftUI

struct BattleOverGameView: View {
    
    @Environment(\.presentationMode) var premode
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("GAME OVER!")
                .font(.custom("IrishGrover-Regular", size: 62))
                .foregroundColor(.white)
            
            Text("TRY AGAIN!")
                .font(.custom("IrishGrover-Regular", size: 32))
                .foregroundColor(.white)
                .padding(.top)
            
            Spacer()
            
            HStack {
                Button {
                    premode.wrappedValue.dismiss()
                } label: {
                    Image("home_button")
                }
                Button {
                    NotificationCenter.default.post(name: Notification.Name("new_game"), object: nil)
                } label: {
                    Image("game_restart")
                }
            }
            .padding(.top)
            
            Spacer()
            
            Image("pers")
                .resizable()
                .frame(width: 200, height: 200)
                .offset(y: 40)
        }
        .background(
            Image("battle_field")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    BattleOverGameView()
}
