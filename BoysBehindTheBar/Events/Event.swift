//
//  Event.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//

import Foundation

struct Event: Codable, Identifiable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var email: String
    var address: String
    var date: Date
    var time: Date
    var duration: String
    var guests: Int
    var notes: String
    var status: String
    var adminMessage: String?

    enum CodingKeys: String, CodingKey {
        case name, phoneNumber, email, address, date, time, duration, guests, notes, status, adminMessage
    }
    
    init(name: String, phoneNumber: String, email: String, address: String, date: Date, time: Date, duration: String, guests: Int, notes: String, status: String, adminMessage: String? = nil) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.date = date
        self.time = time
        self.duration = duration
        self.guests = guests
        self.notes = notes
        self.status = status
        self.adminMessage = adminMessage
    }

    // Custom Decoder to handle different date/time formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        email = try container.decode(String.self, forKey: .email)
        address = try container.decode(String.self, forKey: .address)
        duration = try container.decode(String.self, forKey: .duration)
        notes = try container.decode(String.self, forKey: .notes)
        status = try container.decode(String.self, forKey: .status)
        adminMessage = try? container.decode(String.self, forKey: .adminMessage)

        // Handle guests as String or Int
        if let guestsInt = try? container.decode(Int.self, forKey: .guests) {
            guests = guestsInt
        } else if let guestsString = try? container.decode(String.self, forKey: .guests), let guestsInt = Int(guestsString) {
            guests = guestsInt
        } else {
            guests = 0  // Default value if guests are missing
        }

        // Simple Date Parsing (Assumes Plain Text Format "YYYY-MM-DD")
        if let dateString = try? container.decode(String.self, forKey: .date),
           let parsedDate = Event.parsePlainTextDate(from: dateString) {
            date = parsedDate
        } else {
            print("❌ Date parsing failed for: \(String(describing: try? container.decode(String.self, forKey: .date)))")
            date = Date()
        }

        // Fixing Time Parsing (Assumes Plain Text Format "HH:mm")
        if let timeString = try? container.decode(String.self, forKey: .time),
           let parsedTime = Event.parsePlainTextTime(from: timeString) {
            time = parsedTime
        } else {
            print("❌ Time parsing failed for: \(String(describing: try? container.decode(String.self, forKey: .time)))")
            time = Date()
        }
    }
    
    // Parses "YYYY-MM-DD" Plain Text Dates
    static func parsePlainTextDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: string)
    }

    // Parses "HH:mm" Plain Text Times
    static func parsePlainTextTime(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current
        if let fullDate = formatter.date(from: string) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.hour, .minute, .second], from: fullDate)
            components.year = 1970
            components.month = 1
            components.day = 1  // Set to a fixed date

            let finalTime = calendar.date(from: components)
            return finalTime
        }
        return nil
    }
}

enum EventStatus {
    case pending
    case accepted(String)
    case denied(String)
}
