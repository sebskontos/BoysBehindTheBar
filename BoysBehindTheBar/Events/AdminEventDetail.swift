//
//  AdminEventDetail.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventDetail: View {
    var event: Event
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var responseMessage: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Client: \(event.clientName)")
                .font(.headline)
            Text("Location: \(event.location)")
                .font(.subheadline)
            Text("Date: \(event.eventDate, style: .date)")
            Text("Duration: \(event.duration) hours")

            Text("Response Message:")
                .font(.headline)
                .padding(.top)
            TextEditor(text: $responseMessage)
                .frame(height: 100)
                .border(Color.gray)

            HStack {
                Button(action: {
                    firestoreManager.updateEventStatus(eventID: event.id!, status: "accepted", adminMessage: responseMessage)
                }) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    firestoreManager.updateEventStatus(eventID: event.id!, status: "denied", adminMessage: responseMessage)
                }) {
                    Text("Deny")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Event Details")
    }
}

