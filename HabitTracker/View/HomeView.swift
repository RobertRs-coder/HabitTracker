//
//  HomeView.swift
//  HabitTracker
//
//  Created by Roberto Rojo Sahuquillo on 13/9/23.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest(entity: Habit.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var habits: FetchedResults<Habit>
    
    @StateObject var viewModel: HabitViewModel = .init()
//    @StateObject var viewModel = HabitViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {}
            //MARK: Add button center when habits empty
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    Button {
                        viewModel.addNewHabit.toggle()
                    } label: {
                        Label {
                            Text("New habit")
                            } icon: {
                                Image(systemName: "plus.circle")
                            }
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                        
                    }
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center )
                }
                .padding(.vertical)
                
            }
        }
        .frame(maxHeight: .infinity, alignment: .top )
        .padding()
        .sheet(isPresented: $viewModel.addNewHabit) {
            
        } content: {
            
        }
    }
}

#Preview {
    MainView()
}
