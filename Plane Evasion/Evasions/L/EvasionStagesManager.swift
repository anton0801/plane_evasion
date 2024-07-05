import Foundation
import Combine

class EvasionStagesManager: ObservableObject {
    private let levelsKey = "EvasionLevels"
    private let userDefaults = UserDefaults.standard
    
    // Singleton instance
    static let shared = EvasionStagesManager()
    
    // Published property to notify changes
    @Published var stages: [EvasionStage]
    
    init() {
        // Initialize stages if they don't exist
        if let savedData = userDefaults.data(forKey: levelsKey),
           let savedStages = try? JSONDecoder().decode([EvasionStage].self, from: savedData) {
            stages = savedStages
        } else {
            stages = (1...28).map { EvasionStage(id: $0, isUnlocked: $0 == 1) }
            saveStages()
        }
        
        if !stages[0].isUnlocked {
            unlockStage(stages[0].id)
        }
    }
    
    // Method to unlock a level
    func unlockStage(_ id: Int) {
        if let index = stages.firstIndex(where: { $0.id == id }) {
            stages[index].isUnlocked = true
            saveStages()
        }
    }
    
    // Method to check if a level is unlocked
    func isStageUnlocked(_ id: Int) -> Bool {
        return stages.first(where: { $0.id == id })?.isUnlocked ?? false
    }
    
    // Method to get the number of levels
    func numberOfStages() -> Int {
        return stages.count
    }
    
    // Method to reset levels (for testing or other purposes)
    func resetStages() {
        stages = (0..<20).map { EvasionStage(id: $0, isUnlocked: $0 == 0) }
        saveStages()
    }
    
    // Save stages to UserDefaults
    private func saveStages() {
        if let encodedData = try? JSONEncoder().encode(stages) {
            userDefaults.set(encodedData, forKey: levelsKey)
            objectWillChange.send() // Notify observers about the change
        }
    }
}
