//
//  CardView.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-07.
//

import SwiftUI

struct CardView: View {
    var healthData: Int
    var sfImage: String
    var text: String
    var color: Color
    var body: some View {
        VStack {
            HStack {
                Image(systemName: sfImage)
                Text("\(healthData)")
            }
            Text(text)
        }

        .padding()
        .frame(width: 150, height: 150)
        .background(color)
        .cornerRadius(15)
    }
}

#Preview {
    CardView(healthData: 10000, sfImage: "shoe.fill", text: "Steps Today", color: .red)
}
