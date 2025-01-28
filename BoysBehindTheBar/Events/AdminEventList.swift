//
//  AdminEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventList: View {
    @EnvironmentObject var firestoreManager: FirestoreManager

    var body: some View {
        NavigationView {
            List(firestoreManager.events) { event in
                NavigationLink(destination: AdminEventDetail(event: event)) {
                    AdminEventRow(event: event)
                }
            }
            .navigationTitle("Bookings")
            .onAppear {
                firestoreManager.fetchEvents()
            }
        }
    }
}

#Preview {
    AdminEventList()
        .environmentObject(FirestoreManager())
}
