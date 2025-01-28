//
//  AdminEventRow.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventRow: View {
    var event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.clientName)
                    .font(.headline)
                Text(event.location)
                    .font(.subheadline)
            }
            Spacer()
            VStack {
                Text(event.eventDate, style: .date)
                Text(event.eventDate, style: .time)
            }
            .foregroundStyle(.secondary)

            // Status icon based on the event status
            if event.status == "pending" {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
            } else if event.status == "accepted" {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if event.status == "denied" {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    AdminEventRow(event: Event(
        clientName: "John Doe",
        eventDate: Date(),
        location: "123 Main St",
        duration: 3,
        status: "pending"
    ))
}
