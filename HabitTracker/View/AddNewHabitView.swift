//
//  AddNewHabitView.swift
//  HabitTracker
//
//  Created by Roberto Rojo Sahuquillo on 13/9/23.
//

import SwiftUI

struct AddNewHabitView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    
    @State private var icon = "l1.rectangle.roundedbottom"

    @State private var isPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title", text: $viewModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("TFBG").opacity(0.6),
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .brightness(0.2)
                // MARK: Habit Color Picker
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) {index in
                        let color = "Card-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == viewModel.habitColor {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                withAnimation {
                                    viewModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                

            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add Habit")
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button{
                        //Action
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                    .padding([.horizontal, .top], 5)
                }
                
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button{
                        //Action
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .tint(.white)
                    .padding([.horizontal, .top], 5)
                }
            }
        }
    }
}

#Preview {
    AddNewHabitView()
        .environmentObject(HabitViewModel())
        .preferredColorScheme(.dark)
}
 
