//
//  AdminEventRow.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct EventRow: View {
    var event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.address)
                    .font(.subheadline)
            }
            Spacer()
            VStack {
                Text(event.date, format: .dateTime.day().month().year())
                Text(event.time, style: .time)
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
    EventRow(event: Event(name: "John Doe",
          phoneNumber: "0401033232",
          email: "john.doe@gmail.com",
          address: "The Pub",
          date: Date.now,
          time: Date.now,
          duration: "3",
          guests: 100,
          notes: "N/A",
          status: "pending"
    )
    )
}
