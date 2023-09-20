//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Roberto Rojo Sahuquillo on 13/9/23.
//

import Foundation
import CoreData
import UserNotifications


class HabitViewModel: ObservableObject {
    // MARK: New Habit Properties
    @Published var addNewHabit: Bool = false
    
    @Published var title: String = ""
    @Published var habitColor: String = "Card-1"
    @Published var weekDays: [String] = []
    @Published var isReminderOn: Bool = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date = Date()
    
    
    // MARK: Reminder Time Picker
    @Published var showTimePicker: Bool = false
    
    // MARK:  Editing habit
    @Published var editHabit: Habit?
    
    // MARK: Notification Access Status
    @Published var notificationAccess: Bool = false
    
    init() {
        requestNotificationAccess()
    }
    
    // MARK: Requesting Access to Database
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    
    // MARK: Adding Habit to Database
    func addNewHabit(context: NSManagedObjectContext) async -> Bool {
        // MARK: Editing Data
        var habit: Habit!
        if let editHabit = editHabit {
             habit = editHabit
            // Removing All Pending Notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
        } else {
            habit = Habit(context: context)
        }
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isReminderOn = isReminderOn
        habit.reminderText = reminderText
        habit.notificationDate = reminderDate
        habit.notificationIDs = []
        
        if isReminderOn {
             //MARK: Scheduling notifications
            if let ids = try? await scheduleNotification() {
                habit.notificationIDs = ids
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            //MARK: Addding Data
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Adding notifications
    func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.subtitle = reminderText
        content.sound = UNNotificationSound.default
        
        
        // Scheduled Ids
        var notificationsIDs: [String] = []
        let calendar = Calendar.current
        let shortWeekdaySymbols: [String] = calendar.shortWeekdaySymbols
        
        //MARK: Scheduling notification
        for weekDay in weekDays {
            // Unique id for each notification
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: reminderDate)
            let min = calendar.component(.minute, from: reminderDate)
            let day = shortWeekdaySymbols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1
            // MARK: Since week day starts from 1-7
            // Thus adding +1 to index
            if day != -1 {
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                // MARK: Thus this will trigger notification on each selected day
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                //MARK: Notification request
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                try await UNUserNotificationCenter.current().add(request)
                
                //Adding ID
                notificationsIDs.append(id)
            }
        }
        return notificationsIDs
    }
    
    // MARK: Erasing Content
    func resetData() {
        title = ""
        habitColor = "Card-1"
        weekDays = []
        isReminderOn = false
        reminderDate = Date()
        reminderText = ""
        editHabit = nil
    }
    
    //MARK: Deleting habit from database
    func deleteHabit(context: NSManagedObjectContext) -> Bool {
        if let editHabit = editHabit {
            if editHabit.isReminderOn {
                // Removing All Pending Notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
            }
            context.delete(editHabit)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    //MARK: Restoring edit data
    func restoreEditData() {
        if let editHabit = editHabit {
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "Card-1"
            weekDays = editHabit.weekDays ?? []
            isReminderOn = editHabit.isReminderOn
            reminderDate = editHabit.notificationDate ?? Date()
            reminderText = editHabit.reminderText ?? ""
        }
    }
    
    
    // MARK: Done Button Status
    
    func doneStatus() -> Bool {
        let reminderStatus = isReminderOn ? reminderText == "" : false
        
        if title == "" || weekDays.isEmpty || reminderStatus {
            return false
        }
        
        return true
    }
}
