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
                    .background(Color("TFBG").opacity(0.6), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                //Ligther black color
                    .brightness(0.2)
             
                    
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
 
