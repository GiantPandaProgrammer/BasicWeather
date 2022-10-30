import Foundation

class Api : ObservableObject{
    @Published var cityForcast = CityForcast(list: [])
    
    func loadData(completion:@escaping (CityForcast) -> (), lat: Double, lon: Double, apiKey: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&cnt=10&appid=\(apiKey)") else {
            print("Invalid url...")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            let cityForcast = try! JSONDecoder().decode(CityForcast.self, from: data!)
            DispatchQueue.main.async {
                completion(cityForcast)
            }
        }.resume()
        
    }
}
