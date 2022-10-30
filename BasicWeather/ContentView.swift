//
//  ContentView.swift
//  BasicWeather
//
//  Created by Ming Luo on 10/23/22.
//

import SwiftUI

struct City : Decodable, Identifiable, Encodable, CustomStringConvertible {
    var id: String { String(lat) + " " + String(lon) }
    var name: String
    var state: String
    var country: String
    var lat: Double
    var lon: Double
    
    public var description: String { return state == "" ? "\(name), \(country)" : "\(name), \(state)" }
}

struct CityForcast : Decodable {
    static let example = CityForcast(list: [])

    var list: [DayForcast]
}
struct TempForcast : Decodable {
    var day: Double
}

struct WeatherForcast : Decodable {
    var main: String
}

struct DayForcast : Decodable{
    var dt: Double
    var temp: TempForcast
    var weather: [WeatherForcast]
    
    public var fTemp: Int { return (Int(temp.day - 273.15) * 9/5 + 32) }
    
    public var imageName: String {
        switch weather[0].main {
        case "Clear":
            return "sun.max.fill"
        case "Rain":
            return "cloud.rain.fill"
        case "Clouds":
            return "cloud.fill"
        case "Snow":
            return "cloud.snow.fill"
        default:
            print("not found icon " + weather[0].main )
            return "cloud.sun.fill"
        }
    }
    
    public var pandaImage: String {
        switch weather[0].main {
        case "Clear":
            return "Sunny"
        case "Rain":
            return "Rain"
        case "Clouds":
            return "Cloud"
        case "Snow":
            return "Snow"
        default:
            print("not found icon " + weather[0].main )
            return "Sunny"
        }
    }
    
    public var dayOfWeek: String {
        let date = Date(timeIntervalSince1970: self.dt)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.dateFormat = "E"
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

var apiKey = "  "

class ViewModel: ObservableObject {
    @Published var cityForcast: CityForcast = CityForcast.example
    @Published var city: City = City(name: "Boston", state: "Massachusetts", country: "US", lat: 42.3554334, lon: -71.060511)
    @Published var pandaMode: Bool = false
    
    init(lat: Double, lon: Double, city: City, pandaMode: Bool, apiKey: String) {
        self.city = city
        self.pandaMode = pandaMode
        if lat != -1 && lon != -1
        {
            Api().loadData(completion: { (cityForcast) in
                self.cityForcast = cityForcast
            }, lat: lat, lon: lon, apiKey: apiKey)
        }
    }
    
    func updatePandaMode(pandaMode: Bool) {
        self.pandaMode = pandaMode
    }
    
    func updateModel(lat: Double, lon: Double, city: City, apiKey: String) {
        self.city = city
        Api().loadData(completion: { (cityForcast) in
            self.cityForcast = cityForcast
        }, lat: lat, lon: lon, apiKey: apiKey)
    }
}
    
    
struct ContentView: View {
    @State private var searchText = ""
    @State var searching = false
    @State var cities: [City] = []
    //@State private var selectedCity: City = City(name: "Boston", state: "Massachusetts", country: "US", lat: 42.3554334, lon: //-71.060511)
    @ObservedObject var viewModel: ViewModel = ViewModel(lat: -1,lon: -1,city: City(name: "Boston", state: "Massachusetts", country: "US", lat: 42.3554334, lon: -71.060511), pandaMode: false, apiKey: apiKey)
    // @State var pandaMode = true
    @ObservedObject var userSettings = UserSettings()
    
    init() {
       // UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear

        viewModel = ViewModel(lat: userSettings.selectedCity.lat, lon: userSettings.selectedCity.lon, city: userSettings.selectedCity, pandaMode: userSettings.pandaMode, apiKey: apiKey)
    }

    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, Color("Light Blue")]),
                startPoint: .topLeading,
                           endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            VStack {
                SearchBar(searchText: $searchText, searching: $searching,
                    cities: $cities)
                ZStack {
                    VStack {
                        Text([viewModel.city.name, viewModel.city.state].joined(separator: ", "))
                            .font(.system(size: 32, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding()
                        VStack(spacing: 10) {
                            if (!viewModel.cityForcast.list.isEmpty)
                            {
                                if viewModel.pandaMode {
                                    Image(viewModel.cityForcast.list[0].pandaImage)
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 180, height: 180)
                                } else {
                                    Image(systemName: viewModel.cityForcast.list[0].imageName)
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 180, height: 180)
                                }
                                // Option shift 8
                                Text("\(viewModel.cityForcast.list[0].fTemp)°")
                                    .font(.system(size: 70, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 40)
                        
                        HStack(spacing: 20) {
                            if (!viewModel.cityForcast.list.isEmpty) {
                                ForEach (1..<6) {
                                    WeatherDayView(dayForcast: viewModel.cityForcast.list[$0], pandaMode: viewModel.pandaMode)
                                }
                            }
                            
                        }
                        Spacer()
                        Button {
                            viewModel.updatePandaMode(pandaMode: !viewModel.pandaMode)
                            userSettings.pandaMode = viewModel.pandaMode
                        } label: {
                            Text(userSettings.pandaMode ? "Panda Mode Off" : "Panda Mode On")
                                .frame(width : 280, height: 50)
                                .background(Color.white)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .cornerRadius(3.0)
                        }
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        if !cities.isEmpty && searchText != "" {
                            List(cities) { city in  Text(city.description).onTapGesture {
                                    searchText = ""
                                    searching = false
                                    userSettings.selectedCity = city
                                viewModel.updateModel(lat: city.lat, lon: city.lon, city: city, apiKey: apiKey)
                                }
                            }.onAppear(perform: {
                                UITableView.appearance().contentInset.top = -35
                            })
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var searching: Bool
    @Binding var cities: [City]
    
    func searchCities() {
        if (searchText != "")
        {
            Task {
                let urlCleaned = "http://api.openweathermap.org/geo/1.0/direct?q=\(searchText)&limit=10&appid=\( apiKey)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                guard let url = URL(string: urlCleaned ?? "") else { return }

                let (data, _) = try await URLSession.shared.data(from: url)
                cities = try JSONDecoder().decode([City].self, from: data)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color("Light Gray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search ..", text: $searchText) {
                    startedEditing in
                    if startedEditing {
                        withAnimation {
                            searching = true
                        }
                    }
                } onCommit: {
                    withAnimation {
                        searching = false
                        searchCities()
                    }
                }
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct WeatherDayView: View {
    
    var dayForcast: DayForcast
    var pandaMode: Bool
    
    var body: some View {
        VStack {
            Text(dayForcast.dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            if pandaMode {
                Image(dayForcast.pandaImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: dayForcast.imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            Text("\(dayForcast.fTemp)°")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
/*
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}*/
