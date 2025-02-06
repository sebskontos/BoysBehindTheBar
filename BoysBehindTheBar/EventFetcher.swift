import Foundation

class EventFetcher: ObservableObject {
    @Published var events: [Event] = []
    
    func fetchEvents() {
        guard let url = URL(string: "YOUR_GOOGLE_SCRIPT_WEB_APP_URL") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
                DispatchQueue.main.async {
                    self.events = decodedEvents
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
