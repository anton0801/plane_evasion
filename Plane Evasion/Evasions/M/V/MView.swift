import SwiftUI

struct MView: View {
    
    @State var mu = UserDefaults.standard.bool(forKey: "is_music_on") {
        didSet {
            UserDefaults.standard.set(mu, forKey: "is_music_on")
        }
    }
    
    @State var so = UserDefaults.standard.bool(forKey: "is_sounds_app_on") {
        didSet {
            UserDefaults.standard.set(so, forKey: "is_sounds_app_on")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            mu = !mu
                        }
                    } label: {
                        if mu {
                            Image("button_app_music")
                        } else {
                            Image("button_app_music_off")
                        }
                    }
                    .padding(.leading)
                    Spacer()
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            so = !so
                        }
                    } label: {
                        if so {
                            Image("button_sounds")
                        } else {
                            Image("button_sounds_off")
                        }
                    }
                    .padding(.trailing)
                }
                Spacer()
                
                Image("pers")
                    .resizable()
                    .frame(width: 270, height: 300)
                    .offset(y: 20)
                
                NavigationLink(destination: EvasionStagesView()
                    .navigationBarBackButtonHidden(true)) {
                    Image("button_play")
                        .resizable()
                        .frame(width: 300, height: 100)
                }
                
                NavigationLink(destination: Shop()
                    .navigationBarBackButtonHidden(true)) {
                    Image("button_shop")
                        .resizable()
                        .frame(width: 300, height: 100)
                }
                NavigationLink(destination: WorkShop()
                    .navigationBarBackButtonHidden(true)) {
                    Image("button_workshop")
                        .resizable()
                        .frame(width: 300, height: 100)
                }
                
                Button {
                    exit(0)
                } label: {
                    Image("button_quit")
                        .resizable()
                        .frame(width: 300, height: 100)
                }
                
                Spacer()
            }
            .background(BackgroundImage())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    MView()
}

struct BackgroundImage: View {
    var body: some View {
        Image("image_background")
            .resizable()
            .frame(minWidth: UIScreen.main.bounds.width,
                   minHeight: UIScreen.main.bounds.height)
            .ignoresSafeArea()
    }
}
