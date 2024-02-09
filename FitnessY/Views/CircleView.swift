//
//  CircleView.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-08.
//

import SwiftUI

struct CircleView: View {
    let progress: Double
    
   
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.pink.opacity(0.5),
                    lineWidth: 30
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.pink,
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)
        }
        .onAppear(perform: {
            print("prgores", progress)
        })
    }
}

#Preview {
    CircleView(progress: 20)
}
