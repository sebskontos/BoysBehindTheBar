//
//  SplashScreenView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 10/2/2025.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .font(.title2)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
