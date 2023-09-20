//
//  AddNewHabitView.swift
//  HabitTracker
//
//  Created by Roberto Rojo Sahuquillo on 13/9/23.
//

import SwiftUI

struct AddNewHabitView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.self) var env
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
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
                
                Divider()
                
                // MARK: Frecuency selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Frecuency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.shortWeekdaySymbols
                    HStack(spacing: 10) {
                        ForEach(weekDays, id: \.self) { day in
                            
                            let index = viewModel.weekDays.firstIndex { value in
                                return value == day
                            } ?? -1 //No lo entiendo
                            
                            //MARK: Color frecuency selection
                            Text(day)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10,
                                                     style: .continuous)
                                    .fill(index != -1 ? Color(Color(viewModel.habitColor)).opacity(0.6) : Color("TFBG").opacity(0.6))
                                    .brightness(0.2)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            viewModel.weekDays.remove(at: index)
                                        } else {
                                            viewModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                
                Divider ()
                    .padding(.vertical, 10)
                
                //MARK: Reminder with toogle
                // Hidding if notification acess is rejected
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminder")
                            .fontWeight(.semibold)
                        
                        Text("Just notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $viewModel.isReminderOn) {
                        //
                    }
                    .labelsHidden()
                    
                }
                .opacity(viewModel.notificationAccess ? 1 : 0)
                
                //MARK: Reminders
                HStack(spacing: 12) {
                    Label {
                        Text(viewModel.reminderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color("TFBG").opacity(0.6),
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .brightness(0.2)
                    //MARK: Change value on Tap to dismiss time selection
                    .onTapGesture {
                        withAnimation {
                            viewModel.showTimePicker.toggle()
                        }
                    }

                    TextField("Reminder Text", text: $viewModel.reminderText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("TFBG").opacity(0.6),
                                    in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .brightness(0.2)

                }
                .frame(height: viewModel.isReminderOn ? nil : 0)
//                .animation(.easeInOut, value: viewModel.isReminderOn) //Why?
                .opacity(viewModel.isReminderOn ? 1 : 0)
                .opacity(viewModel.notificationAccess ? 1 : 0)


            }
            .animation(.easeInOut, value: viewModel.isReminderOn)

            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.editHabit != nil ? "Edit Habit" : "Add Habit")
            
            // MARK: Toolbar Configuration
            .toolbar {
                // MARK: Dismiss button
                ToolbarItem (placement: .navigationBarLeading) {
                    Button{
                        //Action
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                    .padding([.horizontal, .top], 5)
                }
                // MARK: Delete button
                ToolbarItem (placement: .navigationBarLeading) {
                    Button{
                        //Action
                        if viewModel.deleteHabit(context: env.managedObjectContext) {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(viewModel.editHabit == nil ? 0: 1)

                }
                // MARK: Done button
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button{
                        Task {
                            if await viewModel.addNewHabit(context: env.managedObjectContext) {
                                env.dismiss()
                            } 
                        }
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .tint(.white)
                    .padding([.horizontal, .top], 5)
                    .disabled(!viewModel.doneStatus())
                    .opacity(viewModel.doneStatus() ? 1 : 0.6)
                }
            }
        }
        //MARK: Overlay to launch TimePicker & using viewModel.showTimePicker.toogle
        .overlay {
            if viewModel.showTimePicker {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker.init("", selection: $viewModel.reminderDate,
                                    displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("TFBG"))
                            .brightness(0.2)
                    }
                    .padding()
                    
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
 
