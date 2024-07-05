import SwiftUI

struct WorkShop: View {
    
    @Environment(\.presentationMode) var pmod
    @State var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    
    @State var attackLevel = UserDefaults.standard.integer(forKey: "attack_level") {
        didSet {
            UserDefaults.standard.set(attackLevel, forKey: "attack_level")
        }
    }
    
    @State var moveLevel = UserDefaults.standard.integer(forKey: "move_level") {
        didSet {
            UserDefaults.standard.set(moveLevel, forKey: "move_level")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    pmod.wrappedValue.dismiss()
                } label: {
                    Image("home_button")
                }
                Spacer()
                Text("WORKSHOP")
                    .font(.custom("IrishGrover-Regular", size: 42))
                    .foregroundColor(.white)
                    .offset(x: -20)
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                VStack {
                    if attackLevel < 4 {
                        HStack {
                            Text("\(10 * attackLevel)")
                                .font(.custom("IrishGrover-Regular", size: 18))
                                .foregroundColor(.white)
                            Image("coin_button")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    } else {
                        HStack {
                            Text("\(10 * attackLevel)")
                                .font(.custom("IrishGrover-Regular", size: 18))
                                .foregroundColor(.white)
                            Image("coin_button")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .opacity(0)
                    }
                    
                    ZStack(alignment: .bottom) {
                        VStack {
                            Image("workshop_item_back")
                        }
                        
                        VStack(spacing: -4) {
                            if attackLevel < 4 {
                                Button {
                                    if balance >= (10 * attackLevel) {
                                        withAnimation(.linear(duration: 0.4)) {
                                            attackLevel += 1
                                        }
                                    }
                                } label: {
                                    Image("workshop_item_upgrade")
                                }
                            }
                            ForEach(0..<attackLevel, id: \.self) { i in
                                Image("workshop_item_red")
                                    .resizable()
                                    .frame(width: 68, height: 60)
                            }
                        }
                        
                        VStack(spacing: 0) {
                            Image("attack")
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text("Level \(attackLevel)")
                                .font(.custom("IrishGrover-Regular", size: 14))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                        .offset(y: -CGFloat((attackLevel - 1) * 58))
                    }
                }
                
                Spacer().frame(width: 90)
                
                VStack {
                    if moveLevel < 4 {
                        HStack {
                            Text("\(10 * moveLevel)")
                                .font(.custom("IrishGrover-Regular", size: 18))
                                .foregroundColor(.white)
                            Image("coin_button")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    } else {
                        HStack {
                            Text("\(10 * moveLevel)")
                                .font(.custom("IrishGrover-Regular", size: 18))
                                .foregroundColor(.white)
                            Image("coin_button")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .opacity(0)
                    }
                    
                    ZStack(alignment: .bottom) {
                        VStack {
                            Image("workshop_item_back")
                        }
                        
                        VStack(spacing: -4) {
                            if moveLevel < 4 {
                                Button {
                                    if balance >= (10 * moveLevel) {
                                        withAnimation(.linear(duration: 0.4)) {
                                            moveLevel += 1
                                        }
                                    }
                                } label: {
                                    Image("workshop_item_upgrade")
                                }
                            }
                            ForEach(0..<moveLevel, id: \.self) { i in
                                Image("workshop_item_red")
                                    .resizable()
                                    .frame(width: 68, height: 60)
                            }
                        }
                        
                        VStack(spacing: 0) {
                            Image("move")
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text("Level \(moveLevel)")
                                .font(.custom("IrishGrover-Regular", size: 14))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                        .offset(y: -CGFloat((moveLevel - 1) * 58))
                    }
                }
                
            }
            
            Spacer()
            
            HStack {
                Text("\(balance)")
                    .font(.custom("IrishGrover-Regular", size: 42))
                    .foregroundColor(.white)
                    .padding(.trailing)
                Image("coin_button")
            }
        }
        .onAppear {
            if attackLevel == 0 {
                attackLevel = 1
            }
            if moveLevel == 0 {
                moveLevel = 1
            }
        }
        .background(BackgroundImageBlacked())
    }
}



#Preview {
    WorkShop()
}


struct BackgroundImageBlacked: View {
    var body: some View {
        ZStack {
            BackgroundImage()
            Color.black.opacity(0.6)
        }
        .ignoresSafeArea()
    }
}
