//
//  UserSettings.swift
//  BasicWeather
//
//  Created by Ming Luo on 10/29/22.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var selectedCity: City {
        didSet {
            if let encoded = try? JSONEncoder().encode(self.selectedCity) {
                UserDefaults.standard.set(encoded, forKey: "SelectedCity")
            }
        }
    }
    
    @Published var pandaMode: Bool {
        didSet {
            UserDefaults.standard.set(pandaMode, forKey: "PandaMode")
        }
    }
    
    init() {
        self.selectedCity = City(name: "Boston", state: "Massachusetts", country: "US", lat: 42.3554334, lon: -71.060511)
        if let data = UserDefaults.standard.data(forKey: "SelectedCity") {
            if let decoded = try? JSONDecoder().decode(City.self, from: data) {
                self.selectedCity = decoded
            }
        }
        self.pandaMode = UserDefaults.standard.bool(forKey: "PandaMode")
    }
}
