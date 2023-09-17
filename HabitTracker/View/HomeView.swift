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
                    
                    ForEach(habits) { habit in
                        HabitCardView(habit: habit)
                    }
                    // MARK: Add habit button
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
            //MARK: Erasing All Existing Content
            viewModel.eraseData()
        } content: {
            AddNewHabitView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: Habit Card View
    @ViewBuilder
    func HabitCardView(habit: Habit) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(habit.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Image("bell.badge.fill")
                    .font(.callout)
                    .foregroundStyle(Color(habit.color ?? "Card-1"))
                    .scaleEffect(0.9)
                    .opacity(habit.isReminderOn ? 1 : 0)
                
                Spacer()
                
                let count = habit.weekDays?.count ?? 0
                Text(count == 7 ? "Everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 10)
            
            // MARK: Displaying current week and amrking active dates of habit
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.weekdaySymbols
            let startDate = currentWeek?.start ?? Date()
            let activeWeekDays = habit.weekDays ?? []
            let activePlot = symbols.indices.compactMap { index -> (String, Date) in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                return (symbols[index], currentDate!)
            }
            
            HStack(spacing: 0) {
                ForEach(activePlot.indices, id: \.self) { index in
                     let item = activePlot[index]
                    
                    VStack(spacing: 6) {
                        Text(item.0)
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
