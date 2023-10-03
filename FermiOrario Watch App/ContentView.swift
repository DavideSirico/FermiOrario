import SwiftUI

struct Schedule: Codable {
    let orario: [String: [String: Lesson]]
}

struct Lesson: Codable {
    let subject: String
    let room: String
}

func getCurrentHour() -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH"
    return Int(dateFormatter.string(from: Date())) ?? 0
}

func loadSchedule() -> Schedule? {
    if let fileURL = Bundle.main.url(forResource: "orario", withExtension: "json") {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let schedule = try decoder.decode(Schedule.self, from: data)
            print("JSON file decoded successfully.")
            return schedule
        } catch {
            print("Error reading or decoding JSON file: \(error)")
            return nil
        }
    } else {
        print("JSON file not found in the app bundle.")
        return nil
    }
}

let schedule = loadSchedule()!

func updateSubject(shift: Int) -> [String] {
    let currentHour = String(getCurrentHour() + shift)
    let currentDay = Calendar.current.component(.weekday, from: Date())
    let dayOfWeek: String

    switch currentDay {
    case 1: dayOfWeek = ""
    case 2: dayOfWeek = "Lunedi"
    case 3: dayOfWeek = "Martedi"
    case 4: dayOfWeek = "Mercoledi"
    case 5: dayOfWeek = "Giovedi"
    case 6: dayOfWeek = "Venerdi"
    case 7: dayOfWeek = "Sabato"
    default: dayOfWeek = ""
    }

    if let lessonsForDay = schedule.orario[dayOfWeek],
       let lesson = lessonsForDay[currentHour] {
        return [lesson.subject, lesson.room]
    } else {
        return ["No class", "No room"]
    }
}

struct ViewPreviousClass: View {
    @State private var data = ["", ""]
    @State public var shouldRefresh = false

    var body: some View {
        VStack {
            Text("Previous Subject:")
                .font(.headline)
            Text(data[0])
                .font(.title)
            Text(data[1])
                .font(.title2)
        }
        .onAppear {
            self.updateData(shift: -1)
        }
    }

    func updateData(shift: Int) {
        self.data = updateSubject(shift: shift)
    }
}
struct ViewCurrentClass: View {
    @State private var data = ["", ""]
    @State public var shouldRefresh = false

    var body: some View {
        VStack {
            Text("Current Subject:")
                .font(.headline)
            Text(data[0])
                .font(.title)
            Text(data[1])
                .font(.title2)
        }
        .onAppear {
            self.updateData(shift: 0)
        }
    }

    func updateData(shift: Int) {
        self.data = updateSubject(shift: shift)
    }
}
struct ViewNextClass: View {
    @State private var data = ["", ""]
    @State public var shouldRefresh = false

    var body: some View {
        VStack {
            Text("Next Subject:")
                .font(.headline)
            Text(data[0])
                .font(.title)
            Text(data[1])
                .font(.title2)
        }
        .onAppear {
            self.updateData(shift: 1)
        }
    }

    public func updateData(shift: Int) {
        self.data = updateSubject(shift: shift)
    }
}

struct ContentView: View {
    @State private var selectedTabIndex = 1

    var body: some View {
        VStack {
            TabView(selection: $selectedTabIndex) {
                ViewPreviousClass()
                    .tag(0)
                ViewCurrentClass()
                    .tag(1)
                ViewNextClass()
                    .tag(2)
            }
            .onAppear {
                selectedTabIndex = 1
            }
            Button(action: {
                ViewNextClass().shouldRefresh.toggle()
                ViewNextClass().updateData(shift: 1)
                
                ViewCurrentClass().shouldRefresh.toggle()
                ViewCurrentClass().updateData(shift: 0)
            
                ViewPreviousClass().shouldRefresh.toggle()
                ViewPreviousClass().updateData(shift: -1)
                
            }) {
                Text("Refresh")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
