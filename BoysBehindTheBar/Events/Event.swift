//
//  Event.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//

import Foundation

struct Event: Codable, Identifiable {
    var id = UUID()
    var clientName: String
    var eventDate: Date
    var location: String
    var duration: Int
    var status: String // Example values: "pending", "accepted", "denied"
    var adminMessage: String? // Optional message for admin decisions
    var userPhoneNumber: String // The phone number of the customer
}

enum EventStatus {
    case pending
    case accepted(String) // Admin can send a message
    case denied(String)   // Admin can send a rejection reason
}
