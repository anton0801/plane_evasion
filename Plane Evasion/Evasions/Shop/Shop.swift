import SwiftUI

struct Shop: View {
    
    @Environment(\.presentationMode) var pmod
    @State var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    
    @State var currentAircraft = UserDefaults.standard.string(forKey: "aircraft") ?? "shooter_aircraft" {
        didSet {
            UserDefaults.standard.set(currentAircraft, forKey: "aircraft")
        }
    }
    
    @State var aircraftsAll: [Aircraft] = []
    @State var currentDisplayedAircraft: Aircraft!
    
    @State var currentDisplayAircraftIndex = 0 {
        didSet {
            currentDisplayedAircraft = aircraftsAll[currentDisplayAircraftIndex]
        }
    }
    
    @State var showErrorPurchase = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    pmod.wrappedValue.dismiss()
                } label: {
                    Image("home_button")
                }
                Spacer()
                Text("SHOP")
                    .font(.custom("IrishGrover-Regular", size: 42))
                    .foregroundColor(.white)
                    .offset(x: -20)
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            if let aircraft = currentDisplayedAircraft {
                if currentAircraft == aircraft.id {
                    ZStack {
                        Image("purchased_back")
                        VStack(spacing: 0) {
                            Image(aircraft.id)
                                .resizable()
                                .frame(width: 200, height: 200)
                            Text("SELECTED")
                                .font(.custom("IrishGrover-Regular", size: 42))
                                .foregroundColor(.black)
                        }
                    }
                } else {
                    if aircraft.isPurchased {
                        ZStack {
                            Image("purchased_back")
                            VStack(spacing: 0) {
                                Image(aircraft.id)
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                Button {
                                    currentAircraft = aircraft.id
                                } label: {
                                    Text("SELECT")
                                        .font(.custom("IrishGrover-Regular", size: 42))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    } else {
                        Button {
                            buyAircraft(aircraft: aircraft) {
                                if balance >= aircraft.price {
                                    return true
                                }
                                self.showErrorPurchase = true
                                return false
                            }
                        } label: {
                            ZStack {
                                Image("not_purchased_back")
                                VStack(spacing: 0) {
                                    Image(aircraft.id)
                                        .resizable()
                                        .frame(width: 200, height: 200)
                                    HStack {
                                        Text("\(aircraft.price)")
                                            .font(.custom("IrishGrover-Regular", size: 42))
                                            .foregroundColor(.black)
                                        Image("coin_button")
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            currentDisplayAircraftIndex -= 1
                        }
                    } label: {
                        Image("back")
                    }
                    .disabled(currentDisplayAircraftIndex == 0 ? true : false)
                    Spacer()
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            currentDisplayAircraftIndex += 1
                        }
                    } label: {
                        Image("next")
                    }
                    .disabled(currentDisplayAircraftIndex == aircraftsAll.count - 1 ? true : false)
                }
                .padding(.horizontal, 42)
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
        .background(BackgroundImageBlacked())
        .onAppear {
            loadAllAircrafts()
        }
        .alert(isPresented: $showErrorPurchase) {
            Alert(title: Text("Purchase plane error!"), message: Text("Not enought credits in your balanace! Game more for gane more!"), dismissButton: .default(Text("OK!")))
        }
    }
    
    private func loadAllAircrafts() {
        let aircraftIds = ["shooter_aircraft", "aircraft_45", "aircraft_150"]
        let prices = ["shooter_aircraft": 0, "aircraft_45": 45, "aircraft_150": 150]
        for aircraftId in aircraftIds {
            aircraftsAll.append(Aircraft(id: aircraftId, price: prices[aircraftId]!, isPurchased: UserDefaults.standard.bool(forKey: "\(aircraftId)_purchased")))
        }
        if !aircraftsAll[0].isPurchased {
            buyAircraft(aircraft: aircraftsAll[0]) {
                return true
            }
        }
        currentDisplayedAircraft = aircraftsAll[0]
    }
    
    private func buyAircraft(aircraft: Aircraft, predicate: @escaping () -> Bool) {
        if predicate() {
            UserDefaults.standard.set(true, forKey: "\(aircraft.id)_purchased")
            if aircraft.price > 0 {
                balance -= aircraft.price
            }
            loadAllAircrafts()
        }
    }
    
}

struct Aircraft {
    var id: String
    var price: Int
    var isPurchased: Bool
}

#Preview {
    Shop()
}
