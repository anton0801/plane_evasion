import SwiftUI

struct WinBattleGameView: View {
    
    @Environment(\.presentationMode) var premode
    @State var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(balance)")
                    .font(.custom("IrishGrover-Regular", size: 42))
                    .foregroundColor(.white)
                    .padding(.trailing)
                Image("coin_button")
            }
            
            Spacer()
            
            Text("YOU WIN!")
                .font(.custom("IrishGrover-Regular", size: 82))
                .foregroundColor(.white)
            
            Text("CONGRATULATIONS!")
                .font(.custom("IrishGrover-Regular", size: 32))
                .foregroundColor(.white)
                .padding(.top)
            
            Text("You get 5 coins!")
                .font(.custom("IrishGrover-Regular", size: 32))
                .foregroundColor(.white)
                .padding(.top)
            
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
    WinBattleGameView()
}
