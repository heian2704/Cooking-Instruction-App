import Foundation
import CoreLocation

class MapViewModel {
    private let nominatimUrl = "https://nominatim.openstreetmap.org/search"
    
    // Define the bounding box for Thailand region
    private let boundingBox = "6.836328,97.343485,20.459779,105.633125" // SW, NE corners for Thailand

    func fetchNearbyStores(coordinate: CLLocationCoordinate2D, completion: @escaping ([Store]) -> Void) {
        // Construct the query URL with bounding box and a query for grocery stores
        let urlString = "\(nominatimUrl)?q=Market&format=json&addressdetails=1&boundingbox=\(boundingBox)&countrycodes=TH"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching stores: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let stores = json.compactMap { result -> Store? in
                        guard
                            let lat = result["lat"] as? String,
                            let lon = result["lon"] as? String,
                            let name = result["display_name"] as? String
                        else {
                            return nil
                        }
                        
                        return Store(
                            lat: Double(lat) ?? 0.0,
                            lon: Double(lon) ?? 0.0,
                            name: name
                        )
                    }
                    completion(stores)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion([])
            }
        }
        task.resume()
    }
    
    func fetchStores(query: String, completion: @escaping ([Store]) -> Void) {
        // Encode the query to ensure it's URL-safe
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(nominatimUrl)?q=\(encodedQuery)&format=json&addressdetails=1&boundingbox=\(boundingBox)&countrycodes=TH"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error searching stores: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let stores = json.compactMap { result -> Store? in
                        guard
                            let lat = result["lat"] as? String,
                            let lon = result["lon"] as? String,
                            let name = result["display_name"] as? String
                        else {
                            return nil
                        }
                        
                        return Store(
                            lat: Double(lat) ?? 0.0,
                            lon: Double(lon) ?? 0.0,
                            name: name
                        )
                    }
                    completion(stores)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion([])
            }
        }
        task.resume()
    }
}
