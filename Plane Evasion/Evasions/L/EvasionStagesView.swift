import SwiftUI

struct EvasionStagesView: View {
    
    @ObservedObject var evasionStagesManager = EvasionStagesManager.shared
    @Environment(\.presentationMode) var pmod

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        pmod.wrappedValue.dismiss()
                    } label: {
                        Image("home_button")
                    }
                    Spacer()
                    Text("PLAY")
                        .font(.custom("IrishGrover-Regular", size: 42))
                        .foregroundColor(.white)
                        .offset(x: -20)
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                LazyVGrid(columns: [
                    GridItem(.fixed(70)),
                    GridItem(.fixed(70)),
                    GridItem(.fixed(70)),
                    GridItem(.fixed(70))
                ]) {
                    ForEach(evasionStagesManager.stages, id: \.id) { stage in
                        if evasionStagesManager.isStageUnlocked(stage.id) {
                            NavigationLink(destination: EvasionGameView(evasionStagesManager: evasionStagesManager, evasionStage: stage)
                                .navigationBarBackButtonHidden(true)) {
                                    ZStack {
                                        Image("evasion_stage_bg")
                                        Text("\(stage.id)")
                                            .font(.custom("IrishGrover-Regular", size: 42))
                                            .foregroundColor(.white)
                                    }
                                }
                        } else {
                            ZStack {
                                Image("evasion_stage_bg_locked")
                            }
                        }
                    }
                }
                
                Spacer()
                
            }
            .background(BackgroundImage())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    EvasionStagesView()
}
